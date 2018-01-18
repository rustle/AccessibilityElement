//
//  Window.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct Window<ElementType> : EventHandler where ElementType : _Element {
    public var describerRequests: [DescriberRequest] {
        return [
            Describer<ElementType>.Single(required: false, attribute: .title),
            Describer<ElementType>.Single(required: false, attribute: .roleDescription),
        ]
    }
    public weak var _controller: Controller<ElementType, Window<ElementType>>?
    public let _node: Node<ElementType>
    public init(node: Node<ElementType>) {
        _node = node
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
