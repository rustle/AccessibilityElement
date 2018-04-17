//
//  Window.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct Window<ElementType> : EventHandler where ElementType : Element {
    public var describerRequests: [DescriberRequest] {
        return [
            Describer<ElementType>.Single(required: false, attribute: .title),
            Describer<ElementType>.Single(required: false, attribute: .roleDescription),
        ]
    }
    public weak var _controller: Controller<Window<ElementType>>?
    public let _node: Node<ElementType>
    public let applicationObserver: ApplicationObserver<ElementType>
    public init(node: Node<ElementType>,
                applicationObserver: ApplicationObserver<ElementType>) {
        _node = node
        self.applicationObserver = applicationObserver
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
