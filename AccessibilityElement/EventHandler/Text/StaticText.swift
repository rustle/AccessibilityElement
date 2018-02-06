//
//  StaticText.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct StaticText<ObserverProvidingType> : EventHandler where ObserverProvidingType : ObserverProviding, ObserverProvidingType.ElementType : _Element {
    public typealias ElementType = ObserverProvidingType.ElementType
    public var describerRequests: [DescriberRequest] = {
        let requests: [DescriberRequest] = [
            Describer<ElementType>.Single(required: true, attribute: .stringValue)
        ]
        return requests
    }()
    public weak var _controller: Controller<ElementType, StaticText<ObserverProvidingType>>?
    public let _node: Node<ElementType>
    public let observerManager: ObserverManager<ObserverProvidingType>
    public init(node: Node<ElementType>, observerManager: ObserverManager<ObserverProvidingType>) {
        _node = node
        self.observerManager = observerManager
    }
    public func connect() {
        
    }
    public mutating func focusIn() -> String? {
        let element = _node._element
        guard let results: [String?] = try? Describer<ElementType>().describe(element: element, requests: describerRequests) else {
            return nil
        }
        return results.prune().joined(separator: "")
    }
    public func focusOut() -> String? {
        return nil
    }
    public func disconnect() {
        
    }
}
