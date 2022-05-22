//
//  SystemObserver.swift
//
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

import AX
import Cocoa
import ObjectiveC

public final class SystemObserver: Observer {
    public typealias ObserverElement = SystemElement
    public typealias ObserverToken = SystemObserverToken

    // MARK: Init

    public let processIdentifier: pid_t
    public init(processIdentifier: pid_t) throws {
        self.processIdentifier = processIdentifier
    }

    // MARK: Schedule

    private var observer: AX.Observer?
    private var tokens: [NSAccessibility.Notification:[UUID:UnsafeMutablePointer<SystemObserverToken?>]] = [:]
    private var handlers: [NSAccessibility.Notification:[UUID:ObserverHandler]] = [:]
    private var retiredTokens = [UnsafeMutablePointer<SystemObserverToken?>]()

    public final class SystemObserverToken: Hashable {
        public static func == (
            lhs: SystemObserverToken,
            rhs: SystemObserverToken
        ) -> Bool {
            lhs.uuid == rhs.uuid
        }
        fileprivate weak var observer: SystemObserver?
        fileprivate let notification: NSAccessibility.Notification
        fileprivate let uuid = UUID()
        fileprivate let element: SystemElement
        public func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
        }
        fileprivate init(
            observer: SystemObserver,
            notification: NSAccessibility.Notification,
            element: SystemElement
        ) {
            self.observer = observer
            self.notification = notification
            self.element = element
        }
        deinit {
            guard let observer = observer else {
                return
            }
            let element = self.element
            let notification = self.notification
            let uuid = self.uuid
            Task.detached {
                try await observer.remove(
                    element: element.element,
                    notification: notification,
                    uuid: uuid
                )
            }
        }
    }

    @ObserverRunLoopActor
    public func start() async throws {
        guard observer == nil else { return }
        let observer = try throwsAXObserverError {
            try AX.Observer(
                pid: self.processIdentifier,
                callback: observer_callback
            )
        }
        self.observer = observer
        observer.schedule()
    }

    @ObserverRunLoopActor
    public func stop() async throws {
        guard let observer = observer else { return }
        observer.unschedule()
        self.observer = nil
    }

    @ObserverRunLoopActor
    public func add(
        element: ObserverElement,
        notification: NSAccessibility.Notification,
        handler: @escaping ObserverHandler
    ) async throws -> ObserverToken {
        guard let observer = self.observer else {
            throw ObserverError.failure
        }
        let token = SystemObserverToken(
            observer: self,
            notification: notification,
            element: element
        )
        let weakToken = UnsafeMutablePointer<SystemObserverToken?>.allocate(capacity: 1)
        objc_storeWeak(
            AutoreleasingUnsafeMutablePointer(weakToken),
            token
        )
        try throwsAXObserverError {
            try observer.add(
                element: element.element,
                notification: notification,
                context: weakToken
            )
        }
        tokens[notification, default: [:]][token.uuid] = weakToken
        handlers[notification, default: [:]][token.uuid] = handler
        return token
    }

    @ObserverRunLoopActor
    public func remove(token: ObserverToken) async throws {
        try await remove(
            element: token.element.element,
            notification: token.notification,
            uuid: token.uuid
        )
    }

    @ObserverRunLoopActor
    fileprivate func remove(
        element: UIElement,
        notification: NSAccessibility.Notification,
        uuid: UUID
    ) async throws {
        guard let observer = self.observer else {
            throw ObserverError.failure
        }
        if let weakToken = tokens[notification]?.removeValue(forKey: uuid) {
            objc_storeWeak(
                AutoreleasingUnsafeMutablePointer(weakToken),
                nil
            )
            retiredTokens.append(weakToken)
        }
        handlers[notification]?.removeValue(forKey: uuid)
        try throwsAXObserverError {
            try observer.remove(
                element: element,
                notification: notification
            )
        }
    }

    @ObserverRunLoopActor
    fileprivate func handle(
        element: UIElement,
        notification: NSAccessibility.Notification,
        uuid: UUID,
        info: [String : Any]
    ) async {
        guard observer != nil else { return }
        guard let handler = handlers[notification]?[uuid] else { return }
        await handler(
            SystemElement(element: element),
            info
        )
    }

    private func throwsAXObserverError<T>(_ work: () throws -> T) rethrows -> T {
        do {
            return try work()
        } catch let error as AX.Error {
            throw ObserverError(axError: error.error)
        } catch {
            throw error
        }
    }
}

fileprivate func observer_callback(
    _ observer: AXObserver,
    _ uiElement: AXUIElement,
    _ name: CFString,
    _ info: CFDictionary?,
    _ refCon: UnsafeMutableRawPointer?
) {
    guard let weakToken = refCon?.assumingMemoryBound(to: AnyObject?.self) else { return }
    guard let token = objc_loadWeak(AutoreleasingUnsafeMutablePointer(weakToken)) as? SystemObserver.SystemObserverToken else { return }
    guard let observer = token.observer else { return }
    Task.detached {
        await observer.handle(
            element: uiElement as UIElement,
            notification: token.notification,
            uuid: token.uuid,
            info: ObserverUserInfoRepackager.repackage(dictionary: info)
        )
    }
}

fileprivate struct ObserverUserInfoRepackager {
    private static func _repackage(element: UIElement) -> SystemElement {
        SystemElement(element: element)
    }
    private static func _repackage(array: [Any]) -> [Any] {
        do {
            return try array.map { value in
                return try _repackage(value: value)
            }
        } catch {
            return []
        }
    }
    private static func _repackage(dictionary: [String:Any]) -> [String:Any] {
        do {
            return try dictionary.reduce(into: [:]) { result, pair in
                result[pair.key] = try _repackage(value: pair.value as CFTypeRef)
            }
        } catch {
            return [:]
        }
    }
    private static func _repackage(value: Any) throws -> Any {
        let typeID = CFGetTypeID(value as CFTypeRef)
        switch typeID {
        case AXUIElementGetTypeID():
            return SystemElement(element: UIElement(element: value as! AXUIElement))
        case AXValueGetTypeID():
            return try AX.Value(value: (value as! AXValue))
        case CFNumberGetTypeID():
            return (value as! NSNumber).intValue
        case CFBooleanGetTypeID():
            return (value as! NSNumber).boolValue
        case AXTextMarkerGetTypeID():
            return TextMarker(textMarker: value as! AXTextMarker)
        case AXTextMarkerRangeGetTypeID():
            return TextMarkerRange(textMarkerRange: (value as! AXTextMarkerRange))
        default:
            break
        }
        switch value {
        case let array as [String]:
            return _repackage(array: array)
        case let dictionary as [String:Any]:
            return _repackage(dictionary: dictionary)
        case let string as String:
            return string
        case let attributeString as NSAttributedString:
            return attributeString
        default:
            throw AccessibilityError.typeMismatch
        }
    }
    static func repackage(dictionary: CFDictionary?) -> [String : Any] {
        guard let dictionary = dictionary as? [String:Any] else {
            return [:]
        }
        return _repackage(dictionary: dictionary)
    }
}
