//
//  NSAccessibility.Attribute.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Cocoa

public extension NSAccessibility.Attribute {
    /// Attribute representing caret browsing preference. Appropriate for use with a WebKit web area element.
    static let caretBrowsingEnabled = NSAccessibility.Attribute(rawValue: "AXCaretBrowsingEnabled")
    /// Attribute representing system focused application. Only valid on system wide element.
    static let focusedApplication = NSAccessibility.Attribute(rawValue: "AXFocusedApplication")
    /// Rectangle representing element, in screen coordinates.
    static let frame = NSAccessibility.Attribute(rawValue: "AXFrame")
    /// Attribute representing selected positions range. Appropriate for use with a web area element or it's descendants.
    static let selectedTextMarkerRange = NSAccessibility.Attribute(rawValue: "AXSelectedTextMarkerRange")
    /// Appropropriate for use with an appllication element.
    static let enhancedUserInterface = NSAccessibility.Attribute(rawValue: "AXEnhancedUserInterface")
    /// Attribute representing first position in web area (or containing web area). Appropriate for use with a web area element or it's descendants.
    static let startTextMarker = NSAccessibility.Attribute(rawValue: "AXStartTextMarker")
    /// Attribute representing last position in web area (or containing web area). Appropriate for use with a web area element or it's descendants.
    static let endTextMarker = NSAccessibility.Attribute(rawValue: "AXEndTextMarker")
}

extension NSAccessibility.Attribute: Codable {}
