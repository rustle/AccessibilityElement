//
//  Registrar.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

fileprivate struct SharedStorage {
    static var registrars = [String:Any]()
}

public class EventHandlerRegistrar<ObserverProvidingType> where ObserverProvidingType : ObserverProviding {
    public enum Error : Swift.Error {
        case registrarUnavailable
    }
    public static func shared() throws -> EventHandlerRegistrar<ObserverProvidingType> {
        let key = String(describing: ObserverProvidingType.self)
        guard let registrar = SharedStorage.registrars[key] else {
            let registrar = EventHandlerRegistrar<ObserverProvidingType>()
            SharedStorage.registrars[key] = registrar
            return registrar
        }
        return (registrar as! EventHandlerRegistrar<ObserverProvidingType>)
    }
    private var map = [Key:AnyEventHandler.Type]()
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
    public func register(role: NSAccessibilityRole?,
                         subrole: NSAccessibilitySubrole?,
                         identifier: String?,
                         eventHandler: AnyEventHandler.Type) {
        guard let key = Key(role: role, subrole: subrole, identifier: identifier) else {
            return
        }
        map[key] = eventHandler
    }
    public func eventHandler(node: Node<ObserverProvidingType.ElementType>,
                             applicationObserver: ApplicationObserver<ObserverProvidingType>) throws -> AnyEventHandler {
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
        case NSAccessibilityRole.webArea:
            return WebArea(node: node,
                           applicationObserver: applicationObserver)
        default:
            return DefaultEventHandler(node: node,
                                       applicationObserver: applicationObserver)
        }
    }
}
