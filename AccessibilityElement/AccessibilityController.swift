//
//  AccessibilityController.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import Foundation

open class Controller {
    public let element: Element
    public required init(element: Element) {
        self.element = element
    }
}

extension Controller : CustomDebugStringConvertible {
    public var debugDescription: String {
        return "<\(String(describing: type(of: self)))> \(element.debugDescription)"
    }
}

open class Application : Controller {
    open func connect() {
        
    }
}
