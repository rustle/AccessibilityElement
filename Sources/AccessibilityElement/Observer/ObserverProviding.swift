//
//  ObserverProviding.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Cocoa

func provider<ObserverProvidingType>(type: ObserverProvidingType.Type) -> ((ProcessIdentifier) -> ObserverProvidingType) where ObserverProvidingType : ObserverProviding {
    if type.self == SystemObserverProviding.self {
        return SystemObserverProviding.provider() as! ((ProcessIdentifier) -> ObserverProvidingType)
    }
    fatalError()
}

public protocol ObserverToken {}

public protocol ObserverProviding {
    mutating func add(element: AnyElement,
                      notification: NSAccessibility.Notification,
                      handler: @escaping (AnyElement, NSAccessibility.Notification, [String:Any]?) -> Void) throws -> ObserverToken
    mutating func remove(element: AnyElement,
                         notification: NSAccessibility.Notification,
                         token: ObserverToken) throws
}
