//
//  EventHandler.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public enum EventType {
    case keyUp
    case keyDown
}

public protocol AnyEventHandler {
    var node: AnyNode { get }
    weak var controller: AnyController? { get set }
    var describerRequests: [DescriberRequest] { get }
    func makeController() throws -> AnyController
    mutating func configure(output: ((String) -> Void)?, sound: ((String, Int, TimeInterval) -> Void)?)
    mutating func connect()
    mutating func focusIn() -> String?
    mutating func focusOut() -> String?
    mutating func disconnect()
    mutating func handleEvent(identifier: String, type: EventType) throws
}

public protocol EventHandler : AnyEventHandler {
    associatedtype ObserverProvidingType : ObserverProviding where ObserverProvidingType.ElementType : _Element
    typealias ElementType = ObserverProvidingType.ElementType
    var _node: Node<ElementType> { get }
    weak var _controller: Controller<ElementType, Self>? { get set }
    var applicationObserver: ApplicationObserver<ObserverProvidingType> { get }
    init(node: Node<ElementType>, applicationObserver: ApplicationObserver<ObserverProvidingType>)
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
    public func configure(output: ((String) -> Void)?, sound: ((String, Int, TimeInterval) -> Void)?) {
        
    }
    mutating func handleEvent(identifier: String, type: EventType) throws {
        
    }
}
