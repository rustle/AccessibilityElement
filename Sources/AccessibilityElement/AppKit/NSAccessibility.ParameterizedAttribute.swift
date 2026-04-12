//
//  NSAccessibility.ParameterizedAttribute.swift
//
//  Copyright © 2018-2021 Doug Russell. All rights reserved.
//

import AppKit

public extension NSAccessibility.ParameterizedAttribute {
    static let textMarkerRangeForUnorderedTextMarkers: NSAccessibility.ParameterizedAttribute = "AXTextMarkerRangeForUnorderedTextMarkers"
    static let stringForTextMarkerRange: NSAccessibility.ParameterizedAttribute = "AXStringForTextMarkerRange"
    static let attributedStringForTextMarkerRange: NSAccessibility.ParameterizedAttribute = "AXAttributedStringForTextMarkerRange"
    static let lineForTextMarker: NSAccessibility.ParameterizedAttribute = "AXLineTextMarkerRangeForTextMarker"
}

extension NSAccessibility.ParameterizedAttribute: @retroactive Codable {}

extension NSAccessibility.ParameterizedAttribute: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}
