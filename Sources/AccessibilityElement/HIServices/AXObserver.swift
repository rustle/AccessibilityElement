//
//  AXObserver.swift
//
//  Copyright © 2017-2019 Doug Russell. All rights reserved.
//

import Cocoa

public typealias AXObserverHandler = (AXUIElement, NSAccessibility.Notification, CFDictionary?) -> Void

public class AXObserverToken {
    fileprivate let handler: AXObserverHandler
    fileprivate let unsafeReference: UnsafeMutablePointer<AXObserverHandler>
    fileprivate init(_ handler: @escaping AXObserverHandler) {
        self.handler = handler
        unsafeReference = UnsafeMutablePointer<AXObserverHandler>.allocate(capacity: 1)
        unsafeReference.initialize(to: handler)
    }
    deinit {
        unsafeReference.deinitialize(count: 1)
        unsafeReference.deallocate()
    }
}

public extension AXObserver {
    static var typeID: CFTypeID {
        return AXObserverGetTypeID()
    }
    //public func AXObserverGetRunLoopSource(_ observer: AXObserver) -> CFRunLoopSource
    var runLoopSource: CFRunLoopSource {
        return AXObserverGetRunLoopSource(self)
    }
    //public func AXObserverCreate(_ application: pid_t,
    //                             _ callback: @escaping ApplicationServices.AXObserverCallback,
    //                             _ outObserver: UnsafeMutablePointer<AXObserver?>) -> AXError
    //public func AXObserverCreateWithInfoCallback(_ application: pid_t,
    //                                             _ callback: @escaping ApplicationServices.AXObserverCallbackWithInfo,
    //                                             _ outObserver: UnsafeMutablePointer<AXObserver?>) -> AXError
    static func observer(processIdentifier: ProcessIdentifier) throws -> AXObserver {
        var observer: AXObserver?
        let error = AXObserverCreateWithInfoCallback(pid_t(processIdentifier),
                                                     observer_callback,
                                                     &observer)
        guard error == .success else {
            throw ObserverError(axError: error)
        }
        if let observer = observer {
            return observer
        }
        throw ObserverError.noValue
    }
    //public func AXObserverAddNotification(_ observer: AXObserver,
    //                                      _ element: AXUIElement,
    //                                      _ notification: CFString,
    //                                      _ refcon: UnsafeMutableRawPointer?) -> AXError
    func add(element: AXUIElement,
             notification: NSAccessibility.Notification,
             handler: @escaping AXObserverHandler) throws -> AXObserverToken {
        let token = AXObserverToken(handler)
        let error = AXObserverAddNotification(self,
                                              element,
                                              notification as CFString,
                                              token.unsafeReference)
        guard error == .success else {
            throw ObserverError(axError: error)
        }
        return token
    }
    //public func AXObserverRemoveNotification(_ observer: AXObserver,
    //                                         _ element: AXUIElement,
    //                                         _ notification: CFString) -> AXError
    func remove(element: AXUIElement,
                notification: NSAccessibility.Notification,
                token: AXObserverToken) throws {
        let error = AXObserverRemoveNotification(self,
                                                 element,
                                                 notification as CFString)
        guard error == .success else {
            throw ObserverError(axError: error)
        }
    }
}

private func observer_callback(_ observer: AXObserver,
                               _ uiElement: AXUIElement,
                               _ name: CFString,
                               _ info: CFDictionary?,
                               _ refCon: UnsafeMutableRawPointer?) {
    guard let handler = refCon?.assumingMemoryBound(to: AXObserverHandler.self).pointee else {
        return
    }
    handler(uiElement,
            name as NSAccessibility.Notification,
            info)
}
