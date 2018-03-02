//
//  ObserverProviding.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa

func provider<ObserverProvidingType>(type: ObserverProvidingType.Type) -> ((Int) -> ObserverProvidingType) where ObserverProvidingType : ObserverProviding {
    if type.self == SystemObserverProviding.self {
        return SystemObserverProviding.provider() as! ((Int) -> ObserverProvidingType)
    }
    fatalError()
}

public protocol ObserverProviding {
    associatedtype ElementType : _Element
    mutating func add(element: ElementType,
                      notification: NSAccessibilityNotificationName,
                      handler: @escaping (ElementType, NSAccessibilityNotificationName, [String:Any]?) -> Void) throws -> Int
    mutating func remove(element: ElementType,
                         notification: NSAccessibilityNotificationName,
                         identifier: Int) throws
}
