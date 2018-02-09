//
//  AXObserver.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import Foundation

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
            throw AXUIElement.AXError(error: error)
        }
        if let observer = observer {
            return observer
        }
        throw AXUIElement.AXError.noValue
    }
    //public func AXObserverAddNotification(_ observer: AXObserver, _ element: AXUIElement, _ notification: CFString, _ refcon: UnsafeMutableRawPointer?) -> AXError
    public func add(element: AXUIElement, notification: NSAccessibilityNotificationName, handler: @escaping AXObserverHandler) throws -> Int {
        let identifier = axObserverState.next()
        let error = AXObserverAddNotification(self, element, notification as CFString, UnsafeMutableRawPointer(bitPattern: identifier))
        guard error == .success else {
            throw AXUIElement.AXError(error: error)
        }
        axObserverState.set(handler: handler, identifier: identifier)
        return identifier
    }
    //public func AXObserverRemoveNotification(_ observer: AXObserver, _ element: AXUIElement, _ notification: CFString) -> AXError
    public func remove(element: AXUIElement, notification: NSAccessibilityNotificationName, identifier: Int) throws {
        let error = AXObserverRemoveNotification(self, element, notification as CFString)
        guard error == .success else {
            throw AXUIElement.AXError(error: error)
        }
        axObserverState.remove(identifier: identifier)
    }
}

fileprivate class AXObserverState {
    private var handlers = [Int : AXObserverHandler]()
    private let queue = DispatchQueue(label: "AXObserverState")
    private var counter = 1234
    fileprivate func next() -> Int {
        counter += 1
        return counter
    }
    fileprivate func set(handler: @escaping AXObserverHandler, identifier: Int) {
        queue.sync(flags: [.barrier]) {
            handlers[identifier] = handler
        }
    }
    fileprivate func remove(identifier: Int) {
        queue.sync(flags: [.barrier]) { () -> Void in
            handlers.removeValue(forKey: identifier)
        }
    }
    fileprivate func handler(identifier: Int) -> AXObserverHandler? {
        return queue.sync {
            return handlers[identifier]
        }
    }
}
fileprivate let axObserverState = AXObserverState()

fileprivate func observer_callback(_ observer: AXObserver,
                                   _ uiElement: AXUIElement,
                                   _ name: CFString,
                                   _ info: CFDictionary?,
                                   _ refCon: UnsafeMutableRawPointer?) {
    print("callback \(name)")
    let identifier = unsafeBitCast(refCon, to: Int.self)
    guard let handler = axObserverState.handler(identifier: identifier) else {
        return
    }
    handler(uiElement, name as NSAccessibilityNotificationName, info)
}
