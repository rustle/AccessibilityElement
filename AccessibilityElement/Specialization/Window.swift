//
//  Window.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct Window<ElementType> : Specialization where ElementType : AccessibilityElement {
    public weak var controller: Controller<ElementType>?
    public init(controller: Controller<ElementType>) {
        self.controller = controller
    }
    public func connect() {
        guard let controller = controller else {
            return
        }
        controller.childControllers = controller.childControllers(node: controller.node)
    }
}
