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
        case .staticText:
            return StaticText<ElementType>(controller: controller)
        case .button:
            return Button<ElementType>(controller: controller)
        case .checkBox:
            if let subrole = try? controller.node.element.subrole(), subrole == .toggle {
                return Toggle<ElementType>(controller: controller)
            } else {
                return DefaultSpecialization<ElementType>(controller: controller)
            }
        default:
            return DefaultSpecialization<ElementType>(controller: controller)
        }
    }
}
