//
//  TextAttachment.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct TextAttachment<ElementType> : EventHandler where ElementType : _Element {
    public var describerRequests: [DescriberRequest] = {
        let requests: [DescriberRequest] = [
            Describer<ElementType>.Single(required: true, attribute: .attachmentText),
        ]
        return requests
    }()
    public weak var _controller: Controller<ElementType, TextAttachment<ElementType>>?
    public let _node: Node<ElementType>
    public init(node: Node<ElementType>) {
        _node = node
    }
    private let describer = Describer<ElementType>()
    public func connect() {
        
    }
    public mutating func focusIn() -> String? {
        let element = _node._element
        guard let results: [String?] = try? Describer<ElementType>().describe(element: element, requests: describerRequests) else {
            return nil
        }
        return results.prune().first
    }
    public func focusOut() -> String? {
        return nil
    }
    public func disconnect() {
        
    }
}
