//
//  Button.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct Button<ObserverProvidingType> : EventHandler where ObserverProvidingType : ObserverProviding {
    public typealias ElementType = ObserverProvidingType.ElementType
    public var describerRequests: [DescriberRequest] {
        let requests: [DescriberRequest] = [
            Describer<ElementType>.Fallthrough(required: true, attributes: [.title, .description, .stringValue, .titleElement(Describer<ElementType>.Fallthrough(required: true, attributes: [.title, .description, .stringValue]))]),
            Describer<ElementType>.Single(required: true, attribute: .roleDescription),
        ]
        return requests
    }
    public weak var _controller: Controller<Button<ObserverProvidingType>>?
    public let _node: Node<ElementType>
    public let applicationObserver: ApplicationObserver<ObserverProvidingType>
    public init(node: Node<ElementType>, applicationObserver: ApplicationObserver<ObserverProvidingType>) {
        _node = node
        self.applicationObserver = applicationObserver
    }
    public mutating func connect() {
        
    }
    public mutating func focusIn() -> String? {
        let element = _node._element
        guard let results = try? Describer<ElementType>().describe(element: element, requests: describerRequests) else {
            return nil
        }
        return results.map { $0! }.joined(separator: ", ")
    }
    public mutating func focusOut() -> String? {
        return nil
    }
    public mutating func disconnect() {
        
    }
}
