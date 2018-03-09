//
//  Window.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct Window<ObserverProvidingType> : EventHandler where ObserverProvidingType : ObserverProviding {
    public typealias ElementType = ObserverProvidingType.ElementType
    public var describerRequests: [DescriberRequest] {
        return [
            Describer<ElementType>.Single(required: false, attribute: .title),
            Describer<ElementType>.Single(required: false, attribute: .roleDescription),
        ]
    }
    public weak var _controller: Controller<Window<ObserverProvidingType>>?
    public let _node: Node<ElementType>
    public let applicationObserver: ApplicationObserver<ObserverProvidingType>
    public init(node: Node<ElementType>, applicationObserver: ApplicationObserver<ObserverProvidingType>) {
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