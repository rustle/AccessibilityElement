//
//  Registrar.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public typealias EventHandlerProviding = (AnyNode, AnyObserverManager) throws -> AnyEventHandler

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
    public func eventHandler<ObserverProvidingType>(node: Node<ObserverProvidingType.ElementType>, observerManager: ObserverManager<ObserverProvidingType>) throws -> AnyEventHandler {
        guard let role = try? node.element.role() else {
            return DefaultEventHandler(node: node, observerManager: observerManager)
        }
        let subrole = try? node.element.subrole()
        let identifer: String? = nil
        if let key = key(role: role,
                         subrole: subrole,
                         identifier: identifer),
            let eventHandlerProviding = map[key] {
            do {
                return try eventHandlerProviding(node, observerManager)
            } catch {
                
            }
        }
        switch role {
        case .application:
            return Application(node: node,
                               observerManager: observerManager)
        case .window:
            return Window(node: node,
                          observerManager: observerManager)
        case .staticText:
            if let subrole = subrole, subrole == .textAttachment {
                return TextAttachment(node: node,
                                      observerManager: observerManager)
            } else {
                return StaticText(node: node,
                                  observerManager: observerManager)
            }
        case .button:
            return Button(node: node,
                          observerManager: observerManager)
        case .checkBox:
            if let subrole = subrole, subrole == .toggle {
                return Toggle(node: node,
                              observerManager: observerManager)
            } else {
                return Checkbox(node: node,
                                observerManager: observerManager)
            }
        case .textField:
            return TextField(node: node,
                             observerManager: observerManager)
        case NSAccessibilityRole.webArea:
            return WebArea(node: node,
                           observerManager: observerManager)
        default:
            return DefaultEventHandler(node: node,
                                       observerManager: observerManager)
        }
    }
}
