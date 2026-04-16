//
//  Element.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AppKit
import AX

public protocol Element: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    /// The element's role. Non-localized string that identifies the type of element. (e.g. radioButton)
    @Sendable
    func role() throws -> NSAccessibility.Role
    /// Localized string that describes the element's role. (e.g. "radio button")
    @Sendable
    func roleDescription() throws -> String
    /// The element's subrole. Non-localized string that further categorizes the element's role. (e.g. closeButton)
    @Sendable
    func subrole() throws -> NSAccessibility.Subrole
    /// The element's value.
    @Sendable
    func value() throws -> Any
    /// Visible text displayed for the element. (e.g. a push button's label)
    @Sendable
    func title() throws -> String
    /// The UI element that serves as the title for this element.
    @Sendable
    func titleUIElement() throws -> Self
    /// The process identifier of the application that owns this element.
    var processIdentifier: pid_t { get throws }
    /// The application's windows.
    @Sendable
    func windows() throws -> [Self]
    /// The application's main window.
    @Sendable
    func mainWindow() throws -> Self
    /// The application's key window.
    @Sendable
    func focusedWindow() throws -> Self
    /// The currently focused UI element.
    @Sendable
    func focusedUIElement() throws -> Self
    /// The element that contains this element.
    @Sendable
    func parent() throws -> Self
    /// The elements contained by this element.
    @Sendable
    func children() throws -> [Self]
    /// The child elements ordered for navigation.
    @Sendable
    func childrenInNavigationOrder() throws -> [Self]
    /// The child elements that are currently visible.
    @Sendable
    func visibleChildren() throws -> [Self]
    /// The child elements that are currently selected.
    @Sendable
    func selectedChildren() throws -> [Self]
    /// The rows of a table or outline.
    @Sendable
    func rows() throws -> [Self]
    /// The columns of a table.
    @Sendable
    func columns() throws -> [Self]
    /// The rows that are currently selected.
    @Sendable
    func selectedRows() throws -> [Self]
    /// The columns that are currently selected.
    @Sendable
    func selectedColumns() throws -> [Self]
    /// The cells that are currently selected.
    @Sendable
    func selectedCells() throws -> [Self]
    /// Whether the enhanced user interface is enabled. Only valid on an application element.
    @Sendable
    func enhancedUserInterface() throws -> Bool
    /// Enable or disable the enhanced user interface. Only valid on an application element.
    @Sendable
    func setEnhancedUserInterface(_ enhancedUserInterface: Bool) throws
    /// The actions the element supports.
    @Sendable
    func actions() throws -> [NSAccessibility.Action]
    /// A localized description of the specified action.
    @Sendable
    func description(action: NSAccessibility.Action) throws -> String
    /// Perform the specified action.
    @Sendable
    func perform(action: NSAccessibility.Action) throws
    /// The line number of the specified character.
    @Sendable
    func line(forIndex index: Int) throws -> Int
    /// The line number of the specified marker.
    @Sendable
    func line(forTextMarker textMarker: TextMarker) throws -> Int
    /// The range of characters corresponding to the specified line number.
    @Sendable
    func range(forLine line: Int) throws -> Range<Int>
    /// The full range of characters, including the specified character, which compose a single glyph.
    @Sendable
    func range(forIndex index: Int) throws -> Range<Int>
    /// The range of characters composing the glyph at the specified point.
    @Sendable
    func range(forPosition position: Int) throws -> Range<Int>
    /// The string specified by the range.
    @Sendable
    func string(for range: Range<Int>) throws -> String
    /// The rectangle enclosing the specified range of characters.
    /// If the range crosses a line boundary, the returned rectangle will fully enclose all the lines of characters.
    @Sendable
    func bounds(for range: Range<Int>) throws -> NSRect
    /// The RTF data describing the specified range of characters.
    @Sendable
    func rtf(for range: Range<Int>) throws -> Data
    /// The attributed string for the specified range. Does not use attributes from AppKit/AttributedString.h.
    @Sendable
    func attributedString(for range: Range<Int>) throws -> NSAttributedString
    /// The full range of characters, including the specified character, which have the same style.
    @Sendable
    func styleRange(for index: Int) throws -> Range<Int>
    /// The cell element at the specified column and row indices.
    @Sendable
    func cell(
        column: Int,
        row: Int
    ) throws -> SystemElement
    /// The line number that contains the insertion point (caret).
    @Sendable
    func insertionPointLineNumber() throws -> Int
    /// The portion of shared text storage that belongs to this element.
    @Sendable
    func sharedCharacterRange() throws -> Range<Int>
    /// Text elements that share the same text storage as this element.
    @Sendable
    func sharedTextUIElements() throws -> [Self]
    /// The range of characters currently visible in the element.
    @Sendable
    func visibleCharacterRange() throws -> Range<Int>
    /// The total number of characters in the element.
    @Sendable
    func numberOfCharacters() throws -> Int
    /// The currently selected text.
    @Sendable
    func selectedText() throws -> String
    /// The range of the currently selected text.
    @Sendable
    func selectedTextRange() throws -> Range<Int>
    /// The ranges of all currently selected text.
    @Sendable
    func selectedTextRanges() throws -> [Range<Int>]
    /// The on-screen rectangle of the element, in screen coordinates.
    @Sendable
    func frame() throws -> NSRect
    /// Set the element's on-screen position.
    @Sendable
    func setPosition(_ position: CGPoint) throws
}

extension Element {
    public var description: String {
        var description = [String]()
        description.reserveCapacity(3)
        description.append(String(describing: self)) // 1
        func append(_ prefix: String,
                    _ attribute: () throws -> Any) {
            guard let value = try? attribute() else {
                return
            }
            description.append(prefix)
            description.append(String(describing: value))
        }
        append("Role:", self.role) // 2
        append("Subrole:", self.subrole) // 3
        return "<Element \(description.joined(separator: " "))>"
    }
}

extension Element {
    public var debugDescription: String {
        var description = [String]()
        description.reserveCapacity(5)
        description.append(String(describing: self)) // 1
        func append(_ prefix: String,
                    _ attribute: () throws -> Any) {
            guard let value = try? attribute() else {
                return
            }
            description.append(prefix)
            description.append(String(describing: value))
        }
        append("Role:", self.role) // 2
        append("Subrole:", self.subrole) // 3
        append("Title:", self.title) // 4
        append("Value:", self.value) // 4
        return "<Element \(description.joined(separator: " "))>"
    }
}
