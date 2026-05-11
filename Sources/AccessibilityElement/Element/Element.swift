//
//  Element.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AppKit
import AX

public protocol Element: Sendable, CustomDebugStringConvertible {
    /// The process identifier of the application that owns this element.
    var processIdentifier: pid_t { get async throws }

    // MARK: - Serialization

    ///
    func transportRepresentation() throws -> Data
    ///
    init(transportRepresentation: Data) throws

    // MARK: - General

    /// The element's role. Non-localized string that identifies the type of element. (e.g. radioButton)
    func role() async throws -> NSAccessibility.Role
    /// Localized string that describes the element's role. (e.g. "radio button")
    func roleDescription() async throws -> String
    /// The element's subrole. Non-localized string that further categorizes the element's role. (e.g. closeButton)
    func subrole() async throws -> NSAccessibility.Subrole
    /// The element's value.
    func value() async throws -> Any
    /// Text description of the element's value.
    func valueDescription() async throws -> String
    /// Visible text displayed for the element. (e.g. a push button's label)
    func title() async throws -> String
    /// The UI element that serves as the title for this element.
    func titleUIElement() async throws -> Self
    /// Element description.
    func description() async throws -> String
    /// Help text / tooltip for the element.
    func help() async throws -> String
    /// Whether the element responds to user interaction.
    func isEnabled() async throws -> Bool
    /// Whether the element currently has keyboard focus.
    func isFocused() async throws -> Bool
    /// Whether the element is currently selected.
    func isSelected() async throws -> Bool

    // MARK: - Application Attributes

    /// The application's windows.
    func windows() async throws -> [Self]
    /// The application's main window.
    func mainWindow() async throws -> Self
    /// The application's key window.
    func focusedWindow() async throws -> Self
    /// The currently focused UI element.
    func focusedUIElement() async throws -> Self
    /// Whether the enhanced user interface is enabled. Only valid on an application element.
    func enhancedUserInterface() async throws -> Bool
    /// Enable or disable the enhanced user interface. Only valid on an application element.
    func setEnhancedUserInterface(_ enhancedUserInterface: Bool) async throws
    /// Whether the application is currently frontmost.
    func isFrontmost() async throws -> Bool
    /// Whether the application is hidden.
    func isHidden() async throws -> Bool
    /// The menu bar element of the application.
    func menuBar() async throws -> Self
    /// The extras menu bar element of the application.
    func extrasMenuBar() async throws -> Self

    // MARK: - Hierarchy

    /// The element that contains this element.
    func parent() async throws -> Self
    /// The elements contained by this element.
    func children() async throws -> [Self]
    /// Lazy view of the elements contained by this element.
    func childrenView() -> ArrayAttributeView<Self>
    /// The child elements ordered for navigation.
    func childrenInNavigationOrder() async throws -> [Self]
    /// Lazy view of the elements children ordered for navigation.
    func childrenInNavigationOrderView() -> ArrayAttributeView<Self>
    /// The child elements that are currently visible.
    func visibleChildren() async throws -> [Self]
    /// Lazy view of the child elements that are currently visible.
    func visibleChildrenView() -> ArrayAttributeView<Self>
    /// The child elements that are currently selected.
    func selectedChildren() async throws -> [Self]
    /// Lazy view of the child elements that are currently selected.
    func selectedChildrenView() -> ArrayAttributeView<Self>
    /// The window containing this element.
    func window() async throws -> Self
    /// The top-level UI element containing this element.
    func topLevelUIElement() async throws -> Self
    /// The index of the element within its parent.
    func index() async throws -> Int

    // MARK: - Hierarchy (Web)

    /// The nearest focusable ancestor of this element.
    func focusableAncestor() async throws -> Self
    /// The nearest editable ancestor of this element.
    func editableAncestor() async throws -> Self
    /// The highest editable ancestor of this element.
    func highestEditableAncestor() async throws -> Self

    // MARK: - Actions

    /// The actions the element supports.
    func actions() async throws -> [NSAccessibility.Action]
    /// A localized description of the specified action.
    func description(action: NSAccessibility.Action) async throws -> String
    /// Perform the specified action.
    func perform(action: NSAccessibility.Action) async throws

