//
//  SelectionChangeHandler.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa

public protocol AnySelectionChangeHandler : class {
    var output: (([Output.Job.Payload]) -> Void)? { get set }
    func start() throws
    func stop()
}

public protocol SelectionChangeHandler : AnySelectionChangeHandler {
    associatedtype ElementType where ElementType : Element
    associatedtype IndexType
    var element: ElementType { get }
    var previousSelection: Range<Position<IndexType>>? { get set }
    func handle(selectionChange: SelectionChange<IndexType>)
    func move(navigation: Navigation<IndexType>)
    func rangeForMove(previousSelection: Range<Position<IndexType>>,
                      selection: Range<Position<IndexType>>,
                      direction: Navigation<IndexType>.Direction,
                      granularity: Navigation<IndexType>.Granularity) throws -> Range<Position<IndexType>>
    init(element: ElementType,
         applicationObserver: ApplicationObserver<ElementType>)
}

public extension SelectionChangeHandler {
    public func handle(selectionChange: SelectionChange<IndexType>) {
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
    public func move(navigation: Navigation<IndexType>) {
        guard let previousSelection = previousSelection else {
            self.previousSelection = navigation.selection
            return
        }
        guard let selection = navigation.selection else {
            return
        }
        if previousSelection == selection {
            return
        }
        do {
            let range: Range<Position<IndexType>>
            if let direction = navigation.direction, let granularity = navigation.granularity {
                range = try rangeForMove(previousSelection: previousSelection,
                                         selection: selection,
                                         direction: direction,
                                         granularity: granularity)
            } else {
                range = try element.range(unorderedPositions: (previousSelection.lowerBound, selection.lowerBound))
            }
            echo(range: range)
        } catch {
            
        }
        self.previousSelection = selection
    }
    public func rangeForMove(previousSelection: Range<Position<IndexType>>,
                             selection: Range<Position<IndexType>>,
                             direction: Navigation<IndexType>.Direction,
                             granularity: Navigation<IndexType>.Granularity) throws -> Range<Position<IndexType>> {
        return try element.range(unorderedPositions: (previousSelection.lowerBound, selection.lowerBound))
    }
    public func echo(range: Range<Position<IndexType>>) {
        do {
            let value = try element.attributedString(range: range)
            output?([.speech(value.string, nil)])
        } catch {
            
        }
    }
}
