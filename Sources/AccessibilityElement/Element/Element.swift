//
//  Element.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AppKit
import AX

public protocol Element: Sendable, CustomDebugStringConvertible {
    /// The process identifier of the application that owns this element.
    var processIdentifier: pid_t { get throws }
    
    // MARK: - General

    /// The element's role. Non-localized string that identifies the type of element. (e.g. radioButton)
    func role() throws -> NSAccessibility.Role
    /// Localized string that describes the element's role. (e.g. "radio button")
    func roleDescription() throws -> String
    /// The element's subrole. Non-localized string that further categorizes the element's role. (e.g. closeButton)
    func subrole() throws -> NSAccessibility.Subrole
    /// The element's value.
    func value() throws -> Any
    /// Text description of the element's value.
    func valueDescription() throws -> String
    /// Visible text displayed for the element. (e.g. a push button's label)
    func title() throws -> String
    /// The UI element that serves as the title for this element.
    func titleUIElement() throws -> Self
    /// Element description.
    func description() throws -> String
    /// Help text / tooltip for the element.
    func help() throws -> String
    /// Whether the element responds to user interaction.
    func isEnabled() throws -> Bool
    /// Whether the element currently has keyboard focus.
    func isFocused() throws -> Bool
    /// Whether the element is currently selected.
    func isSelected() throws -> Bool

    // MARK: - Application Attributes

    /// The application's windows.
    func windows() throws -> [Self]
    /// The application's main window.
    func mainWindow() throws -> Self
    /// The application's key window.
    func focusedWindow() throws -> Self
    /// The currently focused UI element.
    func focusedUIElement() throws -> Self
    /// Whether the enhanced user interface is enabled. Only valid on an application element.
    func enhancedUserInterface() throws -> Bool
    /// Enable or disable the enhanced user interface. Only valid on an application element.
    func setEnhancedUserInterface(_ enhancedUserInterface: Bool) throws
    /// Whether the application is currently frontmost.
    func isFrontmost() throws -> Bool
    /// Whether the application is hidden.
    func isHidden() throws -> Bool
    /// The menu bar element of the application.
    func menuBar() throws -> Self
    /// The extras menu bar element of the application.
    func extrasMenuBar() throws -> Self

    // MARK: - Hierarchy

    /// The element that contains this element.
    func parent() throws -> Self
    /// The elements contained by this element.
    func children() throws -> [Self]
    /// Lazy view of the elements contained by this element.
    func childrenView() -> ArrayAttributeView<Self>
    /// The child elements ordered for navigation.
    func childrenInNavigationOrder() throws -> [Self]
    /// Lazy view of the elements children ordered for navigation.
    func childrenInNavigationOrderView() -> ArrayAttributeView<Self>
    /// The child elements that are currently visible.
    func visibleChildren() throws -> [Self]
    /// Lazy view of the child elements that are currently visible.
    func visibleChildrenView() -> ArrayAttributeView<Self>
    /// The child elements that are currently selected.
    func selectedChildren() throws -> [Self]
    /// Lazy view of the child elements that are currently selected.
    func selectedChildrenView() -> ArrayAttributeView<Self>
    /// The window containing this element.
    func window() throws -> Self
    /// The top-level UI element containing this element.
    func topLevelUIElement() throws -> Self
    /// The index of the element within its parent.
    func index() throws -> Int
    
    // MARK: - Hierarchy (Web)

    /// The nearest focusable ancestor of this element.
    func focusableAncestor() throws -> Self
    /// The nearest editable ancestor of this element.
    func editableAncestor() throws -> Self
    /// The highest editable ancestor of this element.
    func highestEditableAncestor() throws -> Self

    // MARK: - Actions

    /// The actions the element supports.
    func actions() throws -> [NSAccessibility.Action]
    /// A localized description of the specified action.
    func description(action: NSAccessibility.Action) throws -> String
    /// Perform the specified action.
    func perform(action: NSAccessibility.Action) throws

    // MARK: - Text

    /// Placeholder text shown when the control has no value.
    func placeholderValue() throws -> String

