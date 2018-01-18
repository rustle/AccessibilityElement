//
//  TextField.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct TextField<ElementType> : EventHandler where ElementType : _Element {
    public var describerRequests: [DescriberRequest] = {
        let requests: [DescriberRequest] = [
            Describer<ElementType>.Single(required: true, attribute: .stringValue),
        ]
        return requests
    }()
    public weak var _controller: Controller<ElementType, TextField>?
    public let _node: Node<ElementType>
    public init(node: Node<ElementType>) {
        _node = node
    }
    private let describer = Describer<ElementType>()
    public mutating func connect() {
        
    }
    public mutating func focusIn() -> String? {
        let element = _node._element
        guard let results: [String?] = try? Describer().describe(element: element, requests: describerRequests) else {
            return nil
        }
        return results.prune().first
    }
    public mutating func focusOut() -> String? {
        return nil
    }
    public mutating func disconnect() {
        
    }
}
