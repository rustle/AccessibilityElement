//
//  SystemObserver.swift
//
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

import AX
import Cocoa

@ObserverRunLoopActor
public final class SystemObserver: Observer {
    public typealias ObserverElement = SystemElement
    public typealias ObserverToken = SystemObserverToken

    // MARK: Init

    public let pid: pid_t
    public init(pid: pid_t) throws {
        self.pid = pid
    }

    // MARK: Schedule

    private var observer: AX.Observer!
    private var tokens: [NSAccessibility.Notification:[UUID:SystemObserverToken]] = [:]

    public final class SystemObserverToken: Hashable {
        public static func == (lhs: SystemObserverToken,
                               rhs: SystemObserverToken) -> Bool {
            lhs.uuid == rhs.uuid
        }
        fileprivate let uuid = UUID()
        fileprivate weak var observer: SystemObserver?
        fileprivate let element: SystemElement
        fileprivate let notification: NSAccessibility.Notification
        fileprivate let handler: ObserverHandler
        public func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
        }
        fileprivate init(observer: SystemObserver,
                         element: SystemElement,
                         notification: NSAccessibility.Notification,
                         handler: @escaping ObserverHandler) {
            self.observer = observer
            self.element = element
            self.notification = notification
            self.handler = handler
        }
        deinit {
            guard let observer = observer else {
                return
            }
            let element = self.element
            let notification = self.notification
            let uuid = self.uuid
            Task.detached {
                try await observer.remove(element: element.element,
                                          notification: notification,
                                          uuid: uuid)
            }
        }
    }

    public func start() async throws {
        if self.observer == nil {
            self.observer = try AX.Observer(pid: self.pid,
                                            callback: observer_callback)
        }
        self.observer
            .schedule(on: .current)
    }

    public func add(element: ObserverElement,
                    notification: NSAccessibility.Notification,
                    handler: @escaping ObserverHandler) async throws -> ObserverToken {
        guard let observer = self.observer else {
            throw ObserverError.failure
        }
        let unsafeToken = UnsafeMutablePointer<SystemObserverToken>.allocate(capacity: 1)
        unsafeToken.initialize(to: SystemObserverToken(observer: self,
                                                       element: element,
                                                       notification: notification,
                                                       handler: handler))
        try observer.add(element: element.element,
                         notification: notification,
                         context: unsafeToken)
        let token = unsafeToken.pointee
        tokens[notification, default: [:]][token.uuid] = token
        return token
    }

    public func remove(token: ObserverToken) async throws {
        try await remove(element: token.element.element,
                         notification: token.notification,
                         uuid: token.uuid)
    }

    fileprivate func remove(element: UIElement,
                            notification: NSAccessibility.Notification,
                            uuid: UUID) async throws {
        guard let observer = self.observer else {
            throw ObserverError.failure
        }
        try observer.remove(element: element,
                            notification: notification)
        tokens[notification]?.removeValue(forKey: uuid)
    }
}

fileprivate func observer_callback(_ observer: AXObserver,
                                   _ uiElement: AXUIElement,
                                   _ name: CFString,
                                   _ info: CFDictionary?,
                                   _ refCon: UnsafeMutableRawPointer?) {
    guard
        let token = refCon?.assumingMemoryBound(to: SystemObserver.SystemObserverToken.self).pointee,
        let observer = token.observer
    else {
        return
    }
    withExtendedLifetime(observer) {
        token.handler(SystemElement(element: uiElement as UIElement),
                      ObserverUserInfoRepackager.repackage(dictionary: info))
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