    // MARK: - Text (Integer Indexed)

    /// The line number of the specified character.
    func line(forIndex index: Int) throws -> Int
    /// The range of characters corresponding to the specified line number.
    func range(forLine line: Int) throws -> Range<Int>
    /// The full range of characters, including the specified character, which compose a single glyph.
    func range(forIndex index: Int) throws -> Range<Int>
    /// The range of characters composing the glyph at the specified point.
    func range(forPosition position: Int) throws -> Range<Int>
    /// The string specified by the range.
    func string(for range: Range<Int>) throws -> String
    /// The rectangle enclosing the specified range of characters.
    /// If the range crosses a line boundary, the returned rectangle will fully enclose all the lines of characters.
    func bounds(for range: Range<Int>) throws -> NSRect
    /// The RTF data describing the specified range of characters.
    func rtf(for range: Range<Int>) throws -> Data
    /// The attributed string for the specified range. Does not use attributes from AppKit/AttributedString.h.
    func attributedString(for range: Range<Int>) throws -> NSAttributedString
    /// The full range of characters, including the specified character, which have the same style.
    func styleRange(for index: Int) throws -> Range<Int>
    /// The line number that contains the insertion point (caret).
    func insertionPointLineNumber() throws -> Int
    /// The portion of shared text storage that belongs to this element.
    func sharedCharacterRange() throws -> Range<Int>
    /// Text elements that share the same text storage as this element.
    func sharedTextUIElements() throws -> [Self]
    /// The range of characters currently visible in the element.
    func visibleCharacterRange() throws -> Range<Int>
    /// Scroll the element so that the specified character range is visible.
    func setVisibleCharacterRange(_ range: Range<Int>) throws
    /// The total number of characters in the element.
    func numberOfCharacters() throws -> Int
    /// The currently selected text.
    func selectedText() throws -> String
    /// The range of the currently selected text.
    func selectedTextRange() throws -> Range<Int>
    /// The ranges of all currently selected text.
    func selectedTextRanges() throws -> [Range<Int>]

    // MARK: - Text (TextMarker Indexed)

