//
//  Registrar.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public typealias EventHandlerProviding = (AnyNode) throws -> AnyEventHandler

public class EventHandlerRegistrar {
    public static let shared = EventHandlerRegistrar()
    private var map = [Key:EventHandlerProviding]()
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
        static func ==(lhs: EventHandlerRegistrar.Key, rhs: EventHandlerRegistrar.Key) -> Bool {
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
                         eventHandler: @escaping EventHandlerProviding) {
        guard let key = key(role: role, subrole: subrole, identifier: identifier) else {
            return
        }
        map[key] = eventHandler
    }
    public func eventHandler<ElementType>(node: Node<ElementType>) throws -> AnyEventHandler where ElementType : _Element {
        guard let role = try? node.element.role() else {
            return DefaultEventHandler(node: node)
        }
        let subrole = try? node.element.subrole()
        let identifer: String? = nil
        if let key = key(role: role,
                         subrole: subrole,
                         identifier: identifer),
            let eventHandlerProviding = map[key] {
            do {
                return try eventHandlerProviding(node)
            } catch {
                
            }
        }
        switch role {
        case .application:
            return Application(node: node)
        case .window:
            return Window(node: node)
        case .staticText:
            if let subrole = subrole, subrole == .textAttachment {
                return TextAttachment(node: node)
            } else {
                return StaticText(node: node)
            }
        case .button:
            return Button(node: node)
        case .checkBox:
            if let subrole = subrole, subrole == .toggle {
                return Toggle(node: node)
            } else {
                return Checkbox(node: node)
            }
        case .textField:
            return TextField(node: node)
        default:
            return DefaultEventHandler(node: node)
        }
    }
}