    // MARK: - Text

    /// Placeholder text shown when the control has no value.
    func placeholderValue() async throws -> String

    // MARK: - Text (Integer Indexed)

    /// The line number of the specified character.
    func line(forIndex index: Int) async throws -> Int
    /// The range of characters corresponding to the specified line number.
    func range(forLine line: Int) async throws -> Range<Int>
    /// The full range of characters, including the specified character, which compose a single glyph.
    func range(forIndex index: Int) async throws -> Range<Int>
    /// The range of characters composing the glyph at the specified point.
    func range(forPosition position: Int) async throws -> Range<Int>
    /// The string specified by the range.
    func string(for range: Range<Int>) async throws -> String
    /// The rectangle enclosing the specified range of characters.
    /// If the range crosses a line boundary, the returned rectangle will fully enclose all the lines of characters.
    func bounds(for range: Range<Int>) async throws -> NSRect
    /// The RTF data describing the specified range of characters.
    func rtf(for range: Range<Int>) async throws -> Data
    /// The attributed string for the specified range. Does not use attributes from AppKit/AttributedString.h.
    func attributedString(for range: Range<Int>) async throws -> NSAttributedString
    /// The full range of characters, including the specified character, which have the same style.
    func styleRange(for index: Int) async throws -> Range<Int>
    /// The line number that contains the insertion point (caret).
    func insertionPointLineNumber() async throws -> Int
    /// The portion of shared text storage that belongs to this element.
    func sharedCharacterRange() async throws -> Range<Int>
    /// Text elements that share the same text storage as this element.
    func sharedTextUIElements() async throws -> [Self]
    /// The range of characters currently visible in the element.
    func visibleCharacterRange() async throws -> Range<Int>
    /// Scroll the element so that the specified character range is visible.
    func setVisibleCharacterRange(_ range: Range<Int>) async throws
    /// The total number of characters in the element.
    func numberOfCharacters() async throws -> Int
    /// The currently selected text.
    func selectedText() async throws -> String
    /// The range of the currently selected text.
    func selectedTextRange() async throws -> Range<Int>
    /// The ranges of all currently selected text.
    func selectedTextRanges() async throws -> [Range<Int>]

    // MARK: - Text (TextMarker Indexed)