    /// The line number of the specified marker.
    func line(forTextMarker textMarker: TextMarker) throws -> Int
    /// The selected text range as a TextMarkerRange (web area / descendants).
    func selectedTextMarkerRange() throws -> TextMarkerRange
    /// The first position in the web area as a TextMarker.
    func startTextMarker() throws -> TextMarker
    /// The last position in the web area as a TextMarker.
    func endTextMarker() throws -> TextMarker
    ///
    func nextTextMarker(for textMarker: TextMarker) throws -> TextMarker
    ///
    func previousTextMarker(for textMarker: TextMarker) throws -> TextMarker
    ///
    func nextWordEndTextMarker(for textMarker: TextMarker) throws -> TextMarker
    ///
    func previousWordStartTextMarker(for textMarker: TextMarker) throws -> TextMarker
    ///
    func nextLineEndTextMarker(for textMarker: TextMarker) throws -> TextMarker
    ///
    func previousLineStartTextMarker(for textMarker: TextMarker) throws -> TextMarker
    ///
    func nextSentenceEndTextMarker(for textMarker: TextMarker) throws -> TextMarker
    ///
    func previousSentenceStartTextMarker(for textMarker: TextMarker) throws -> TextMarker
    ///
    func nextParagraphEndTextMarker(for textMarker: TextMarker) throws -> TextMarker
    ///
    func previousParagraphStartTextMarker(for textMarker: TextMarker) throws -> TextMarker
    /// The TextMarkerRange of the line containing the given TextMarker.
    func lineTextMarkerRange(for textMarker: TextMarker) throws -> TextMarkerRange
    ///
    func leftWordTextMarkerRange(for textMarker: TextMarker) throws -> TextMarkerRange
    ///
    func rightWordTextMarkerRange(for textMarker: TextMarker) throws -> TextMarkerRange
    ///
    func leftLineTextMarkerRange(for textMarker: TextMarker) throws -> TextMarkerRange
    ///
    func rightLineTextMarkerRange(for textMarker: TextMarker) throws -> TextMarkerRange
    ///
    func sentenceTextMarkerRange(for textMarker: TextMarker) throws -> TextMarkerRange
    ///
    func paragraphTextMarkerRange(for textMarker: TextMarker) throws -> TextMarkerRange
    ///
    func styleTextMarkerRange(for textMarker: TextMarker) throws -> TextMarkerRange
    /// The Int line number for a given TextMarker.
    func lineNumber(for textMarker: TextMarker) throws -> Int
    /// The Int character index for a given TextMarker.
    func index(for textMarker: TextMarker) throws -> Int
    /// The element at the position of a given TextMarker.
    func element(for textMarker: TextMarker) throws -> Self
    ///
    func string(for textMarkerRange: TextMarkerRange) throws -> String
    ///
    func attributedString(for textMarkerRange: TextMarkerRange) throws -> NSAttributedString
    ///
    func bounds(for textMarkerRange: TextMarkerRange) throws -> NSRect
    ///
    func length(for textMarkerRange: TextMarkerRange) throws -> Int
    /// The TextMarker for the given character index.
    func textMarker(forIndex index: Int) throws -> TextMarker
    /// The TextMarkerRange for the given line number.
    func textMarkerRange(forLine line: Int) throws -> TextMarkerRange
    /// The TextMarker at the given screen position.
    func textMarker(forPosition position: CGPoint) throws -> TextMarker
    /// The TextMarkerRange for the start of the element intersecting the given rect.
    func startTextMarker(forBounds bounds: NSRect) throws -> TextMarker
    /// The TextMarkerRange for the end of the element intersecting the given rect.
    func endTextMarker(forBounds bounds: NSRect) throws -> TextMarker
    /// The TextMarkerRange covering the full extent of the given element.
    func textMarkerRange(for element: Self) throws -> TextMarkerRange
    /// TextMarkerRange from an unordered pair of TextMarkers.
    func textMarkerRange(forUnordered textMarkers: [TextMarker]) throws -> TextMarkerRange
    /// TextMarkerRange from an ordered [start, end] pair of TextMarkers.
    func textMarkerRange(forOrdered textMarkers: [TextMarker]) throws -> TextMarkerRange

    // MARK: - Text marker validation

    ///
    func isNullTextMarker(_ textMarker: TextMarker) throws -> Bool
    ///
    func isValidTextMarker(_ textMarker: TextMarker) throws -> Bool

    // MARK: - Table/Outline/Grid/List/Collection

    /// The cell element at the specified column and row indices.
    func cell(
        column: Int,
        row: Int
    ) throws -> SystemElement
    /// The rows of a table or outline.
    func rows() throws -> [Self]
    /// Lazy view of the rows a table or outline
    func rowsView() throws -> ArrayAttributeView<Self>
    /// The columns of a table.
    func columns() throws -> [Self]
    /// Lazy view of the columns of a table.
    func columnsView() throws -> ArrayAttributeView<Self>
    /// The rows that are currently selected.
    func selectedRows() throws -> [Self]
    /// Lazy view of the
    func selectedRowsView() throws -> ArrayAttributeView<Self>
    /// The columns that are currently selected.
    func selectedColumns() throws -> [Self]
    /// Lazy view of the columns that are currently selected.
    func selectedColumnsView() throws -> ArrayAttributeView<Self>
    /// The cells that are currently selected.
    func selectedCells() throws -> [Self]
    /// Lazy view of the cells that are currently selected.
    func selectedCellsView() throws -> ArrayAttributeView<Self>
    /// The visible rows of a table or outline.
    func visibleRows() throws -> [Self]
    /// Lazy view of the visible rows of a table or outline.
    func visibleRowsView() throws -> ArrayAttributeView<Self>
    /// The visible columns of a table.
    func visibleColumns() throws -> [Self]
    /// Lazy view of the visible columns of a table.
    func visibleColumnsView() throws -> ArrayAttributeView<Self>
    /// The visible cells of a cell-based table.
    func visibleCells() throws -> [Self]
    /// Lazy view of the visible cells of a cell-based table.
    func visibleCellsView() throws -> ArrayAttributeView<Self>
    /// The row header elements of a cell-based table.
    func rowHeaderUIElements() throws -> [Self]
    /// Lazy view of the row header elements of a cell-based table.
    func rowHeaderUIElementsView() throws -> ArrayAttributeView<Self>
    /// The column header elements of a cell-based table.
    func columnHeaderUIElements() throws -> [Self]
    /// Lazy view of the column header elements of a cell-based table.
    func columnHeaderUIElementsView() throws -> ArrayAttributeView<Self>
    /// The column title elements of a table.
    func columnTitles() throws -> [Self]
    /// Lazy view of the column title elements of a table.
    func columnTitlesView() throws -> ArrayAttributeView<Self>
    /// The sort direction of a column.
    func sortDirection() throws -> String
    /// The number of rows in the table.
    func rowCount() throws -> Int
    /// The number of columns in the table.
    func columnCount() throws -> Int
    /// Whether the table is ordered by row rather than column.
    func isOrderedByRow() throws -> Bool
    /// The row location and span of a cell, as an index range.
    func rowIndexRange() throws -> Range<Int>
    /// The column location and span of a cell, as an index range.
    func columnIndexRange() throws -> Range<Int>

