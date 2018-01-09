//
//  StaticText.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct StaticText<ElementType> : Specialization where ElementType : AccessibilityElement {
    public weak var controller: Controller<ElementType>?
    public init(controller: Controller<ElementType>) {
        self.controller = controller
    }
    public mutating func focusIn() -> String? {
        guard let controller = controller else {
            return "no controller"
        }
        do {
            return try controller.node.element.value() as? String
        } catch {
            return "error"
        }
    }
}
