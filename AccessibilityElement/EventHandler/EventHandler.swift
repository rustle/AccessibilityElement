//
//  EventHandler.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public protocol AnyEventHandler {
    var node: AnyNode { get }
    weak var controller: AnyController? { get set }
    var describerRequests: [DescriberRequest] { get }
    func makeController() throws -> AnyController
    mutating func connect()
    mutating func focusIn() -> String?
    mutating func valueChanged() -> String?
    mutating func focusOut() -> String?
    mutating func disconnect()
}

public protocol EventHandler : AnyEventHandler {
    associatedtype ElementType : _Element
    var _node: Node<ElementType> { get }
    weak var _controller: Controller<ElementType, Self>? { get set }
    init(node: Node<ElementType>)
}

public extension EventHandler {
    public var node: AnyNode {
        return _node
    }
    public weak var controller: AnyController? {
        get {
            return _controller
        }
        set {
            _controller = newValue as? Controller<ElementType, Self>
        }
    }
    public func makeController() throws -> AnyController {
        return try Controller<ElementType, Self>(eventHandler: self)
    }
    public mutating func valueChanged() -> String? {
        return nil
    }
}
