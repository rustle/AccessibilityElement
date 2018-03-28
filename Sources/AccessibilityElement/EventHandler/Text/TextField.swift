//
//  TextField.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct TextField<ObserverProvidingType> : EventHandler where ObserverProvidingType : ObserverProviding {
    public typealias ElementType = ObserverProvidingType.ElementType
    public var describerRequests: [DescriberRequest] = {
        let requests: [DescriberRequest] = [
            Describer<ElementType>.Single(required: true, attribute: .stringValue(nil)),
        ]
        return requests
    }()
    public weak var _controller: Controller<TextField<ObserverProvidingType>>?
    public let _node: Node<ElementType>
    public let applicationObserver: ApplicationObserver<ObserverProvidingType>
    public init(node: Node<ElementType>, applicationObserver: ApplicationObserver<ObserverProvidingType>) {
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
#if swift(>=4.1)
        return results.compactMap({ $0 }).first
#else
        return results.flatMap({ $0 }).first
#endif
    }
    public mutating func focusOut() -> String? {
        return nil
    }
    public mutating func disconnect() {
        
    }
}