    // MARK: - Layout

    /// The on-screen rectangle of the element, in screen coordinates.
    func frame() throws -> NSRect
    /// Set the element's on-screen position.
    func setPosition(_ position: CGPoint) throws

    // MARK: - Linked Elements

    /// UI elements linked to this element.
    func linkedUIElements() throws -> [Self]
    /// UI elements for which this element serves as a title.
    func servesAsTitleForUIElements() throws -> [Self]

    // MARK: - Slider

    /// The minimum value the element can take.
    func minValue() throws -> Any
    /// The maximum value the element can take.
    func maxValue() throws -> Any
    /// The warning threshold value of a level indicator.
    func warningValue() throws -> Any
    /// The critical threshold value of a level indicator.
    func criticalValue() throws -> Any
    /// The set of discrete values a slider allows.
    func allowedValues() throws -> [Double]
    /// The label UI elements associated with a slider.
    func labelUIElements() throws -> [Self]
    /// The value of a label UI element on a slider.
    func labelValue() throws -> Double

    // MARK: - Window

    /// Whether this is the application's main window.
    func isMain() throws -> Bool
    /// Whether the window is minimized.
    func isMinimized() throws -> Bool
    /// Whether the window is modal.
    func isModal() throws -> Bool
    /// The close button of the window.
    func closeButton() throws -> Self
    /// The zoom button of the window.
    func zoomButton() throws -> Self
    /// The minimize button of the window.
    func minimizeButton() throws -> Self
    /// The toolbar button of the window.
    func toolbarButton() throws -> Self
    /// The full-screen button of the window.
    func fullScreenButton() throws -> Self
    /// The default button of the window.
    func defaultButton() throws -> Self
    /// The cancel button of the window.
    func cancelButton() throws -> Self
    /// The proxy icon element in the title bar.
    func proxy() throws -> Self
    /// The grow area (resize handle) of the window.
    func growArea() throws -> Self

    // MARK: - Container / scroll UI

    /// The header element (e.g. column header in a table).
    func header() throws -> Self
    /// The tab elements of a tab group.
    func tabs() throws -> [Self]
    /// The splitter elements of a split view.
    func splitters() throws -> [Self]
    /// The horizontal scroll bar.
    func horizontalScrollBar() throws -> Self
    /// The vertical scroll bar.
    func verticalScrollBar() throws -> Self
    /// The overflow button (e.g. of a toolbar).
    func overflowButton() throws -> Self
    /// The increment button of a stepper or scroll bar.
    func incrementButton() throws -> Self
    /// The decrement button of a stepper or scroll bar.
    func decrementButton() throws -> Self
    /// The preceding sibling content elements.
    func previousContents() throws -> [Self]
    /// The following sibling content elements.
    func nextContents() throws -> [Self]
    /// The menu currently shown by this element.
    func shownMenu() throws -> Self
    /// The search button of a search field.
    func searchButton() throws -> Self
    /// The search menu of a search field.
    func searchMenu() throws -> Self
    /// The clear button of a search field.
    func clearButton() throws -> Self