    /// The line number of the specified marker.
    func line(forTextMarker textMarker: TextMarker) async throws -> Int
    /// The selected text range as a TextMarkerRange (web area / descendants).
    func selectedTextMarkerRange() async throws -> TextMarkerRange
    /// The first position in the web area as a TextMarker.
    func startTextMarker() async throws -> TextMarker
    /// The last position in the web area as a TextMarker.
    func endTextMarker() async throws -> TextMarker
    ///
    func nextTextMarker(for textMarker: TextMarker) async throws -> TextMarker
    ///
    func previousTextMarker(for textMarker: TextMarker) async throws -> TextMarker
    ///
    func nextWordEndTextMarker(for textMarker: TextMarker) async throws -> TextMarker
    ///
    func previousWordStartTextMarker(for textMarker: TextMarker) async throws -> TextMarker
    ///
    func nextLineEndTextMarker(for textMarker: TextMarker) async throws -> TextMarker
    ///
    func previousLineStartTextMarker(for textMarker: TextMarker) async throws -> TextMarker
    ///
    func nextSentenceEndTextMarker(for textMarker: TextMarker) async throws -> TextMarker
    ///
    func previousSentenceStartTextMarker(for textMarker: TextMarker) async throws -> TextMarker
    ///
    func nextParagraphEndTextMarker(for textMarker: TextMarker) async throws -> TextMarker
    ///
    func previousParagraphStartTextMarker(for textMarker: TextMarker) async throws -> TextMarker
    /// The TextMarkerRange of the line containing the given TextMarker.
    func lineTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange
    ///
    func leftWordTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange
    ///
    func rightWordTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange
    ///
    func leftLineTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange
    ///
    func rightLineTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange
    ///
    func sentenceTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange
    ///
    func paragraphTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange
    ///
    func styleTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange
    /// The Int line number for a given TextMarker.
    func lineNumber(for textMarker: TextMarker) async throws -> Int
    /// The Int character index for a given TextMarker.
    func index(for textMarker: TextMarker) async throws -> Int
    /// The element at the position of a given TextMarker.
    func element(for textMarker: TextMarker) async throws -> Self
    ///
    func string(for textMarkerRange: TextMarkerRange) async throws -> String
    ///
    func attributedString(for textMarkerRange: TextMarkerRange) async throws -> NSAttributedString
    ///
    func bounds(for textMarkerRange: TextMarkerRange) async throws -> NSRect
    ///
    func length(for textMarkerRange: TextMarkerRange) async throws -> Int
    /// The TextMarker for the given character index.
    func textMarker(forIndex index: Int) async throws -> TextMarker
    /// The TextMarkerRange for the given line number.
    func textMarkerRange(forLine line: Int) async throws -> TextMarkerRange
    /// The TextMarker at the given screen position.
    func textMarker(forPosition position: CGPoint) async throws -> TextMarker
    /// The TextMarkerRange for the start of the element intersecting the given rect.
    func startTextMarker(forBounds bounds: NSRect) async throws -> TextMarker
    /// The TextMarkerRange for the end of the element intersecting the given rect.
    func endTextMarker(forBounds bounds: NSRect) async throws -> TextMarker
    /// The TextMarkerRange covering the full extent of the given element.
    func textMarkerRange(for element: Self) async throws -> TextMarkerRange
    /// TextMarkerRange from an unordered pair of TextMarkers.
    func textMarkerRange(forUnordered textMarkers: [TextMarker]) async throws -> TextMarkerRange
    /// TextMarkerRange from an ordered [start, end] pair of TextMarkers.
    func textMarkerRange(forOrdered textMarkers: [TextMarker]) async throws -> TextMarkerRange

    // MARK: - Text marker validation

    ///
    func isNullTextMarker(_ textMarker: TextMarker) async throws -> Bool
    ///
    func isValidTextMarker(_ textMarker: TextMarker) async throws -> Bool

    // MARK: - Table/Outline/Grid/List/Collection

    /// The cell element at the specified column and row indices.
    func cell(
        column: Int,
        row: Int
    ) async throws -> Self
    /// The rows of a table or outline.
    func rows() async throws -> [Self]
    /// Lazy view of the rows a table or outline
    func rowsView() async throws -> ArrayAttributeView<Self>
    /// The columns of a table.
    func columns() async throws -> [Self]
    /// Lazy view of the columns of a table.
    func columnsView() async throws -> ArrayAttributeView<Self>
    /// The rows that are currently selected.
    func selectedRows() async throws -> [Self]
    /// Lazy view of the
    func selectedRowsView() async throws -> ArrayAttributeView<Self>
    /// The columns that are currently selected.
    func selectedColumns() async throws -> [Self]
    /// Lazy view of the columns that are currently selected.
    func selectedColumnsView() async throws -> ArrayAttributeView<Self>
    /// The cells that are currently selected.
    func selectedCells() async throws -> [Self]
    /// Lazy view of the cells that are currently selected.
    func selectedCellsView() async throws -> ArrayAttributeView<Self>
    /// The visible rows of a table or outline.
    func visibleRows() async throws -> [Self]
    /// Lazy view of the visible rows of a table or outline.
    func visibleRowsView() async throws -> ArrayAttributeView<Self>
    /// The visible columns of a table.
    func visibleColumns() async throws -> [Self]
    /// Lazy view of the visible columns of a table.
    func visibleColumnsView() async throws -> ArrayAttributeView<Self>
    /// The visible cells of a cell-based table.
    func visibleCells() async throws -> [Self]
    /// Lazy view of the visible cells of a cell-based table.
    func visibleCellsView() async throws -> ArrayAttributeView<Self>
    /// The row header elements of a cell-based table.
    func rowHeaderUIElements() async throws -> [Self]
    /// Lazy view of the row header elements of a cell-based table.
    func rowHeaderUIElementsView() async throws -> ArrayAttributeView<Self>
    /// The column header elements of a cell-based table.
    func columnHeaderUIElements() async throws -> [Self]
    /// Lazy view of the column header elements of a cell-based table.
    func columnHeaderUIElementsView() async throws -> ArrayAttributeView<Self>
    /// The column title elements of a table.
    func columnTitles() async throws -> [Self]
    /// Lazy view of the column title elements of a table.
    func columnTitlesView() async throws -> ArrayAttributeView<Self>
    /// The sort direction of a column.
    func sortDirection() async throws -> String
    /// The number of rows in the table.
    func rowCount() async throws -> Int
    /// The number of columns in the table.
    func columnCount() async throws -> Int
    /// Whether the table is ordered by row rather than column.
    func isOrderedByRow() async throws -> Bool
    /// The row location and span of a cell, as an index range.
    func rowIndexRange() async throws -> Range<Int>
    /// The column location and span of a cell, as an index range.
    func columnIndexRange() async throws -> Range<Int>

