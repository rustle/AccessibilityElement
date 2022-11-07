//
//  ObserverNotification.swift
//
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

import Cocoa

public struct ObserverNotification<ObserverElement: Element> {
    public let observedElement: ObserverElement
    public let element: ObserverElement
    public let name: NSAccessibility.Notification
    public let info: [String : Any]
}
