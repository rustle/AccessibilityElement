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
    static func eventHandler(node: AnyNode,
                             applicationObserver: AnyApplicationObserver) throws -> AnyEventHandler
    var node: AnyNode { get }
    weak var controller: AnyController? { get set }
    var describerRequests: [DescriberRequest] { get }
    func makeController() throws -> AnyController
    mutating func configure(output: (([Output.Job.Payload]) -> Void)?)
    mutating func connect()
    mutating func focusIn() -> String?
    mutating func focusOut() -> String?
    mutating func disconnect()
    mutating func handleEvent(identifier: String, type: EventType) throws
}

public protocol EventHandler : AnyEventHandler {
    associatedtype ObserverProvidingType : ObserverProviding
    typealias ElementType = ObserverProvidingType.ElementType
    var _node: Node<ElementType> { get }
    weak var _controller: Controller<Self>? { get set }
    var applicationObserver: ApplicationObserver<ObserverProvidingType> { get }
    init(node: Node<ElementType>, applicationObserver: ApplicationObserver<ObserverProvidingType>)
}

public extension EventHandler {
    static func eventHandler(node: AnyNode,
                             applicationObserver: AnyApplicationObserver) throws -> AnyEventHandler {
        guard let node = node as? Node<ElementType> else {
            throw AccessibilityError.typeMismatch
        }
        guard let applicationObserver = applicationObserver as? ApplicationObserver<ObserverProvidingType> else {
            throw AccessibilityError.typeMismatch
        }
        return Self.init(node: node,
                         applicationObserver: applicationObserver)
    }
    public var node: AnyNode {
        return _node
    }
    public weak var controller: AnyController? {
        get {
            return _controller
        }
        set {
            _controller = newValue as? Controller<Self>
        }
    }
    public func makeController() throws -> AnyController {
        return try Controller<Self>(eventHandler: self)
    }
    public func configure(output: (([Output.Job.Payload]) -> Void)?) {
        
    }
    mutating func handleEvent(identifier: String, type: EventType) throws {
        
    }
}
