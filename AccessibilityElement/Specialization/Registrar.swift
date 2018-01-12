//
//  Registrar.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public typealias SpecializationProviding<ElementType> = (Controller<ElementType>) -> AnySpecialization where ElementType : _AccessibilityElement

public let SharedSpecializationRegistrar = SpecializationRegistrar<Element>()

public class SpecializationRegistrar<ElementType> where ElementType : _AccessibilityElement {
    private var map = [Key:SpecializationProviding<ElementType>]()
    private struct Key : Hashable {
        var hashValue: Int {
            var seed = 0
            if let role = role {
                seed ^= role.hashValue
            }
            if let subrole = subrole {
                seed ^= subrole.hashValue
            }
            if let identifier = identifier {
                seed ^= identifier.hashValue
            }
            return seed
        }
        static func ==(lhs: SpecializationRegistrar<ElementType>.Key, rhs: SpecializationRegistrar<ElementType>.Key) -> Bool {
            return
                lhs.role == rhs.role &&
                lhs.subrole == rhs.subrole &&
                lhs.identifier == rhs.identifier
        }
        var role: NSAccessibilityRole?
        var subrole: NSAccessibilitySubrole?
        var identifier: String?
        init?(role: NSAccessibilityRole?,
              subrole: NSAccessibilitySubrole?,
              identifier: String?) {
            if role == nil, subrole == nil, identifier == nil {
                return nil
            }
            self.role = role
            self.subrole = subrole
            self.identifier = identifier
        }
    }
    private func key(role: NSAccessibilityRole?,
                     subrole: NSAccessibilitySubrole?,
                     identifier: String?) -> Key? {
        return Key(role: role, subrole: subrole, identifier: identifier)
    }
    public func register(role: NSAccessibilityRole?,
                         subrole: NSAccessibilitySubrole?,
                         identifier: String?,
                         specialization: @escaping SpecializationProviding<ElementType>) {
        guard let key = key(role: role, subrole: subrole, identifier: identifier) else {
            return
        }
        map[key] = specialization
     }
    public func specialization(controller: Controller<ElementType>) -> AnySpecialization {
        guard let role = try? controller.node.element.role() else {
            return DefaultSpecialization<ElementType>(controller: controller)
        }
        let subrole = try? controller.node.element.subrole()
        let identifer: String? = nil
        if let key = key(role: role,
                         subrole: subrole,
                         identifier: identifer),
            let specializationProviding = map[key] {
            return specializationProviding(controller)
        }
        switch role {
        case .application:
            return Application<ElementType>(controller: controller)
        case .window:
            return Window<ElementType>(controller: controller)
        case .staticText:
            if let subrole = subrole, subrole == .textAttachment {
                return TextAttachment<ElementType>(controller: controller)
            } else {
                return StaticText<ElementType>(controller: controller)
            }
        case .button:
            return Button<ElementType>(controller: controller)
        case .checkBox:
            if let subrole = subrole, subrole == .toggle {
                return Toggle<ElementType>(controller: controller)
            }
        case .textField:
            return TextField<ElementType>(controller: controller)
        default:
            return DefaultSpecialization<ElementType>(controller: controller)
        }
        return DefaultSpecialization<ElementType>(controller: controller)
    }
}
