//
//  Default.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct DefaultSpecialization<ElementType> : Specialization where ElementType : AccessibilityElement {
    public weak var controller: Controller<ElementType>?
    public init(controller: Controller<ElementType>) {
        self.controller = controller
    }
    public func focusIn() -> String? {
        guard let controller = controller else {
            return nil
        }
        let element = controller.node.element
        if let title = try? element.title(), title.count > 0 {
            return title
        } else if let description = try? element.description(), description.count > 0 {
            return description
        } else if let value = (try? element.value()) as? String, value.count > 0 {
            return value
        } else if let titleElement = try? element.titleElement() {
            if let title = try? titleElement.title(), title.count > 0 {
                return title
            } else if let description = try? titleElement.description(), description.count > 0 {
                return description
            }
        }
        return nil
    }
}
