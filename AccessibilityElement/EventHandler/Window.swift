//
//  Window.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct Window<ObserverProvidingType> : EventHandler where ObserverProvidingType : ObserverProviding, ObserverProvidingType.ElementType : _Element {
    public typealias ElementType = ObserverProvidingType.ElementType
    public var describerRequests: [DescriberRequest] {
        return [
            Describer<ElementType>.Single(required: false, attribute: .title),
            Describer<ElementType>.Single(required: false, attribute: .roleDescription),
        ]
    }
    public weak var _controller: Controller<ElementType, Window<ObserverProvidingType>>?
    public let _node: Node<ElementType>
    public let observerManager: ObserverManager<ObserverProvidingType>
    public init(node: Node<ElementType>, observerManager: ObserverManager<ObserverProvidingType>) {
        _node = node
        self.observerManager = observerManager
    }
    public func connect() {
        
    }
    public func focusIn() -> String? {
        return nil
    }
    public func focusOut() -> String? {
        return nil
    }
    public func disconnect() {
        
    }
}
