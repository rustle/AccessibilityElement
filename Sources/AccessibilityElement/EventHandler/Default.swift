//
//  Default.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct DefaultEventHandler<ObserverProvidingType> : EventHandler where ObserverProvidingType : ObserverProviding {
    public typealias ElementType = ObserverProvidingType.ElementType
    public var describerRequests: [DescriberRequest] {
        let requests: [DescriberRequest] = [
            Describer<ElementType>.Fallthrough(required: true, attributes: [.title, .description, .stringValue(nil), .titleElement(Describer<ElementType>.Fallthrough(required: true, attributes: [.title, .description, .stringValue(nil)]))]),
            Describer<ElementType>.Single(required: true, attribute: .roleDescription)
        ]
        return requests
    }
    public weak var _controller: Controller<DefaultEventHandler<ObserverProvidingType>>?
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
        do {
            let results = try Describer().describe(element: element, requests: describerRequests)
#if swift(>=4.1)
            return results.compactMap({ $0 }).joined(separator: ", ")
#else
            return results.flatMap({ $0 }).joined(separator: ", ")
#endif
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
