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
    mutating func focusOut() -> String?
    mutating func disconnect()
}

public protocol EventHandler : AnyEventHandler {
    associatedtype ObserverProvidingType : ObserverProviding where ObserverProvidingType.ElementType : _Element
    typealias ElementType = ObserverProvidingType.ElementType
    var _node: Node<ElementType> { get }
    weak var _controller: Controller<ElementType, Self>? { get set }
    var observerManager: ObserverManager<ObserverProvidingType> { get }
    init(node: Node<ElementType>, observerManager: ObserverManager<ObserverProvidingType>)
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
}
