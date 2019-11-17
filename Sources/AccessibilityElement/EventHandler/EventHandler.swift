//
//  EventHandler.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Foundation

public enum EventType {
    case keyUp
    case keyDown
}

public protocol AnyEventHandler {
    static func eventHandler(node: AnyNode,
                             applicationObserver: AnyApplicationObserver) throws -> AnyEventHandler
    var node: AnyNode { get }
    var controller: AnyController? { get set }
    var describerRequests: [DescriberRequest] { get }
    func makeController() throws -> AnyController
    mutating func configure(output: (([Output.Job.Payload]) -> Void)?)
    mutating func connect()
    mutating func focusIn() -> String?
    mutating func focusOut() -> String?
    mutating func disconnect()
    mutating func handleEvent(identifier: String, type: EventType) throws
}

public protocol EventHandler: AnyEventHandler {
    associatedtype ElementType: Element
    var _node: Node<ElementType> { get }
    var _controller: Controller<Self>? { get set }
    var applicationObserver: ApplicationObserver<ElementType> { get }
    init(node: Node<ElementType>,
         applicationObserver: ApplicationObserver<ElementType>)
}

public extension EventHandler {
    static func eventHandler(node: AnyNode,
                             applicationObserver: AnyApplicationObserver) throws -> AnyEventHandler {
        guard let node = node as? Node<ElementType> else {
            throw AccessibilityError.typeMismatch
        }
        guard let applicationObserver = applicationObserver as? ApplicationObserver<ElementType> else {
            throw AccessibilityError.typeMismatch
        }
        return Self.init(node: node,
                         applicationObserver: applicationObserver)
    }
    var node: AnyNode {
        _node
    }
    weak var controller: AnyController? {
        get {
            return _controller
        }
        set {
            _controller = newValue as? Controller<Self>
        }
    }
    func makeController() throws -> AnyController {
        try Controller<Self>(eventHandler: self)
    }
    func configure(output: (([Output.Job.Payload]) -> Void)?) {
        
    }
    mutating func handleEvent(identifier: String,
                              type: EventType) throws {
        
    }
}
