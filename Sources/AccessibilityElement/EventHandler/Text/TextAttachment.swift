//
//  TextAttachment.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct TextAttachment<ElementType> : EventHandler where ElementType : _Element {
    public typealias ObserverProvidingType = ElementType.ObserverProvidingType
    public var describerRequests: [DescriberRequest] = {
        let requests: [DescriberRequest] = [
            Describer<ElementType>.Single(required: true, attribute: .attachmentText),
        ]
        return requests
    }()
    public weak var _controller: Controller<TextAttachment<ElementType>>?
    public let _node: Node<ElementType>
    public let applicationObserver: ApplicationObserver<ElementType>
    public init(node: Node<ElementType>,
                applicationObserver: ApplicationObserver<ElementType>) {
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
#if swift(>=4.1)
        return results.compactMap({ $0 }).first
#else
        return results.flatMap({ $0 }).first
#endif
    }
    public func focusOut() -> String? {
        return nil
    }
    public func disconnect() {
        
    }
}
