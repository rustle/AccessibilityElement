//
//  WebArea.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import os.log

public struct WebArea<ElementType> : EventHandler where ElementType : _Element {
    public var describerRequests: [DescriberRequest] {
        return []
    }
    public weak var _controller: Controller<ElementType, WebArea<ElementType>>?
    public let _node: Node<ElementType>
    public init(node: Node<ElementType>) {
        _node = node
    }
    public mutating func connect() {
        _ = try? _node._element.set(caretBrowsing: true)
    }
    public mutating func focusIn() -> String? {
        return nil
    }
    public mutating func focusOut() -> String? {
        return nil
    }
    public mutating func disconnect() {
        
    }
}
