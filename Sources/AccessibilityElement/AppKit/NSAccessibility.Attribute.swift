//
//  NSAccessibility.Attribute.swift
//
//  Copyright © 2018-2021 Doug Russell. All rights reserved.
//

import AppKit

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
    // MARK: Web area
    static let loaded: NSAccessibility.Attribute = "AXLoaded"
    static let loadingProgress: NSAccessibility.Attribute = "AXLoadingProgress"
    static let layoutCount: NSAccessibility.Attribute = "AXLayoutCount"
    static let preventKeyboardDOMEventDispatch: NSAccessibility.Attribute = "AXPreventKeyboardDOMEventDispatch"
    // MARK: Ancestor navigation
    static let focusableAncestor: NSAccessibility.Attribute = "AXFocusableAncestor"
    static let editableAncestor: NSAccessibility.Attribute = "AXEditableAncestor"
    static let highestEditableAncestor: NSAccessibility.Attribute = "AXHighestEditableAncestor"
    // MARK: MathML
    static let mathBase: NSAccessibility.Attribute = "AXMathBase"
    static let mathFencedOpen: NSAccessibility.Attribute = "AXMathFencedOpen"
    static let mathFencedClose: NSAccessibility.Attribute = "AXMathFencedClose"
    static let mathFractionNumerator: NSAccessibility.Attribute = "AXMathFractionNumerator"
    static let mathFractionDenominator: NSAccessibility.Attribute = "AXMathFractionDenominator"
    static let mathLineThickness: NSAccessibility.Attribute = "AXMathLineThickness"
    static let mathOver: NSAccessibility.Attribute = "AXMathOver"
    static let mathUnder: NSAccessibility.Attribute = "AXMathUnder"
    static let mathPostscripts: NSAccessibility.Attribute = "AXMathPostscripts"
    static let mathPrescripts: NSAccessibility.Attribute = "AXMathPrescripts"
    static let mathRootIndex: NSAccessibility.Attribute = "AXMathRootIndex"
    static let mathRootRadicand: NSAccessibility.Attribute = "AXMathRootRadicand"
    static let mathSubscript: NSAccessibility.Attribute = "AXMathSubscript"
    static let mathSuperscript: NSAccessibility.Attribute = "AXMathSuperscript"
}

extension NSAccessibility.Attribute: @retroactive Codable {}

extension NSAccessibility.Attribute: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}
