//
//  Toggle.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import os.log

public struct Toggle<ElementType> : EventHandler where ElementType : _Element {
    public var describerRequests: [DescriberRequest] {
        let requests: [DescriberRequest] = [
            Describer<ElementType>.Fallthrough(required: true, attributes: [.titleElement(Describer<ElementType>.Fallthrough(required: true, attributes: [.stringValue(nil), .title, .description])), .title, .description, .stringValue(nil)]),
            Describer<ElementType>.Single(required: true, attribute: .toggleValue),
            Describer<ElementType>.Single(required: true, attribute: .roleDescription),
        ]
        return requests
    }
    public weak var _controller: Controller<Toggle<ElementType>>?
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
        do {
            let results = try Describer().describe(element: element, requests: describerRequests)
            return results.map { $0! }.joined(separator: ", ")
        } catch {
            return nil
        }
    }
    public mutating func focusOut() -> String? {
        return nil
    }
    public mutating func disconnect() {
        
    }
}
