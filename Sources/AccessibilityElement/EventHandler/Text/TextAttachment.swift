//
//  TextAttachment.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct TextAttachment<ObserverProvidingType> : EventHandler where ObserverProvidingType : ObserverProviding {
    public typealias ElementType = ObserverProvidingType.ElementType
    public var describerRequests: [DescriberRequest] = {
        let requests: [DescriberRequest] = [
            Describer<ElementType>.Single(required: true, attribute: .attachmentText),
        ]
        return requests
    }()
    public weak var _controller: Controller<TextAttachment<ObserverProvidingType>>?
    public let _node: Node<ElementType>
    public let applicationObserver: ApplicationObserver<ObserverProvidingType>
    public init(node: Node<ElementType>, applicationObserver: ApplicationObserver<ObserverProvidingType>) {
        _node = node
        self.applicationObserver = applicationObserver
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
