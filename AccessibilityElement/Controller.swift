//
//  Controller.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import Foundation
import os.log

public protocol AnyController : class {
    var eventHandler: AnyEventHandler { get set }
    weak var parentController: AnyController? { get set }
    var childControllers: [AnyController]? { get set }
}

public class _Controller<ElementType> : AnyController where ElementType : _Element {
    public weak var applicationController: _Controller<ElementType>?
    public weak var parentController: AnyController? {
        get {
            return _parentController
        }
        set {
            _parentController = newValue as? _Controller<ElementType>
        }
    }
    public weak var _parentController: _Controller<ElementType>?
    public var childControllers: [AnyController]? {
        get {
            return _childControllers
        }
        set {
            _childControllers = newValue as? [_Controller<ElementType>]
        }
    }
    public var _childControllers: [_Controller<ElementType>]?
    public var eventHandler: AnyEventHandler {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }
    public var node: Node<ElementType> {
        get {
            fatalError()
        }
    }
}

extension _Controller : Equatable {
    public static func ==(lhs: _Controller<ElementType>, rhs: _Controller<ElementType>) -> Bool {
        return lhs.node == rhs.node
    }
}

public class Controller<ElementType, EventHandlerType> : _Controller<ElementType> where
    ElementType : _Element,
    EventHandlerType : EventHandler
{
    public var _eventHandler: EventHandlerType
    public override var eventHandler: AnyEventHandler {
        get {
            return _eventHandler
        }
        set {
            _eventHandler = newValue as! EventHandlerType
        }
    }
    public required init(eventHandler: EventHandlerType) throws {
        _eventHandler = eventHandler
        super.init()
        _eventHandler.controller = self
    }
    public func childControllers(node: Node<ElementType>) throws -> [_Controller<ElementType>] {
        return try node.children.map { node in
            // TODO: This casting sucks
            let applicationObserver = _eventHandler.applicationObserver
            let node: Node<EventHandlerType.ObserverProvidingType.ElementType> = node as! Node<EventHandlerType.ObserverProvidingType.ElementType>
            let controller = try EventHandlerRegistrar.shared.eventHandler(node: node, applicationObserver: applicationObserver).makeController() as! _Controller<ElementType>
            controller.applicationController = applicationController
            controller.parentController = self
            return controller
        }
    }
    public override var node: Node<ElementType> {
        get {
            return _eventHandler._node as! Node<ElementType>
        }
    }
}

extension Controller : CustomDebugStringConvertible {
    public var debugDescription: String {
        var debugDescription = "<\(String(describing: type(of: self)))>"
        if let debugElement = eventHandler.node.element as? CustomDebugStringConvertible {
            debugDescription += " \(debugElement.debugDescription)"
        }
        if let debugEventHandler = eventHandler as? CustomDebugStringConvertible {
            debugDescription += " \(debugEventHandler.debugDescription)"
        }
        return debugDescription
    }
}

extension Controller : CustomDebugDictionaryConvertible {
    public var debugInfo: [String:CustomDebugStringConvertible] {
        var debugInfo = [String:CustomDebugStringConvertible]()
        debugInfo["type"] = String(describing: type(of: self))
        if let debugElement = eventHandler.node.element as? CustomDebugDictionaryConvertible {
            debugInfo["element"] = debugElement.debugInfo
        }
        if let debugEventHandler = eventHandler as? CustomDebugDictionaryConvertible {
            debugInfo["eventHandler"] = debugEventHandler.debugInfo
        }
        return debugInfo
    }
}
