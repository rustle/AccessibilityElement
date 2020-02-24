//
//  NSAccessibility.ParameterizedAttribute.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Cocoa

public extension NSAccessibility.ParameterizedAttribute {
    static let textMarkerRangeForUnorderedTextMarkers = NSAccessibility.ParameterizedAttribute(rawValue: "AXTextMarkerRangeForUnorderedTextMarkers")
    static let stringForTextMarkerRange = NSAccessibility.ParameterizedAttribute(rawValue: "AXStringForTextMarkerRange")
    static let attributedStringForTextMarkerRange = NSAccessibility.ParameterizedAttribute(rawValue: "AXAttributedStringForTextMarkerRange")
}

extension NSAccessibility.ParameterizedAttribute: Codable {}
