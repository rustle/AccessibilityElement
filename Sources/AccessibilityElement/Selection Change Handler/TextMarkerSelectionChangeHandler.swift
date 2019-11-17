//
//  TextMarkerSelectionChangeHandler.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Cocoa
import Combine

public class TextMarkerSelectionChangeHandler<ElementType> : SelectionChangeHandler where ElementType : Element {
    public typealias IndexType = AXTextMarker
    public let element: ElementType
    public let applicationObserver: ApplicationObserver<ElementType>
    public var previousSelection: Range<Position<IndexType>>?
    private var selectionChange: AnyCancellable? {
        didSet {
            oldValue?.cancel()
        }
    }
    public var output: (([Output.Job.Payload]) -> Void)?
    public required init(element: ElementType,
                         applicationObserver: ApplicationObserver<ElementType>) {
        self.element = element
        self.applicationObserver = applicationObserver
    }
    public func start() throws {
        guard selectionChange == nil else {
            return
        }
        do {
            // Poke a WebKit only property to differentiate Blink from WebKit
            _ = try element.caretBrowsingEnabled()
            selectionChange = try applicationObserver
                .publisher(element: element,
                           notification: .selectedTextChanged)
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { [weak self] element, info in
                    guard let info = info else {
                        return
                    }
                    self?.handle(element: element,
                                 info: info)
                })
        } catch {
            do {
                let application = try type(of: element)
                    .application(processIdentifier: element.processIdentifier)
                selectionChange = try applicationObserver
                    .publisher(element: application,
                               notification: .selectedTextChanged)
                    .sink(receiveCompletion: { _ in
                        
                    }, receiveValue: { [weak self] element, info in
                        guard let info = info else {
                            return
                        }
                        self?.handle(element: element,
                                     info: info)
                    })
            } catch {
                throw error
            }
        }
    }
    public func stop() {
        selectionChange?.cancel()
        selectionChange = nil
    }
    public func rangeForMove(previousSelection: Range<Position<IndexType>>,
                             selection: Range<Position<IndexType>>,
                             direction: Navigation<IndexType>.Direction,
                             granularity: Navigation<IndexType>.Granularity) throws -> Range<Position<IndexType>> {
        return try element.range(unorderedPositions: (previousSelection.lowerBound, selection.lowerBound))
    }
    private func handle(element: ElementType,
                        info: ElementNotificationInfo) {
        do {
            guard let selectionChange = try SelectionChangeForTextMarkerChangeNotification(info: info,
                                                                                           element: element) else {
                return
            }
            self.handle(selectionChange: selectionChange)
        } catch {
            
        }
    }
}
