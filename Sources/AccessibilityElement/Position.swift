//
//  Position.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public typealias AXTextMarker = CFTypeRef
public typealias AXTextMarkerRange = CFTypeRef

public protocol AnyPosition : Comparable {}

public struct Position<IndexType> : AnyPosition {
    public var index: IndexType
    public var element: AnyElement
    public init(index: IndexType,
                element: AnyElement) {
        self.index = index
        self.element = element
    }
    public static func <(lhs: Position<IndexType>,
                         rhs: Position<IndexType>) -> Bool {
        if IndexType.self == Int.self {
            return (lhs as! Position<Int>).index < (rhs as! Position<Int>).index
        } else if CFGetTypeID(lhs.index as CFTypeRef) == accessibility_element_get_marker_type_id() {
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
        fatalError()
    }
    public static func >(lhs: Position<IndexType>,
                         rhs: Position<IndexType>) -> Bool {
        if IndexType.self == Int.self {
            return (lhs as! Position<Int>).index > (rhs as! Position<Int>).index
        } else if CFGetTypeID(lhs.index as CFTypeRef) != accessibility_element_get_marker_type_id() {
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
        fatalError()
    }
    public static func ==(lhs: Position<IndexType>,
                          rhs: Position<IndexType>) -> Bool {
        if IndexType.self == Int.self {
            return (lhs as! Position<Int>).index == (rhs as! Position<Int>).index
        } else if IndexType.self == AXTextMarker.self {
            return CFEqual(lhs.index as CFTypeRef, rhs.index as CFTypeRef)
        }
        fatalError()
    }
}

extension Position : Codable where IndexType : Codable {
    public enum CodingKeys : String, CodingKey {
        case index
        case element
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(index,
                             forKey: .index)
        if let systemElement = element as? SystemElement {
            try container.encode(systemElement.element.transportRepresentation(),
                                 forKey: .element)
        } else {
            fatalError()
        }
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        index = try values.decode(IndexType.self, forKey: .index)
        if let transportRepresentation = try values.decodeIfPresent(Data.self,
                                                                    forKey: .element) {
            element = SystemElement(element: AXUIElement.element(transportRepresentation: transportRepresentation))
        } else {
            fatalError()
        }
    }
}

extension Position : CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(index)"
    }
}

public extension Range where Bound == Position<AXTextMarker> {
    init(_ axTextMarkerRange: AXTextMarkerRange,
         element: AnyElement) {
        guard CFGetTypeID(axTextMarkerRange as CFTypeRef) == accessibility_element_get_marker_range_type_id() else {
            fatalError()
        }
        let start = accessibility_element_copy_start_marker(axTextMarkerRange as CFTypeRef)
        let lowerBound = Position(index: start as AXTextMarker, element: element)
        let end = accessibility_element_copy_end_marker(axTextMarkerRange as CFTypeRef)
        let upperBound = Position(index: end as AXTextMarker, element: element)
        self = Range(uncheckedBounds: (lowerBound, upperBound))
    }
    var axTextMarkerRange: AXTextMarkerRange? {
        return accessibility_element_create_marker_range(lowerBound.index, upperBound.index)
    }
}
