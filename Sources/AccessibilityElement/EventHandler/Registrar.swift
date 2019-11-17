//
//  Registrar.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Cocoa

fileprivate struct SharedStorage {
    static var registrars = [String:Any]()
}

public class EventHandlerRegistrar<ElementType: Element> {
    public enum Error: Swift.Error {
        case registrarUnavailable
    }
    public static func shared() throws -> EventHandlerRegistrar<ElementType> {
        let key = String(describing: ElementType.ObserverProvidingType.self)
        guard let registrar = SharedStorage.registrars[key] else {
            let registrar = EventHandlerRegistrar<ElementType>()
            SharedStorage.registrars[key] = registrar
            return registrar
        }
        return (registrar as! EventHandlerRegistrar<ElementType>)
    }
    private var map = [Key:AnyEventHandler.Type]()
    private struct Key: Hashable {
        func hash(into hasher: inout Hasher) {
            if let role = role {
                hasher.combine(role)
            }
            if let subrole = subrole {
                hasher.combine(subrole)
            }
            if let identifier = identifier {
                hasher.combine(identifier)
            }
        }
        static func ==(lhs: EventHandlerRegistrar.Key,
                       rhs: EventHandlerRegistrar.Key) -> Bool {
            return
                lhs.role == rhs.role &&
                lhs.subrole == rhs.subrole &&
                lhs.identifier == rhs.identifier
        }
        var role: NSAccessibility.Role?
        var subrole: NSAccessibility.Subrole?
        var identifier: String?
        init?(role: NSAccessibility.Role?,
              subrole: NSAccessibility.Subrole?,
              identifier: String?) {
            if role == nil, subrole == nil, identifier == nil {
                return nil
            }
            self.role = role
            self.subrole = subrole
            self.identifier = identifier
        }
    }
    public func register(role: NSAccessibility.Role?,
                         subrole: NSAccessibility.Subrole?,
                         identifier: String?,
                         eventHandler: AnyEventHandler.Type) {
        guard let key = Key(role: role, subrole: subrole, identifier: identifier) else {
            return
        }
        map[key] = eventHandler
    }
    public func eventHandler(node: Node<ElementType>,
                             applicationObserver: ApplicationObserver<ElementType>) throws -> AnyEventHandler {
        guard let role = try? node.element.role() else {
            return DefaultEventHandler(node: node,
                                       applicationObserver: applicationObserver)
        }
        let subrole = try? node.element.subrole()
        let identifer: String? = nil
        if let key = Key(role: role,
                         subrole: subrole,
                         identifier: identifer) {
            if let EventHandlerType = map[key] {
                do {
                    return try EventHandlerType.eventHandler(node: node,
                                                             applicationObserver: applicationObserver)
                } catch { }
            }
        }
        switch role {
        case .application:
            return Application(node: node,
                               applicationObserver: applicationObserver)
        case .window:
            return Window(node: node,
                          applicationObserver: applicationObserver)
        case .staticText:
            if let subrole = subrole, subrole == .textAttachment {
                return TextAttachment(node: node,
                                      applicationObserver: applicationObserver)
            } else {
                return StaticText(node: node,
                                  applicationObserver: applicationObserver)
            }
        case .button:
            return Button(node: node,
                          applicationObserver: applicationObserver)
        case .checkBox:
            if let subrole = subrole, subrole == .toggle {
                return Toggle(node: node,
                              applicationObserver: applicationObserver)
            } else {
                return Checkbox(node: node,
                                applicationObserver: applicationObserver)
            }
        case .textField:
            return TextField(node: node,
                             applicationObserver: applicationObserver)
        case NSAccessibility.Role.webArea:
            return WebArea(node: node,
                           applicationObserver: applicationObserver)
        default:
            return DefaultEventHandler(node: node,
                                       applicationObserver: applicationObserver)
        }
    }
}
