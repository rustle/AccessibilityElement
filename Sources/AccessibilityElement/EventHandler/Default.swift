//
//  Default.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct DefaultEventHandler<ElementType: Element>: EventHandler {
    public typealias ObserverProvidingType = ElementType.ObserverProvidingType
    public var describerRequests: [DescriberRequest] {
        let requests: [DescriberRequest] = [
            Describer<ElementType>.Fallthrough(required: true, attributes: [.title, .description, .stringValue(nil), .titleElement(Describer<ElementType>.Fallthrough(required: true, attributes: [.title, .description, .stringValue(nil)]))]),
            Describer<ElementType>.Single(required: true, attribute: .roleDescription)
        ]
        return requests
    }
    public weak var _controller: Controller<DefaultEventHandler<ElementType>>?
    public let _node: Node<ElementType>
    public let applicationObserver: ApplicationObserver<ElementType>
    public init(node: Node<ElementType>, applicationObserver: ApplicationObserver<ElementType>) {
        _node = node
        self.applicationObserver = applicationObserver
    }
    public mutating func connect() {
        
    }
    public mutating func focusIn() -> String? {
        let element = _node._element
        do {
            let results = try Describer().describe(element: element, requests: describerRequests)
            return results.compactMap({ $0 }).joined(separator: ", ")
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
