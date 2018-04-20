//
//  NSAccessibilityAttributeName.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa

public extension NSAccessibilityAttributeName {
    /// Attribute representing caret browsing preference. Appropriate for use with a WebKit web area element.
    public static let caretBrowsingEnabled = NSAccessibilityAttributeName(rawValue: "AXCaretBrowsingEnabled")
    /// Attribute representing system focused application. Only valid on system wide element.
    public static let focusedApplication = NSAccessibilityAttributeName(rawValue: "AXFocusedApplication")
    /// Rectangle representing element, in screen coordinates.
    public static let frame = NSAccessibilityAttributeName(rawValue: "AXFrame")
    /// Attribute representing selected positions range. Appropriate for use with a web area element or it's descendants.
    public static let selectedTextMarkerRange = NSAccessibilityAttributeName(rawValue: "AXSelectedTextMarkerRange")
    /// Appropropriate for use with an appllication element.
    public static let enhancedUserInterface = NSAccessibilityAttributeName(rawValue: "AXEnhancedUserInterface")
    /// Attribute representing first position in web area (or containing web area). Appropriate for use with a web area element or it's descendants.
    public static let startTextMarker = NSAccessibilityAttributeName(rawValue: "AXStartTextMarker")
    /// Attribute representing last position in web area (or containing web area). Appropriate for use with a web area element or it's descendants.
    public static let endTextMarker = NSAccessibilityAttributeName(rawValue: "AXEndTextMarker")
}
