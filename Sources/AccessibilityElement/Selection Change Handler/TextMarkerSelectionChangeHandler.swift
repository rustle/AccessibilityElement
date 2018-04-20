//
//  TextMarkerSelectionChangeHandler.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa
import Signals

public class TextMarkerSelectionChangeHandler<ElementType> : SelectionChangeHandler where ElementType : Element {
    public typealias IndexType = AXTextMarker
    public let element: ElementType
    public let applicationObserver: ApplicationObserver<ElementType>
    public var previousSelection: Range<Position<IndexType>>?
    private var selectionChangeSubscription: Subscription<(element: ElementType, info: ObserverInfo?)>?
    public var output: (([Output.Job.Payload]) -> Void)?
    public required init(element: ElementType,
                         applicationObserver: ApplicationObserver<ElementType>) {
        self.element = element
        self.applicationObserver = applicationObserver
    }
    public func start() throws {
        guard selectionChangeSubscription == nil else {
            return
        }
        let signal: ObserverSignal<ElementType>
        do {
            // Poke a WebKit only property to differentiate Blink from WebKit
            _ = try element.caretBrowsingEnabled()
            signal = try applicationObserver.signal(element: element, notification: .selectedTextChanged)
        } catch {
            do {
                let application = try type(of: element).application(processIdentifier: element.processIdentifier)
                signal = try applicationObserver.signal(element: application, notification: .selectedTextChanged)
            } catch {
                throw error
            }
        }
        selectionChangeSubscription = signal.subscribe { [weak self] element, info in
            do {
                guard let selectionChange = try SelectionChangeForTextMarkerChangeNotification(info: info, element: element) else {
                    return
                }
                self?.handle(selectionChange: selectionChange)
            } catch {
                
            }
        }
    }
    public func stop() {
        selectionChangeSubscription?.cancel()
        selectionChangeSubscription = nil
    }
    public func rangeForMove(previousSelection: Range<Position<IndexType>>,
                             selection: Range<Position<IndexType>>,
                             direction: Navigation<IndexType>.Direction,
                             granularity: Navigation<IndexType>.Granularity) throws -> Range<Position<IndexType>> {
        return try element.range(unorderedPositions: (previousSelection.lowerBound, selection.lowerBound))
    }
}
