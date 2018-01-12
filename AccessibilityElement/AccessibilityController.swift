//
//  AccessibilityController.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import Foundation

public protocol AnyController {
    var specialization: AnySpecialization { get }
}

public class Controller<ElementType> : AnyController where ElementType : _AccessibilityElement {
    public var registrar: SpecializationRegistrar<ElementType> {
        if ElementType.self == Element.self {
            return SharedSpecializationRegistrar as! SpecializationRegistrar<ElementType>
        }
        fatalError()
    }
    public let node: Node<ElementType>
    public weak var parentController: Controller?
    public var childControllers: [Controller]?
    private var _specialization: AnySpecialization?
    public private(set) var specialization: AnySpecialization {
        get {
            return _specialization!
        }
        set {
            _specialization = newValue
        }
    }
    public var output: ((String) -> Void)?
    public required init(node: Node<ElementType>) {
        self.node = node
        _specialization = registrar.specialization(controller: self)
    }
    public func connect() -> String? {
        return specialization.connect()
    }
    public func focusIn() -> String? {
        return specialization.focusIn()
    }
    public func focusOut() -> String? {
        return specialization.focusOut()
    }
    public func childControllers(node: Node<ElementType>) -> [Controller<ElementType>] {
        return node.children.map { node in
            let controller = Controller<ElementType>(node: node)
            controller.parentController = self
            return controller
        }
    }
}

extension Controller : CustomDebugStringConvertible {
    public var debugDescription: String {
        var debugDescription = "<\(String(describing: type(of: self)))>"
        if let debugElement = node.element as? CustomDebugStringConvertible {
            debugDescription += " \(debugElement.debugDescription)"
        }
        if let debugSpecialization = specialization as? CustomDebugStringConvertible {
            debugDescription += " \(debugSpecialization.debugDescription)"
        }
        return debugDescription
    }
}

extension Controller : CustomDebugDictionaryConvertible {
    public var debugInfo: [String:CustomDebugStringConvertible] {
        var debugInfo = [String:CustomDebugStringConvertible]()
        debugInfo["type"] = String(describing: type(of: self))
        if let debugElement = node.element as? CustomDebugDictionaryConvertible {
            debugInfo["element"] = debugElement.debugInfo
        }
        if let debugSpecialization = specialization as? CustomDebugDictionaryConvertible {
            debugInfo["specialization"] = debugSpecialization.debugInfo
        }
        return debugInfo
    }
}
