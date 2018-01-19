//
//  Position.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public typealias AXTextMarker = CFTypeRef
public typealias AXTextMarkerRange = CFTypeRef

public protocol AnyPosition : Comparable {
    
}

public struct Position<IndexType> : AnyPosition {
    public var index: IndexType
    public var element: AnyElement
    public init(index: IndexType, element: AnyElement) {
        self.index = index
        self.element = element
    }
    public static func <(lhs: Position<IndexType>, rhs: Position<IndexType>) -> Bool {
        fatalError()
    }
    public static func >(lhs: Position<IndexType>, rhs: Position<IndexType>) -> Bool {
        fatalError()
    }
    public static func ==(lhs: Position<IndexType>, rhs: Position<IndexType>) -> Bool {
        fatalError()
    }
}

public extension Position where IndexType == AXTextMarker {
    public static func <(lhs: Position<AXTextMarker>, rhs: Position<AXTextMarker>) -> Bool {
        do {
            let range = try lhs.element.range(unorderedPositions: (lhs, rhs))
            if range.lowerBound == range.upperBound {
                return false
            }
            return range.lowerBound == lhs
        } catch {
            return false
        }
    }
    public static func >(lhs: Position<AXTextMarker>, rhs: Position<AXTextMarker>) -> Bool {
        do {
            let range = try lhs.element.range(unorderedPositions: (lhs, rhs))
            if range.lowerBound == range.upperBound {
                return false
            }
            return range.upperBound == lhs
        } catch {
            return false
        }
    }
    public static func ==(lhs: Position<AXTextMarker>, rhs: Position<AXTextMarker>) -> Bool {
        return CFEqual(lhs.index, rhs.index)
    }
}

public extension Position where IndexType == Int {
    public static func <(lhs: Position<Int>, rhs: Position<Int>) -> Bool {
        return lhs < rhs
    }
    public static func >(lhs: Position<Int>, rhs: Position<Int>) -> Bool {
        return lhs > rhs
    }
    public static func ==(lhs: Position<Int>, rhs: Position<Int>) -> Bool {
        return lhs == rhs
    }
}

public extension Range where Bound == Position<AXTextMarker> {
    init?(_ axTextMarkerRange: AXTextMarkerRange, element: AnyElement) {
        guard CFGetTypeID(axTextMarkerRange as CFTypeRef) == accessibility_element_get_marker_range_type_id() else {
            return nil
        }
        var lowerBound: Position<AXTextMarker>?
        var upperBound: Position<AXTextMarker>?
        if let start = accessibility_element_copy_start_marker(axTextMarkerRange as CFTypeRef) {
            lowerBound = Position(index: start.takeRetainedValue() as AXTextMarker, element: element)
        }
        if let end = accessibility_element_copy_end_marker(axTextMarkerRange as CFTypeRef) {
            upperBound = Position(index: end.takeRetainedValue() as AXTextMarker, element: element)
        }
        guard let l = lowerBound, let u = upperBound else {
            return nil
        }
        self = Range(uncheckedBounds: (l, u))
    }
    public var axTextMarkerRange: AXTextMarkerRange? {
        return accessibility_element_create_marker_range(lowerBound.index, upperBound.index)?.takeRetainedValue()
    }
}
