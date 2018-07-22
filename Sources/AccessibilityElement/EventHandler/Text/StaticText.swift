//
//  StaticText.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct StaticText<ElementType> : EventHandler where ElementType : Element {
    public typealias ObserverProvidingType = ElementType.ObserverProvidingType
    public var describerRequests: [DescriberRequest] = {
        let requests: [DescriberRequest] = [
            Describer<ElementType>.Single(required: true, attribute: .stringValue(nil))
        ]
        return requests
    }()
    public weak var _controller: Controller<StaticText<ElementType>>?
    public let _node: Node<ElementType>
    public let applicationObserver: ApplicationObserver<ElementType>
    public init(node: Node<ElementType>,
                applicationObserver: ApplicationObserver<ElementType>) {
        _node = node
        self.applicationObserver = applicationObserver
    }
    public func connect() {
        
    }
    public mutating func focusIn() -> String? {
        let element = _node._element
        guard let results: [String?] = try? Describer<ElementType>().describe(element: element, requests: describerRequests) else {
            return nil
        }
        return results.compactMap({ $0 }).joined(separator: "")
    }
    public func focusOut() -> String? {
        return nil
    }
    public func disconnect() {
        
    }
}
