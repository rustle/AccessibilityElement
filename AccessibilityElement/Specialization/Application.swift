//
//  Application.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct Application<ElementType> : Specialization where ElementType : AccessibilityElement {
    public weak var controller: Controller<ElementType>?
    public init(controller: Controller<ElementType>) {
        self.controller = controller
    }
    public var isFocused: Bool = false
    mutating public func focusIn() -> String? {
        guard let controller = controller else {
            return nil
        }
        if isFocused {
            return nil
        }
        isFocused = true
        controller.childControllers = controller.childControllers(node: controller.node)
        do {
            let title = try controller.node.element.title()
            return "focused \(String(describing: title))"
        } catch {
            return "focused"
        }
    }
    mutating public func focusOut() -> String? {
        isFocused = false
        return nil
    }
}