    // MARK: - Layout

    /// The on-screen rectangle of the element, in screen coordinates.
    func frame() async throws -> NSRect
    /// Set the element's on-screen position.
    func setPosition(_ position: CGPoint) async throws

    // MARK: - Linked Elements

    /// UI elements linked to this element.
    func linkedUIElements() async throws -> [Self]
    /// UI elements for which this element serves as a title.
    func servesAsTitleForUIElements() async throws -> [Self]

    // MARK: - Slider

    /// The minimum value the element can take.
    func minValue() async throws -> Any
    /// The maximum value the element can take.
    func maxValue() async throws -> Any
    /// The warning threshold value of a level indicator.
    func warningValue() async throws -> Any
    /// The critical threshold value of a level indicator.
    func criticalValue() async throws -> Any
    /// The set of discrete values a slider allows.
    func allowedValues() async throws -> [Double]
    /// The label UI elements associated with a slider.
    func labelUIElements() async throws -> [Self]
    /// The value of a label UI element on a slider.
    func labelValue() async throws -> Double

    // MARK: - Window

    /// Whether this is the application's main window.
    func isMain() async throws -> Bool
    /// Whether the window is minimized.
    func isMinimized() async throws -> Bool
    /// Whether the window is modal.
    func isModal() async throws -> Bool
    /// The close button of the window.
    func closeButton() async throws -> Self
    /// The zoom button of the window.
    func zoomButton() async throws -> Self
    /// The minimize button of the window.
    func minimizeButton() async throws -> Self
    /// The toolbar button of the window.
    func toolbarButton() async throws -> Self
    /// The full-screen button of the window.
    func fullScreenButton() async throws -> Self
    /// The default button of the window.
    func defaultButton() async throws -> Self
    /// The cancel button of the window.
    func cancelButton() async throws -> Self
    /// The proxy icon element in the title bar.
    func proxy() async throws -> Self
    /// The grow area (resize handle) of the window.
    func growArea() async throws -> Self

    // MARK: - Container / scroll UI

    /// The header element (e.g. column header in a table).
    func header() async throws -> Self
    /// The tab elements of a tab group.
    func tabs() async throws -> [Self]
    /// The splitter elements of a split view.
    func splitters() async throws -> [Self]
    /// The horizontal scroll bar.
    func horizontalScrollBar() async throws -> Self
    /// The vertical scroll bar.
    func verticalScrollBar() async throws -> Self
    /// The overflow button (e.g. of a toolbar).
    func overflowButton() async throws -> Self
    /// The increment button of a stepper or scroll bar.
    func incrementButton() async throws -> Self
    /// The decrement button of a stepper or scroll bar.
    func decrementButton() async throws -> Self
    /// The preceding sibling content elements.
    func previousContents() async throws -> [Self]
    /// The following sibling content elements.
    func nextContents() async throws -> [Self]
    /// The single preceding content sibling
    func previousContentSibling() async throws -> Self
    /// The single following content sibling
    func nextContentSibling() async throws -> Self
    func contentSiblingAbove() async throws -> Self
    func contentSiblingBelow() async throws -> Self
    func firstContentSibling() async throws -> Self
    func lastContentSibling() async throws -> Self
    /// The menu currently shown by this element.
    func shownMenu() async throws -> Self
    /// The search button of a search field.
    func searchButton() async throws -> Self
    /// The search menu of a search field.
    func searchMenu() async throws -> Self
    /// The clear button of a search field.
    func clearButton() async throws -> Self

