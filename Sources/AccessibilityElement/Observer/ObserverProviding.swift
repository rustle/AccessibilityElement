//
//  ObserverProviding.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa

func provider<ObserverProvidingType>(type: ObserverProvidingType.Type) -> ((ProcessIdentifier) -> ObserverProvidingType) where ObserverProvidingType : ObserverProviding {
    if type.self == SystemObserverProviding.self {
        return SystemObserverProviding.provider() as! ((ProcessIdentifier) -> ObserverProvidingType)
    }
    fatalError()
}

public protocol ObserverProviding {
    mutating func add(element: AnyElement,
                      notification: NSAccessibilityNotificationName,
                      handler: @escaping (AnyElement, NSAccessibilityNotificationName, [String:Any]?) -> Void) throws -> Int
    mutating func remove(element: AnyElement,
                         notification: NSAccessibilityNotificationName,
                         identifier: Int) throws
}
