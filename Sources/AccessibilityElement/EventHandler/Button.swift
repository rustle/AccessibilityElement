//
//  Button.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct Button<ElementType> : EventHandler where ElementType : _Element {
    public typealias ObserverProvidingType = ElementType.ObserverProvidingType
    public var describerRequests: [DescriberRequest] {
        let requests: [DescriberRequest] = [
            Describer<ElementType>.Fallthrough(required: true, attributes: [.title, .description, .stringValue(nil), .titleElement(Describer<ElementType>.Fallthrough(required: true, attributes: [.title, .description, .stringValue(nil)]))]),
            Describer<ElementType>.Single(required: true, attribute: .roleDescription),
        ]
        return requests
    }
    public weak var _controller: Controller<Button<ElementType>>?
    public let _node: Node<ElementType>
    public let applicationObserver: ApplicationObserver<ElementType>
    public init(node: Node<ElementType>,
                applicationObserver: ApplicationObserver<ElementType>) {
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
