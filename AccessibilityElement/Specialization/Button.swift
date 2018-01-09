//
//  Button.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct Button<ElementType> : Specialization where ElementType : AccessibilityElement {
    public weak var controller: Controller<ElementType>?
    public init(controller: Controller<ElementType>) {
        self.controller = controller
    }
    public mutating func focusIn() -> String? {
        guard let controller = controller else {
            // TODO: remove this
            return "no controller"
        }
        do {
            let title = try controller.node.element.title()
            do {
                let roleDescription = try controller.node.element.roleDescription()
                return "\(title) \(roleDescription)"
            } catch {
                return title
            }
        } catch {
            // TODO: remove this
            return "error"
        }
    }
}
