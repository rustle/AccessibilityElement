//
//  Registrar.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public class SpecializationRegistrar<ElementType> where ElementType : AccessibilityElement {
    public func specialization(controller: Controller<ElementType>) -> AnySpecialization {
        guard let role = try? controller.node.element.role() else {
            return DefaultSpecialization<ElementType>(controller: controller)
        }
        switch role {
        case .application:
            return Application<ElementType>(controller: controller)
        case .window:
            return Window<ElementType>(controller: controller)
        default:
            return DefaultSpecialization<ElementType>(controller: controller)
        }
    }
}
