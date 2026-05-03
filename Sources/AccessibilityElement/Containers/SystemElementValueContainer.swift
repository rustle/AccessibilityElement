//
//  SystemElementValueContainer.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AX
import CoreGraphics
import Foundation

public enum SystemElementValueContainer: Codable, Sendable {
    case int(Int)
    case double(Double)
    case bool(Bool)
    case string(String)
    case attributedString(SystemElementAttributedStringContainer)
    case element(SystemElement)
    case textMarker(TextMarker)
    case textMarkerRange(TextMarkerRange)
    case array([SystemElementValueContainer])
    case dictionary([String:SystemElementValueContainer])
    case point(CGPoint)
    case size(CGSize)
    case rect(CGRect)
    case range(Range<Int>)
    case error(AXError)
    case color(CodableCGColor)
    case url(URL)
    public func value() -> Any {
        switch self {
        case let .int(value):
            value
        case let .double(value):
            value
        case let .bool(value):
            value
        case let .string(value):
            value
        case let .attributedString(value):
            value.attributedString
        case let .element(value):
            value
        case let .textMarker(value):
            value
        case let .textMarkerRange(value):
            value
        case let .array(value):
            value
        case let .dictionary(value):
            value
        case let .point(value):
            value
        case let .size(value):
            value
        case let .rect(value):
            value
        case let .range(value):
            value
        case let .error(value):
            value
        case let .color(value):
            value
        case let .url(value):
            value
        }
    }

    public static func from(any value: Any) throws -> SystemElementValueContainer {
        try SystemElementValueRepackager.repackage(value: value)
    }
}