    // MARK: - Outline / tree

    /// Whether the outline row is currently disclosing its children.
    func isDisclosing() async throws -> Bool
    /// The rows disclosed by this outline row.
    func disclosedRows() async throws -> [Self]
    /// The outline row that discloses this row.
    func disclosedByRow() async throws -> Self
    /// The indentation level of this outline row.
    func disclosureLevel() async throws -> Int

    // MARK: - Misc

    /// Application-defined identifier string.
    func identifier() async throws -> String
    /// The URL associated with the element.
    func url() async throws -> URL
    /// The URL of the open document, as a string.
    func document() async throws -> String
    /// The filename associated with the element.
    func filename() async throws -> String
    /// The orientation of the element.
    func orientation() async throws -> String
    /// The main child elements of the element.
    func contents() async throws -> [Self]
    /// Elements that share keyboard focus with this element.
    func sharedFocusElements() async throws -> [Self]
    /// Whether the element is expanded (e.g. a disclosure triangle or combo box).
    func isExpanded() async throws -> Bool
    /// Whether the element has unsaved changes.
    func isEdited() async throws -> Bool
    /// Whether a form field is required to have content.
    func isRequired() async throws -> Bool
    /// Whether the element contains protected (non-readable) content.
    func containsProtectedContent() async throws -> Bool
    /// The point that activates the element, in screen coordinates.
    func activationPoint() async throws -> CGPoint

    // MARK: - Web

    /// Whether the web area has finished loading.
    func isLoaded() async throws -> Bool
    /// Loading progress of the web area (0.0–1.0).
    func loadingProgress() async throws -> Double
    /// Number of layout passes the web area has completed.
    func layoutCount() async throws -> Int
    /// Whether keyboard events should be dispatched to the DOM rather than the AT.
    func preventKeyboardDOMEventDispatch() async throws -> Bool

    // MARK: - MathML

    func mathBase() async throws -> Self
    func mathFencedOpen() async throws -> String
    func mathFencedClose() async throws -> String
    func mathFractionNumerator() async throws -> Self
    func mathFractionDenominator() async throws -> Self
    func mathLineThickness() async throws -> Double
    func mathOver() async throws -> Self
    func mathUnder() async throws -> Self
    func mathPostscripts() async throws -> [Self]
    func mathPrescripts() async throws -> [Self]
    func mathRootIndex() async throws -> Self
    func mathRootRadicand() async throws -> Self
    func mathSubscript() async throws -> Self
    func mathSuperscript() async throws -> Self
}

extension Element {
    // MARK: - General

    public func description() async throws -> String {
        throw ElementError.noValue
    }
    public func help() async throws -> String {
        throw ElementError.noValue
    }
    public func isEnabled() async throws -> Bool {
        throw ElementError.noValue
    }
    public func isFocused() async throws -> Bool {
        throw ElementError.noValue
    }
    public func isSelected() async throws -> Bool {
        throw ElementError.noValue
    }
    public func valueDescription() async throws -> String {
        throw ElementError.noValue
    }

    // MARK: - Application Attributes

    public func isFrontmost() async throws -> Bool {
        throw ElementError.noValue
    }
    public func isHidden() async throws -> Bool {
        throw ElementError.noValue
    }
    public func menuBar() async throws -> Self {
        throw ElementError.noValue
    }
    public func extrasMenuBar() async throws -> Self {
        throw ElementError.noValue
    }

    // MARK: - Hierarchy

    public func children() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func childrenInNavigationOrder() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func visibleChildren() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func selectedChildren() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func window() async throws -> Self {
        throw ElementError.noValue
    }
    public func topLevelUIElement() async throws -> Self {
        throw ElementError.noValue
    }
    public func index() async throws -> Int {
        throw ElementError.noValue
    }

