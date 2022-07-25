//
//  SystemObserver.swift
//
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

import AX
import Cocoa

public final class SystemObserver: Observer {
    public typealias ObserverElement = SystemElement
    public typealias ObserverToken = SystemObserverToken

    fileprivate class CallbackContext {
        private(set) weak var token: ObserverToken?
        init(token: ObserverToken) {
            self.token = token
        }
        fileprivate func handle(
            observer: AXObserver,
            uiElement: AXUIElement,
            name: CFString,
            info: CFDictionary?
        ) {
            guard let token = token else { return }
            guard let systemObserver = token.observer else { return }
            Task.detached {
                await systemObserver.handle(
                    element: uiElement as UIElement,
                    notification: token.notification,
                    uuid: token.uuid,
                    info: ObserverUserInfoRepackager.repackage(dictionary: info)
                )
            }
        }
    }

    // MARK: Init

    public let processIdentifier: pid_t
    public init(processIdentifier: pid_t) throws {
        self.processIdentifier = processIdentifier
    }

    // MARK: Schedule

    private var observer: AX.Observer?
    private var tokens: [NSAccessibility.Notification:[UUID:Unmanaged<CallbackContext>]] = [:]
    private var handlers: [NSAccessibility.Notification:[UUID:ObserverHandler]] = [:]
    private var retiredTokens = [Unmanaged<CallbackContext>]()

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
        let unmanagedToken = Unmanaged.passRetained(CallbackContext(token: token))
        let context = unmanagedToken.toOpaque()
        try throwsAXObserverError {
            try observer.add(
                element: element.element,
                notification: notification,
                context: context
            )
        }
        tokens[notification, default: [:]][token.uuid] = unmanagedToken
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
        if let unmanagedToken = tokens[notification]?.removeValue(forKey: uuid) {
            retiredTokens.append(unmanagedToken)
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
        } catch let error as AX.AXError {
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
    _ context: UnsafeMutableRawPointer?
) {
    guard let context = context else { return }
    let token = Unmanaged<SystemObserver.CallbackContext>
        .fromOpaque(context)
        .takeUnretainedValue()
    token
        .handle(
            observer: observer,
            uiElement: uiElement,
            name: name,
            info: info
        )
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

/**
 # What's up with retiredTokens?

 FB10280342: AXObserverCreateWithInfoCallback, AXObserverAddNotification, and AXObserverRemoveNotification APIs need cleanup callbacks

 Assuming the follow idiomatic AX API Observer setup:

     1. `AXObserver` is created
     2. Observer is scheduled on a runloop
     3. Any notification is observed via `AXObserverAddNotification` with a `refCon`
     4. That notification is then later removed

 In any concurrent settings where any of these interactions may happen on a runloop other than the one the observer is scheduled on *OR* if the memory pointed by refCon may be freed on a different runloop/queue/thread then there is no safe point at which the memory that is pointed to by the `refcon` argument can be reclaimed.

 The race here is that when remove `AXObserverRemoveNotification` is called it can't be guaranteed that a callback hasn't already been enqueued from another runloop/queue/thread and could still fire at an undefined point in the future when the relevant runloop is resumed.

 VoiceOver and other 1st party Assistive Technologies use the existing APIs significantly and work around this by using objc_weakStore/objc_weakLoad. This greatly limits architectural choices, inhibits testing, and makes interacting safely with Swift difficult.

 Consulting with the Swift forums, the recommendation, (which I strongly agree with) is an API that definitively signals that cleanup is safe. This could take several forms, but I think the following would be be addititive, non-ABI breaking, and straight forward to implement.

 Another approach might be to send an event to the existing callback using a convention that indicates cleanup is now appropriate and safe, but this is very likely to introduce compatibility issues with existing applications.
 */