    // MARK: - Outline / tree

    /// Whether the outline row is currently disclosing its children.
    func isDisclosing() throws -> Bool
    /// The rows disclosed by this outline row.
    func disclosedRows() throws -> [Self]
    /// The outline row that discloses this row.
    func disclosedByRow() throws -> Self
    /// The indentation level of this outline row.
    func disclosureLevel() throws -> Int

    // MARK: - Misc

    /// Application-defined identifier string.
    func identifier() throws -> String
    /// The URL associated with the element.
    func url() throws -> URL
    /// The URL of the open document, as a string.
    func document() throws -> String
    /// The filename associated with the element.
    func filename() throws -> String
    /// The orientation of the element.
    func orientation() throws -> String
    /// The main child elements of the element.
    func contents() throws -> [Self]
    /// Elements that share keyboard focus with this element.
    func sharedFocusElements() throws -> [Self]
    /// Whether the element is expanded (e.g. a disclosure triangle or combo box).
    func isExpanded() throws -> Bool
    /// Whether the element has unsaved changes.
    func isEdited() throws -> Bool
    /// Whether a form field is required to have content.
    func isRequired() throws -> Bool
    /// Whether the element contains protected (non-readable) content.
    func containsProtectedContent() throws -> Bool
    /// The point that activates the element, in screen coordinates.
    func activationPoint() throws -> CGPoint
}

extension Element {
    // MARK: - General
    
    public func description() throws -> String {
        throw ElementError.noValue
    }
    public func help() throws -> String {
        throw ElementError.noValue
    }
    public func isEnabled() throws -> Bool {
        throw ElementError.noValue
    }
    public func isFocused() throws -> Bool {
        throw ElementError.noValue
    }
    public func isSelected() throws -> Bool {
        throw ElementError.noValue
    }
    public func valueDescription() throws -> String {
        throw ElementError.noValue
    }
    
    // MARK: - Application Attributes
    
    public func isFrontmost() throws -> Bool {
        throw ElementError.noValue
    }
    public func isHidden() throws -> Bool {
        throw ElementError.noValue
    }
    public func menuBar() throws -> Self {
        throw ElementError.noValue
    }
    public func extrasMenuBar() throws -> Self {
        throw ElementError.noValue
    }
    
    // MARK: - Hierarchy
    
    public func children() throws -> [Self] {
        throw ElementError.noValue
    }
    public func childrenView() throws -> ArrayAttributeView<Self> {
        throw ElementError.noValue
    }
    public func childrenInNavigationOrder() throws -> [Self] {
        throw ElementError.noValue
    }
    public func childrenInNavigationOrderView() throws -> ArrayAttributeView<Self> {
        throw ElementError.noValue
    }
    public func visibleChildren() throws -> [Self] {
        throw ElementError.noValue
    }
    public func visibleChildrenView() throws -> ArrayAttributeView<Self> {
        throw ElementError.noValue
    }
    public func selectedChildren() throws -> [Self] {
        throw ElementError.noValue
    }
    public func selectedChildrenView() throws -> ArrayAttributeView<Self> {
        throw ElementError.noValue
    }
    public func window() throws -> Self {
        throw ElementError.noValue
    }
    public func topLevelUIElement() throws -> Self {
        throw ElementError.noValue
    }
    public func index() throws -> Int {
        throw ElementError.noValue
    }

    // MARK: - Text

    public func placeholderValue() throws -> String {
        throw ElementError.noValue
    }

    // MARK: - Text (Integer Indexed)
    
