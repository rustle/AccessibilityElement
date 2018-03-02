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
    var childControllers: [AnyController] { get set }
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
    public var childControllers: [AnyController] {
        get {
            return _childControllers
        }
        set {
            _childControllers = (newValue as? [_Controller<ElementType>]) ?? []
        }
    }
    public var _childControllers: [_Controller<ElementType>] = []
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
    public func childControllers(node: Node<ElementType>, reuse: Bool = true) throws -> [_Controller<ElementType>] {
        return []
    }
}

extension _Controller : Equatable {
    public static func ==(lhs: _Controller<ElementType>, rhs: _Controller<ElementType>) -> Bool {
        return lhs.node == rhs.node
    }
}

public class Controller<EventHandlerType> : _Controller<EventHandlerType.ObserverProvidingType.ElementType> where EventHandlerType : EventHandler {
    public typealias ObserverProvidingType = EventHandlerType.ObserverProvidingType
    public typealias ElementType = ObserverProvidingType.ElementType
    public var _eventHandler: EventHandlerType
    public override var eventHandler: AnyEventHandler {
        get {
            return _eventHandler
        }
        set {
            _eventHandler = newValue as! EventHandlerType
        }
    }
    public var applicationObserver: ApplicationObserver<ObserverProvidingType> {
        return _eventHandler.applicationObserver
    }
    public required init(eventHandler: EventHandlerType) throws {
        _eventHandler = eventHandler
        super.init()
        _eventHandler.controller = self
    }
    public override func childControllers(node: Node<ElementType>, reuse: Bool = true) throws -> [_Controller<ElementType>] {
#if swift(>=4.1)
        let currentChildrenReuseMap: [Node<ElementType>:_Controller<ElementType>]
        if reuse {
            currentChildrenReuseMap = _childControllers.reduce(into: [Node<ElementType>:_Controller<ElementType>]()) { reuseMap, controller in
                reuseMap[controller.node] = controller
            }
        } else {
            currentChildrenReuseMap = [:]
        }
#else
        let currentChildrenReuseMap: [HashableNode<ElementType>:_Controller<ElementType>]
        if reuse {
            currentChildrenReuseMap = _childControllers.reduce(into: [HashableNode<ElementType>:_Controller<ElementType>]()) { reuseMap, controller in
                reuseMap[HashableNode(node: controller.node)] = controller
            }
        } else {
            currentChildrenReuseMap = [:]
        }
#endif
        let applicationObserver = _eventHandler.applicationObserver
        let shared = try EventHandlerRegistrar<ObserverProvidingType>.shared()
        return try node.children.map { node in
#if swift(>=4.1)
            if let controller = currentChildrenReuseMap[node] {
                return controller
            }
#else
            if let controller = currentChildrenReuseMap[HashableNode(node: node)] {
                return controller
            }
#endif
            guard let controller = try shared.eventHandler(node: node, applicationObserver: applicationObserver).makeController() as? _Controller<ElementType> else {
                throw AccessibilityError.typeMismatch
            }
            controller.applicationController = applicationController
            controller.parentController = self
            return controller
        }
    }
    public override var node: Node<ElementType> {
        get {
            return _eventHandler._node
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
