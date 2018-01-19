//
//  WebArea.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import os.log

public struct WebArea<ElementType> : EventHandler where ElementType : _Element {
    public var describerRequests: [DescriberRequest] {
        return []
    }
    public weak var _controller: Controller<ElementType, WebArea<ElementType>>?
    public let _node: Node<ElementType>
    public init(node: Node<ElementType>) {
        _node = node
    }
    public mutating func connect() {
        _ = try? _node._element.set(caretBrowsing: true)
        registerObservers()
    }
    public mutating func focusIn() -> String? {
        return nil
    }
    public mutating func focusOut() -> String? {
        return nil
    }
    public mutating func disconnect() {
        unregisterObservers()
    }
    var observer: ApplicationObserver?
    var valueChangeToken: ApplicationObserver.Token?
    var selectionChangeToken: ApplicationObserver.Token?
    private mutating func registerObservers() {
        guard let controller = _controller else {
            return
        }
        guard let element = controller.eventHandler.node.element as? Element else {
            return
        }
        guard let applicationElement = controller.applicationController?.eventHandler.node.element as? Element else {
            return
        }
        if observer == nil {
            do {
                observer = try ObserverManager.shared.registerObserver(application: applicationElement)
            } catch {
                return
            }
        }
        guard let observer = observer else {
            return
        }
        do {
            valueChangeToken = try observer.startObserving(element: element,
                                                           notification: .valueChanged,
                                                           root: controller,
                                                           keyPath: \Controller._eventHandler) { element, eventHandler, info in
                _ = eventHandler.valueChanged()
            }
        } catch {
            
        }
        do {
            selectionChangeToken = try observer.startObserving(element: element,
                                                               notification: .selectedTextChanged,
                                                               root: controller,
                                                               keyPath: \Controller._eventHandler) { element, eventHandler, info in
                guard let info = info else {
                    return
                }
                let element = controller.eventHandler.node.element
                guard let selectionChange = SelectionChange(info: info, element: element) else {
                    return
                }
                eventHandler.handle(selectionChange: selectionChange)
            }
        } catch {
            
        }
    }
    private mutating func unregisterObservers() {
        guard let observer = observer else {
            return
        }
        if let token = valueChangeToken {
            do {
                try observer.stopObserving(token: token)
                valueChangeToken = nil
            } catch {
                return
            }
        }
    }
    private var previousSelection: Range<Position<AXTextMarker>>?
    private func echo<IndexType>(range: Range<Position<IndexType>>) {
        do {
            let value = try _node._element.attributedString(range: range)
            guard let applicationController = (_controller?.applicationController) as? Controller<Element, Application<Element>> else {
                return
            }
            applicationController._eventHandler.output?(value.string)
        } catch {
            return
        }
    }
    private func rangeForMove<IndexType>(previousSelection: Range<Position<IndexType>>,
                                         selection: Range<Position<IndexType>>,
                                         direction: Navigation.Direction) throws -> Range<Position<IndexType>> {
        switch direction {
        case .beginning:
            fatalError()
        case .end:
            fatalError()
        case .previous:
            return try _node._element.range(unorderedPositions: (previousSelection.lowerBound, selection.lowerBound))
        case .next:
            return try _node._element.range(unorderedPositions: (selection.lowerBound, previousSelection.lowerBound))
        case .discontiguous:
            fatalError()
        }
    }
    private mutating func move(navigation: Navigation) {
        guard let previousSelection = previousSelection else {
            self.previousSelection = navigation.selection
            return
        }
        guard let selection = navigation.selection else {
            return
        }
        do {
            echo(range: try rangeForMove(previousSelection: previousSelection,
                                         selection: selection,
                                         direction: navigation.direction))
        } catch {
            
        }
        self.previousSelection = selection
    }
    private mutating func handle(selectionChange: SelectionChange) {
        switch selectionChange {
        case .edit(_):
            break
        case .move(let navigation):
            move(navigation: navigation)
        case .extend(_):
            break
        case .boundary(_):
            break
        }
    }
}