    func line(forIndex index: Int) throws -> Int {
        throw ElementError.noValue
    }
    func range(forLine line: Int) throws -> Range<Int> {
        throw ElementError.noValue
    }
    func range(forIndex index: Int) throws -> Range<Int> {
        throw ElementError.noValue
    }
    func range(forPosition position: Int) throws -> Range<Int> {
        throw ElementError.noValue
    }
    func string(for range: Range<Int>) throws -> String {
        throw ElementError.noValue
    }
    func bounds(for range: Range<Int>) throws -> NSRect {
        throw ElementError.noValue
    }
    func rtf(for range: Range<Int>) throws -> Data {
        throw ElementError.noValue
    }
    func attributedString(for range: Range<Int>) throws -> NSAttributedString {
        throw ElementError.noValue
    }
    func styleRange(for index: Int) throws -> Range<Int> {
        throw ElementError.noValue
    }
    func insertionPointLineNumber() throws -> Int {
        throw ElementError.noValue
    }
    func sharedCharacterRange() throws -> Range<Int> {
        throw ElementError.noValue
    }
    func sharedTextUIElements() throws -> [Self] {
        throw ElementError.noValue
    }
    func visibleCharacterRange() throws -> Range<Int> {
        throw ElementError.noValue
    }
    func setVisibleCharacterRange(_ range: Range<Int>) throws {
        throw ElementError.noValue
    }
    func numberOfCharacters() throws -> Int {
        throw ElementError.noValue
    }
    func selectedText() throws -> String {
        throw ElementError.noValue
    }
    func selectedTextRange() throws -> Range<Int> {
        throw ElementError.noValue
    }
    func selectedTextRanges() throws -> [Range<Int>] {
        throw ElementError.noValue
    }

    // MARK: - Text (TextMarker Indexed)

    /// The line number of the specified marker.
    func line(forTextMarker textMarker: TextMarker) throws -> Int {
        throw ElementError.noValue
    }

    // MARK: - Table/Outline/Grid/List/Collection

    public func visibleRows() throws -> [Self] {
        throw ElementError.noValue
    }
    public func visibleRowsView() throws -> ArrayAttributeView<Self> {
        throw ElementError.noValue
    }
    public func visibleColumns() throws -> [Self] {
        throw ElementError.noValue
    }
    public func visibleColumnsView() throws -> ArrayAttributeView<Self> {
        throw ElementError.noValue
    }
    public func visibleCells() throws -> [Self] {
        throw ElementError.noValue
    }
    public func visibleCellsView() throws -> ArrayAttributeView<Self> {
        throw ElementError.noValue
    }
    public func rowHeaderUIElements() throws -> [Self] {
        throw ElementError.noValue
    }
    public func rowHeaderUIElementsView() throws -> ArrayAttributeView<Self> {
        throw ElementError.noValue
    }
    public func columnHeaderUIElements() throws -> [Self] {
        throw ElementError.noValue
    }
    public func columnHeaderUIElementsView() throws -> ArrayAttributeView<Self> {
        throw ElementError.noValue
    }
    public func columnTitles() throws -> [Self] {
        throw ElementError.noValue
    }
    public func columnTitlesView() throws -> ArrayAttributeView<Self> {
        throw ElementError.noValue
    }
    public func sortDirection() throws -> String {
        throw ElementError.noValue
    }
    public func rowCount() throws -> Int {
        throw ElementError.noValue
    }
    public func columnCount() throws -> Int {
        throw ElementError.noValue
    }
    public func isOrderedByRow() throws -> Bool {
        throw ElementError.noValue
    }
    public func rowIndexRange() throws -> Range<Int> {
        throw ElementError.noValue
    }
    public func columnIndexRange() throws -> Range<Int> {
        throw ElementError.noValue
    }

    // MARK: - Linked Elements

    public func linkedUIElements() throws -> [Self] {
        throw ElementError.noValue
    }
    public func servesAsTitleForUIElements() throws -> [Self] {
        throw ElementError.noValue
    }

    // MARK: - Slider

