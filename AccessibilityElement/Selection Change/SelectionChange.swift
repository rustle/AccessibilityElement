//
//  SelectionChange.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public enum SelectionChange<IndexType> {
    case edit(Edit)
    case move(Navigation<IndexType>)
    case extend(Navigation<IndexType>)
    case boundary(Navigation<IndexType>)
}

public enum Edit {
    case delete // Generic text delete
    case insert // Generic text insert
    case typing // Insert via typing
    case dictation // Insert via dictation
    case cut // Delete via Cut
    case paste // Insert via Paste
    case attributesChange // Change font, style, alignment, color, etc.
}

public struct Navigation<IndexType> {
    public enum Direction {
        case beginning
        case end
        case previous
        case next
        case discontiguous
    }
    public enum Granularity {
        case unknown
        case character
        case word
        case line
        case sentence
        case paragraph
        case page
        case document
        case all // All granularity represents the action of selecting the whole document as a single action. Extending selection by some other granularity until it encompasses the whole document will not result in a all granularity notification.
    }
    public var element: AnyElement?
    public var selection: Range<Position<IndexType>>?
    public var direction: Direction
    public var granularity: Granularity
    public var focusChanged: Bool
    public var sync: Bool
}