    // MARK: - Text

    public func placeholderValue() async throws -> String {
        throw ElementError.noValue
    }

    // MARK: - Text (Integer Indexed)

    func line(forIndex index: Int) async throws -> Int {
        throw ElementError.noValue
    }
    func range(forLine line: Int) async throws -> Range<Int> {
        throw ElementError.noValue
    }
    func range(forIndex index: Int) async throws -> Range<Int> {
        throw ElementError.noValue
    }
    func range(forPosition position: Int) async throws -> Range<Int> {
        throw ElementError.noValue
    }
    func string(for range: Range<Int>) async throws -> String {
        throw ElementError.noValue
    }
    func bounds(for range: Range<Int>) async throws -> NSRect {
        throw ElementError.noValue
    }
    func rtf(for range: Range<Int>) async throws -> Data {
        throw ElementError.noValue
    }
    func attributedString(for range: Range<Int>) async throws -> NSAttributedString {
        throw ElementError.noValue
    }
    func styleRange(for index: Int) async throws -> Range<Int> {
        throw ElementError.noValue
    }
    func insertionPointLineNumber() async throws -> Int {
        throw ElementError.noValue
    }
    func sharedCharacterRange() async throws -> Range<Int> {
        throw ElementError.noValue
    }
    func sharedTextUIElements() async throws -> [Self] {
        throw ElementError.noValue
    }
    func visibleCharacterRange() async throws -> Range<Int> {
        throw ElementError.noValue
    }
    func setVisibleCharacterRange(_ range: Range<Int>) async throws {
        throw ElementError.noValue
    }
    func numberOfCharacters() async throws -> Int {
        throw ElementError.noValue
    }
    func selectedText() async throws -> String {
        throw ElementError.noValue
    }
    func selectedTextRange() async throws -> Range<Int> {
        throw ElementError.noValue
    }
    func selectedTextRanges() async throws -> [Range<Int>] {
        throw ElementError.noValue
    }

    // MARK: - Text (TextMarker Indexed)

    /// The line number of the specified marker.
    func line(forTextMarker textMarker: TextMarker) async throws -> Int {
        throw ElementError.noValue
    }

    // MARK: - Table/Outline/Grid/List/Collection

    public func visibleRows() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func visibleRowsView() async throws -> ArrayAttributeView<Self> {
        throw ElementError.noValue
    }
    public func visibleColumns() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func visibleColumnsView() async throws -> ArrayAttributeView<Self> {
        throw ElementError.noValue
    }
    public func visibleCells() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func visibleCellsView() async throws -> ArrayAttributeView<Self> {
        throw ElementError.noValue
    }
    public func rowHeaderUIElements() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func rowHeaderUIElementsView() async throws -> ArrayAttributeView<Self> {
        throw ElementError.noValue
    }
    public func columnHeaderUIElements() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func columnHeaderUIElementsView() async throws -> ArrayAttributeView<Self> {
        throw ElementError.noValue
    }
    public func columnTitles() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func columnTitlesView() async throws -> ArrayAttributeView<Self> {
        throw ElementError.noValue
    }
    public func sortDirection() async throws -> String {
        throw ElementError.noValue
    }
    public func rowCount() async throws -> Int {
        throw ElementError.noValue
    }
    public func columnCount() async throws -> Int {
        throw ElementError.noValue
    }
    public func isOrderedByRow() async throws -> Bool {
        throw ElementError.noValue
    }
    public func rowIndexRange() async throws -> Range<Int> {
        throw ElementError.noValue
    }
    public func columnIndexRange() async throws -> Range<Int> {
        throw ElementError.noValue
    }

    // MARK: - Linked Elements

    public func linkedUIElements() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func servesAsTitleForUIElements() async throws -> [Self] {
        throw ElementError.noValue
    }

    // MARK: - Slider

