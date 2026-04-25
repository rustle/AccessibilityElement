//
//  NSAccessibility.ParameterizedAttribute.swift
//
//  Copyright © 2018-2021 Doug Russell. All rights reserved.
//

import AppKit

public extension NSAccessibility.ParameterizedAttribute {
    ///
    static let textMarkerRangeForUnorderedTextMarkers: NSAccessibility.ParameterizedAttribute = "AXTextMarkerRangeForUnorderedTextMarkers"
    ///
    static let stringForTextMarkerRange: NSAccessibility.ParameterizedAttribute = "AXStringForTextMarkerRange"
    ///
    static let attributedStringForTextMarkerRange: NSAccessibility.ParameterizedAttribute = "AXAttributedStringForTextMarkerRange"
    /// Returns the TextMarkerRange for the line containing the given TextMarker.
    static let lineForTextMarker: NSAccessibility.ParameterizedAttribute = "AXLineTextMarkerRangeForTextMarker"
    /// Returns the Int line number for a given TextMarker (distinct from lineForTextMarker).
    static let lineNumberForTextMarker: NSAccessibility.ParameterizedAttribute = "AXLineForTextMarker"

    // MARK: - Text marker navigation (TextMarker → TextMarker)

    static let nextTextMarkerForTextMarker: NSAccessibility.ParameterizedAttribute = "AXNextTextMarkerForTextMarker"
    static let previousTextMarkerForTextMarker: NSAccessibility.ParameterizedAttribute = "AXPreviousTextMarkerForTextMarker"
    static let nextWordEndTextMarkerForTextMarker: NSAccessibility.ParameterizedAttribute = "AXNextWordEndTextMarkerForTextMarker"
    static let previousWordStartTextMarkerForTextMarker: NSAccessibility.ParameterizedAttribute = "AXPreviousWordStartTextMarkerForTextMarker"
    static let nextLineEndTextMarkerForTextMarker: NSAccessibility.ParameterizedAttribute = "AXNextLineEndTextMarkerForTextMarker"
    static let previousLineStartTextMarkerForTextMarker: NSAccessibility.ParameterizedAttribute = "AXPreviousLineStartTextMarkerForTextMarker"
    static let nextSentenceEndTextMarkerForTextMarker: NSAccessibility.ParameterizedAttribute = "AXNextSentenceEndTextMarkerForTextMarker"
    static let previousSentenceStartTextMarkerForTextMarker: NSAccessibility.ParameterizedAttribute = "AXPreviousSentenceStartTextMarkerForTextMarker"
    static let nextParagraphEndTextMarkerForTextMarker: NSAccessibility.ParameterizedAttribute = "AXNextParagraphEndTextMarkerForTextMarker"
    static let previousParagraphStartTextMarkerForTextMarker: NSAccessibility.ParameterizedAttribute = "AXPreviousParagraphStartTextMarkerForTextMarker"

    // MARK: - Text marker range (TextMarker → TextMarkerRange)

    static let leftWordTextMarkerRangeForTextMarker: NSAccessibility.ParameterizedAttribute = "AXLeftWordTextMarkerRangeForTextMarker"
    static let rightWordTextMarkerRangeForTextMarker: NSAccessibility.ParameterizedAttribute = "AXRightWordTextMarkerRangeForTextMarker"
    static let leftLineTextMarkerRangeForTextMarker: NSAccessibility.ParameterizedAttribute = "AXLeftLineTextMarkerRangeForTextMarker"
    static let rightLineTextMarkerRangeForTextMarker: NSAccessibility.ParameterizedAttribute = "AXRightLineTextMarkerRangeForTextMarker"
    static let sentenceTextMarkerRangeForTextMarker: NSAccessibility.ParameterizedAttribute = "AXSentenceTextMarkerRangeForTextMarker"
    static let paragraphTextMarkerRangeForTextMarker: NSAccessibility.ParameterizedAttribute = "AXParagraphTextMarkerRangeForTextMarker"
    static let styleTextMarkerRangeForTextMarker: NSAccessibility.ParameterizedAttribute = "AXStyleTextMarkerRangeForTextMarker"

    // MARK: - TextMarker ↔ index / position

    /// Int character index for a given TextMarker.
    static let indexForTextMarker: NSAccessibility.ParameterizedAttribute = "AXIndexForTextMarker"
    /// TextMarker for a given Int character index.
    static let textMarkerForIndex: NSAccessibility.ParameterizedAttribute = "AXTextMarkerForIndex"
    /// TextMarker for a given CGPoint in screen coordinates.
    static let textMarkerForPosition: NSAccessibility.ParameterizedAttribute = "AXTextMarkerForPosition"
    /// TextMarkerRange for a given Int line number.
    static let textMarkerRangeForLine: NSAccessibility.ParameterizedAttribute = "AXTextMarkerRangeForLine"

    // MARK: - TextMarker ↔ bounds

    /// TextMarker at the start of the element intersecting the given NSRect.
    static let startTextMarkerForBounds: NSAccessibility.ParameterizedAttribute = "AXStartTextMarkerForBounds"
    /// TextMarker at the end of the element intersecting the given NSRect.
    static let endTextMarkerForBounds: NSAccessibility.ParameterizedAttribute = "AXEndTextMarkerForBounds"

    // MARK: - TextMarkerRange operations

    /// NSRect bounding box for a given TextMarkerRange.
    static let boundsForTextMarkerRange: NSAccessibility.ParameterizedAttribute = "AXBoundsForTextMarkerRange"
    /// Int character length of a given TextMarkerRange.
    static let lengthForTextMarkerRange: NSAccessibility.ParameterizedAttribute = "AXLengthForTextMarkerRange"

    // MARK: - UIElement ↔ TextMarkerRange

    /// UIElement at the position of a given TextMarker.
    static let uiElementForTextMarker: NSAccessibility.ParameterizedAttribute = "AXUIElementForTextMarker"
    /// TextMarkerRange covering the full extent of a given UIElement.
    static let textMarkerRangeForUIElement: NSAccessibility.ParameterizedAttribute = "AXTextMarkerRangeForUIElement"

    // MARK: - [TextMarker] → TextMarkerRange

    /// Ordered [start, end] TextMarkers → TextMarkerRange.
    static let textMarkerRangeForOrderedTextMarkers: NSAccessibility.ParameterizedAttribute = "AXTextMarkerRangeForTextMarkers"

    // MARK: - TextMarker validation

    static let textMarkerIsNull: NSAccessibility.ParameterizedAttribute = "AXTextMarkerIsNull"
    static let textMarkerIsValid: NSAccessibility.ParameterizedAttribute = "AXTextMarkerIsValid"
}

extension NSAccessibility.ParameterizedAttribute: @retroactive Codable {}

extension NSAccessibility.ParameterizedAttribute: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}
