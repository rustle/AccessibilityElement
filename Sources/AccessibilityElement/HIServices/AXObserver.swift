//
//  AXObserver.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import Cocoa

public typealias AXObserverHandler = (AXUIElement, NSAccessibilityNotificationName, CFDictionary?) -> Void

extension AXObserver {
    public static var typeID: CFTypeID {
        return AXObserverGetTypeID()
    }
    //public func AXObserverGetRunLoopSource(_ observer: AXObserver) -> CFRunLoopSource
    public var runLoopSource: CFRunLoopSource {
        return AXObserverGetRunLoopSource(self)
    }
    //public func AXObserverCreate(_ application: pid_t, _ callback: @escaping ApplicationServices.AXObserverCallback, _ outObserver: UnsafeMutablePointer<AXObserver?>) -> AXError
    //public func AXObserverCreateWithInfoCallback(_ application: pid_t, _ callback: @escaping ApplicationServices.AXObserverCallbackWithInfo, _ outObserver: UnsafeMutablePointer<AXObserver?>) -> AXError
    public static func observer(processIdentifier: Int) throws -> AXObserver {
        var observer: AXObserver?
        let error = AXObserverCreateWithInfoCallback(pid_t(processIdentifier), observer_callback, &observer)
        guard error == .success else {
            throw ObserverError(axError: error)
        }
        if let observer = observer {
            return observer
        }
        throw ObserverError.noValue
    }
    //public func AXObserverAddNotification(_ observer: AXObserver, _ element: AXUIElement, _ notification: CFString, _ refcon: UnsafeMutableRawPointer?) -> AXError
    public func add(element: AXUIElement, notification: NSAccessibilityNotificationName, handler: @escaping AXObserverHandler) throws -> Int {
        let identifier = axObserverState.next()
        let error = AXObserverAddNotification(self, element, notification as CFString, UnsafeMutableRawPointer(bitPattern: identifier))
        guard error == .success else {
            throw ObserverError(axError: error)
        }
        axObserverState.set(state: handler, identifier: identifier)
        return identifier
    }
    //public func AXObserverRemoveNotification(_ observer: AXObserver, _ element: AXUIElement, _ notification: CFString) -> AXError
    public func remove(element: AXUIElement, notification: NSAccessibilityNotificationName, identifier: Int) throws {
        let error = AXObserverRemoveNotification(self, element, notification as CFString)
        guard error == .success else {
            throw ObserverError(axError: error)
        }
        axObserverState.remove(identifier: identifier)
    }
}

fileprivate let axObserverState = SimpleState<AXObserverHandler>()

fileprivate func observer_callback(_ observer: AXObserver,
                                   _ uiElement: AXUIElement,
                                   _ name: CFString,
                                   _ info: CFDictionary?,
                                   _ refCon: UnsafeMutableRawPointer?) {
    let identifier = unsafeBitCast(refCon, to: Int.self)
    guard let handler = axObserverState.state(identifier: identifier) else {
        return
    }
    handler(uiElement, name as NSAccessibilityNotificationName, info)
}
