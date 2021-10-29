//
//  NSAccessibility.Attribute.swift
//
//  Copyright © 2018-2021 Doug Russell. All rights reserved.
//

import Cocoa

public extension NSAccessibility.Attribute {
    /// Attribute representing caret browsing preference.
    /// Appropriate for use with a WebKit web area element.
    static let caretBrowsingEnabled: NSAccessibility.Attribute = "AXCaretBrowsingEnabled"
    /// Attribute representing system focused application.
    /// Only valid on system wide element.
    static let focusedApplication: NSAccessibility.Attribute = "AXFocusedApplication"
    /// Rectangle representing element, in screen coordinates.
    static let frame: NSAccessibility.Attribute = "AXFrame"
    /// Attribute representing selected positions range.
    /// Appropriate for use with a web area element or it's descendants.
    static let selectedTextMarkerRange: NSAccessibility.Attribute = "AXSelectedTextMarkerRange"
    /// Appropropriate for use with an appllication element.
    static let enhancedUserInterface: NSAccessibility.Attribute = "AXEnhancedUserInterface"
    /// Attribute representing first position in web area (or containing web area).
    /// Appropriate for use with a web area element or it's descendants.
    static let startTextMarker: NSAccessibility.Attribute = "AXStartTextMarker"
    /// Attribute representing last position in web area (or containing web area).
    /// Appropriate for use with a web area element or it's descendants.
    static let endTextMarker: NSAccessibility.Attribute = "AXEndTextMarker"
}

extension NSAccessibility.Attribute: Codable {}

extension NSAccessibility.Attribute: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}
