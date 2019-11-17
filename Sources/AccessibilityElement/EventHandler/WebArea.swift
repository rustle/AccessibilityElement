//
//  WebArea.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Cocoa

public struct WebArea<ElementType: Element>: EventHandler {
    public var describerRequests: [DescriberRequest] {
        return []
    }
    public weak var _controller: Controller<WebArea<ElementType>>?
    public let _node: Node<ElementType>
    public let applicationObserver: ApplicationObserver<ElementType>
    private lazy var selectionChangeHandler: AnySelectionChangeHandler = {
        let handler: AnySelectionChangeHandler
        do {
            // See if this is a WebKit/Blink web area that uses AXTextMarker
            let _: Position<AXTextMarker> = try _node.element.first()
            handler = TextMarkerSelectionChangeHandler(element: _node._element,
                                                       applicationObserver: applicationObserver)
        } catch {
            handler = IntegerIndexSelectionChangeHandler(element: _node._element,
                                                         applicationObserver: applicationObserver)
        }
        if let applicationController = (_controller?.applicationController) as? Controller<Application<ElementType>> {
            handler.output = { [weak applicationController] payload in
                applicationController?._eventHandler.output?(payload)
            }
        }
        return handler
    }()
    public init(node: Node<ElementType>, applicationObserver: ApplicationObserver<ElementType>) {
        _node = node
        self.applicationObserver = applicationObserver
    }
    public mutating func connect() {
        do {
            _ = try _node._element.set(caretBrowsing: true)
        } catch {
            
        }
        do {
            try selectionChangeHandler.start()
        } catch {
            
        }
    }
    public mutating func focusIn() -> String? {
        return nil
    }
    public mutating func focusOut() -> String? {
        return nil
    }
    public mutating func disconnect() {
        selectionChangeHandler.stop()
    }
}