    public func minValue() async throws -> Any {
        throw ElementError.noValue
    }
    public func maxValue() async throws -> Any {
        throw ElementError.noValue
    }
    public func warningValue() async throws -> Any {
        throw ElementError.noValue
    }
    public func criticalValue() async throws -> Any {
        throw ElementError.noValue
    }
    public func allowedValues() async throws -> [Double] {
        throw ElementError.noValue
    }
    public func labelUIElements() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func labelValue() async throws -> Double {
        throw ElementError.noValue
    }

    // MARK: - Window

    public func isMain() async throws -> Bool {
        throw ElementError.noValue
    }
    public func isMinimized() async throws -> Bool {
        throw ElementError.noValue
    }
    public func isModal() async throws -> Bool {
        throw ElementError.noValue
    }
    public func closeButton() async throws -> Self {
        throw ElementError.noValue
    }
    public func zoomButton() async throws -> Self {
        throw ElementError.noValue
    }
    public func minimizeButton() async throws -> Self {
        throw ElementError.noValue
    }
    public func toolbarButton() async throws -> Self {
        throw ElementError.noValue
    }
    public func fullScreenButton() async throws -> Self {
        throw ElementError.noValue
    }
    public func defaultButton() async throws -> Self {
        throw ElementError.noValue
    }
    public func cancelButton() async throws -> Self {
        throw ElementError.noValue
    }
    public func proxy() async throws -> Self {
        throw ElementError.noValue
    }
    public func growArea() async throws -> Self {
        throw ElementError.noValue
    }

    // MARK: - Container / scroll UI

    public func header() async throws -> Self {
        throw ElementError.noValue
    }
    public func tabs() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func splitters() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func horizontalScrollBar() async throws -> Self {
        throw ElementError.noValue
    }
    public func verticalScrollBar() async throws -> Self {
        throw ElementError.noValue
    }
    public func overflowButton() async throws -> Self {
        throw ElementError.noValue
    }
    public func incrementButton() async throws -> Self {
        throw ElementError.noValue
    }
    public func decrementButton() async throws -> Self {
        throw ElementError.noValue
    }
    public func previousContents() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func nextContents() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func previousContentSibling() async throws -> Self {
        throw ElementError.noValue
    }
    public func nextContentSibling() async throws -> Self {
        throw ElementError.noValue
    }
    public func contentSiblingAbove() async throws -> Self {
        throw ElementError.noValue
    }
    public func contentSiblingBelow() async throws -> Self {
        throw ElementError.noValue
    }
    public func firstContentSibling() async throws -> Self {
        throw ElementError.noValue
    }
    public func lastContentSibling() async throws -> Self {
        throw ElementError.noValue
    }
    public func shownMenu() async throws -> Self {
        throw ElementError.noValue
    }
    public func searchButton() async throws -> Self {
        throw ElementError.noValue
    }
    public func searchMenu() async throws -> Self {
        throw ElementError.noValue
    }
    public func clearButton() async throws -> Self {
        throw ElementError.noValue
    }

    // MARK: - Outline / tree

    public func isDisclosing() async throws -> Bool {
        throw ElementError.noValue
    }
    public func disclosedRows() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func disclosedByRow() async throws -> Self {
        throw ElementError.noValue
    }
    public func disclosureLevel() async throws -> Int {
        throw ElementError.noValue
    }

    // MARK: - Misc

    public func identifier() async throws -> String {
        throw ElementError.noValue
    }
    public func url() async throws -> URL {
        throw ElementError.noValue
    }
    public func document() async throws -> String {
        throw ElementError.noValue
    }
    public func filename() async throws -> String {
        throw ElementError.noValue
    }
    public func orientation() async throws -> String {
        throw ElementError.noValue
    }
    public func contents() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func sharedFocusElements() async throws -> [Self] {
        throw ElementError.noValue
    }
    public func isExpanded() async throws -> Bool {
        throw ElementError.noValue
    }
    public func isEdited() async throws -> Bool {
        throw ElementError.noValue
    }
    public func isRequired() async throws -> Bool {
        throw ElementError.noValue
    }
    public func containsProtectedContent() async throws -> Bool {
        throw ElementError.noValue
    }
    public func activationPoint() async throws -> CGPoint {
        throw ElementError.noValue
    }
}

extension Element {
    public var debugDescription: String {
        "<Element>"
    }
}