    public func minValue() throws -> Any {
        throw ElementError.noValue
    }
    public func maxValue() throws -> Any {
        throw ElementError.noValue
    }
    public func warningValue() throws -> Any {
        throw ElementError.noValue
    }
    public func criticalValue() throws -> Any {
        throw ElementError.noValue
    }
    public func allowedValues() throws -> [Double] {
        throw ElementError.noValue
    }
    public func labelUIElements() throws -> [Self] {
        throw ElementError.noValue
    }
    public func labelValue() throws -> Double {
        throw ElementError.noValue
    }

    // MARK: - Window

    public func isMain() throws -> Bool {
        throw ElementError.noValue
    }
    public func isMinimized() throws -> Bool {
        throw ElementError.noValue
    }
    public func isModal() throws -> Bool {
        throw ElementError.noValue
    }
    public func closeButton() throws -> Self {
        throw ElementError.noValue
    }
    public func zoomButton() throws -> Self {
        throw ElementError.noValue
    }
    public func minimizeButton() throws -> Self {
        throw ElementError.noValue
    }
    public func toolbarButton() throws -> Self {
        throw ElementError.noValue
    }
    public func fullScreenButton() throws -> Self {
        throw ElementError.noValue
    }
    public func defaultButton() throws -> Self {
        throw ElementError.noValue
    }
    public func cancelButton() throws -> Self {
        throw ElementError.noValue
    }
    public func proxy() throws -> Self {
        throw ElementError.noValue
    }
    public func growArea() throws -> Self {
        throw ElementError.noValue
    }

    // MARK: - Container / scroll UI

    public func header() throws -> Self {
        throw ElementError.noValue
    }
    public func tabs() throws -> [Self] {
        throw ElementError.noValue
    }
    public func splitters() throws -> [Self] {
        throw ElementError.noValue
    }
    public func horizontalScrollBar() throws -> Self {
        throw ElementError.noValue
    }
    public func verticalScrollBar() throws -> Self {
        throw ElementError.noValue
    }
    public func overflowButton() throws -> Self {
        throw ElementError.noValue
    }
    public func incrementButton() throws -> Self {
        throw ElementError.noValue
    }
    public func decrementButton() throws -> Self {
        throw ElementError.noValue
    }
    public func previousContents() throws -> [Self] {
        throw ElementError.noValue
    }
    public func nextContents() throws -> [Self] {
        throw ElementError.noValue
    }
    public func shownMenu() throws -> Self {
        throw ElementError.noValue
    }
    public func searchButton() throws -> Self {
        throw ElementError.noValue
    }
    public func searchMenu() throws -> Self {
        throw ElementError.noValue
    }
    public func clearButton() throws -> Self {
        throw ElementError.noValue
    }

    // MARK: - Outline / tree

    public func isDisclosing() throws -> Bool {
        throw ElementError.noValue
    }
    public func disclosedRows() throws -> [Self] {
        throw ElementError.noValue
    }
    public func disclosedByRow() throws -> Self {
        throw ElementError.noValue
    }
    public func disclosureLevel() throws -> Int {
        throw ElementError.noValue
    }

    // MARK: - Misc

    public func identifier() throws -> String {
        throw ElementError.noValue
    }
    public func url() throws -> URL {
        throw ElementError.noValue
    }
    public func document() throws -> String {
        throw ElementError.noValue
    }
    public func filename() throws -> String {
        throw ElementError.noValue
    }
    public func orientation() throws -> String {
        throw ElementError.noValue
    }
    public func contents() throws -> [Self] {
        throw ElementError.noValue
    }
    public func sharedFocusElements() throws -> [Self] {
        throw ElementError.noValue
    }
    public func isExpanded() throws -> Bool {
        throw ElementError.noValue
    }
    public func isEdited() throws -> Bool {
        throw ElementError.noValue
    }
    public func isRequired() throws -> Bool {
        throw ElementError.noValue
    }
    public func containsProtectedContent() throws -> Bool {
        throw ElementError.noValue
    }
    public func activationPoint() throws -> CGPoint {
        throw ElementError.noValue
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
