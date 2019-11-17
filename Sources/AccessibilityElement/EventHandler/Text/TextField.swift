//
//  TextField.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct TextField<ElementType: Element>: EventHandler {
    public var describerRequests: [DescriberRequest] = {
        let requests: [DescriberRequest] = [
            Describer<ElementType>.Single(required: true, attribute: .stringValue(nil)),
        ]
        return requests
    }()
    public weak var _controller: Controller<TextField<ElementType>>?
    public let _node: Node<ElementType>
    public let applicationObserver: ApplicationObserver<ElementType>
    public init(node: Node<ElementType>,
                applicationObserver: ApplicationObserver<ElementType>) {
        _node = node
        self.applicationObserver = applicationObserver
    }
    private let describer = Describer<ElementType>()
    public mutating func connect() {
        
    }
    public mutating func focusIn() -> String? {
        let element = _node._element
        guard let results: [String?] = try? Describer().describe(element: element, requests: describerRequests) else {
            return nil
        }
        return results.compactMap({ $0 }).first
    }
    public mutating func focusOut() -> String? {
        return nil
    }
    public mutating func disconnect() {
        
    }
}
