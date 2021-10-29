//
//  NSAccessibility.ParameterizedAttribute.swift
//
//  Copyright © 2018-2021 Doug Russell. All rights reserved.
//

import Cocoa

public extension NSAccessibility.ParameterizedAttribute {
    static let textMarkerRangeForUnorderedTextMarkers: NSAccessibility.ParameterizedAttribute = "AXTextMarkerRangeForUnorderedTextMarkers"
    static let stringForTextMarkerRange: NSAccessibility.ParameterizedAttribute = "AXStringForTextMarkerRange"
    static let attributedStringForTextMarkerRange: NSAccessibility.ParameterizedAttribute = "AXAttributedStringForTextMarkerRange"
}

extension NSAccessibility.ParameterizedAttribute: Codable {}

extension NSAccessibility.ParameterizedAttribute: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}
