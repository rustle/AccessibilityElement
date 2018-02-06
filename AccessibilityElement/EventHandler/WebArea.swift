//
//  WebArea.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import Signals

public struct WebArea<ObserverProvidingType> : EventHandler where ObserverProvidingType : ObserverProviding, ObserverProvidingType.ElementType : _Element {
    public typealias ElementType = ObserverProvidingType.ElementType
    public var describerRequests: [DescriberRequest] {
        return []
    }
    public weak var _controller: Controller<ElementType, WebArea<ObserverProvidingType>>?
    public let _node: Node<ElementType>
    public let observerManager: ObserverManager<ObserverProvidingType>
    public init(node: Node<ElementType>, observerManager: ObserverManager<ObserverProvidingType>) {
        _node = node
        self.observerManager = observerManager
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
    private var selectionChangeSignal: SignalSubscription<(element: ElementType, info: ObserverInfo?)>?
    private mutating func registerObservers() {
        guard let applicationController = (_controller?.applicationController) as? Controller<Element, Application<ObserverProvidingType>> else {
            return
        }
        guard let (controller, _, observer) = try? applicationController._eventHandler.observerContext() else {
            return
        }
        func registerSelectionChange() throws {
            guard selectionChangeSignal == nil else {
                return
            }
//            selectionChangeSignal = try observer.signal(element: element, notification: .selectedTextChanged).subscribe { [weak controller] element, info in
//                guard let info = info, let controller = controller else {
//                    return
//                }
//                let element = controller._eventHandler._node.element
//                guard let selectionChange = SelectionChange(info: info, element: element) else {
//                    return
//                }
//                controller._eventHandler.handle(selectionChange: selectionChange)
//            }
        }
        try? registerSelectionChange()
    }
    private mutating func unregisterObservers() {
        selectionChangeSignal?.cancel()
        selectionChangeSignal = nil
    }
    private var previousSelection: Range<Position<AXTextMarker>>?
    private func echo<IndexType>(range: Range<Position<IndexType>>) {
        do {
            let value = try _node._element.attributedString(range: range)
            guard let applicationController = (_controller?.applicationController) as? Controller<ElementType, Application<ObserverProvidingType>> else {
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
