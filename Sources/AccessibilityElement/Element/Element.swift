//
//  Element.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AppKit
import AX

public protocol Element: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    /// String that defines the element’s role in the app. (not localized)
    @Sendable
    func role() throws -> NSAccessibility.Role
    /// Localized string that describes the element’s role in the app
    @Sendable
    func roleDescription() throws -> String
    ///
    @Sendable
    func subrole() throws -> NSAccessibility.Subrole
    ///
    @Sendable
    func value() throws -> any Sendable
    ///
    @Sendable
    func title() throws -> String
    ///
    @Sendable
    func titleUIElement() throws -> Self
    ///
    var processIdentifier: pid_t { get throws }
    ///
    @Sendable
    func windows() throws -> [Self]
    ///
    @Sendable
    func mainWindow() throws -> Self
    ///
    @Sendable
    func focusedWindow() throws -> Self
    ///
    @Sendable
    func focusedUIElement() throws -> Self
    ///
    @Sendable
    func parent() throws -> Self
    ///
    @Sendable
    func children() throws -> [Self]
    ///
    @Sendable
    func childrenInNavigationOrder() throws -> [Self]
    ///
    @Sendable
    func visibleChildren() throws -> [Self]
    ///
    @Sendable
    func selectedChildren() throws -> [Self]
    ///
    @Sendable
    func rows() throws -> [Self]
    ///
    @Sendable
    func columns() throws -> [Self]
    ///
    @Sendable
    func selectedRows() throws -> [Self]
    ///
    @Sendable
    func selectedColumns() throws -> [Self]
    ///
    @Sendable
    func selectedCells() throws -> [Self]
    ///
    @Sendable
    func enhancedUserInterface() throws -> Bool
    ///
    @Sendable
    func setEnhancedUserInterface(_ enhancedUserInterface: Bool) throws
    ///
    @Sendable
    func actions() throws -> [NSAccessibility.Action]
    ///
    @Sendable
    func description(action: NSAccessibility.Action) throws -> String
    ///
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
    ///
    @Sendable
    func attributedString(for range: Range<Int>) throws -> NSAttributedString
    /// The full range of characters, including the specified character, which have the same style.
    @Sendable
    func styleRange(for index: Int) throws -> Range<Int>
    ///
    @Sendable
    func cell(
        column: Int,
        row: Int
    ) throws -> SystemElement
    ///
    @Sendable
    func insertionPointLineNumber() throws -> Int
    ///
    @Sendable
    func sharedCharacterRange() throws -> Range<Int>
    ///
    @Sendable
    func sharedTextUIElements() throws -> [Self]
    ///
    @Sendable
    func visibleCharacterRange() throws -> Range<Int>
    ///
    @Sendable
    func numberOfCharacters() throws -> Int
    ///
    @Sendable
    func selectedText() throws -> String
    ///
    @Sendable
    func selectedTextRange() throws -> Range<Int>
    ///
    @Sendable
    func selectedTextRanges() throws -> [Range<Int>]
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
