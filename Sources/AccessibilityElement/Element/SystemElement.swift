//
//  SystemElement.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AppKit
import AX

public struct SystemElement: Element, ArrayAttributeElement, Sendable {
    public static func systemWide() throws -> SystemElement {
        .init(element: UIElement.systemWide())
    }

    public static func application(processIdentifier: pid_t) throws -> SystemElement {
        .init(element: UIElement.application(pid: processIdentifier))
    }

    public var processIdentifier: pid_t {
        get async throws {
            try element.pid
        }
    }

    // MARK: - Serialization

    ///
    public func transportRepresentation() throws -> Data {
        try throwsAXError {
            try element.transportRepresentation()
        }
    }

    ///
    public init(transportRepresentation: Data) throws {
        element = try throwsAXError {
            try UIElement(transportRepresentation: transportRepresentation)
        }
    }

    // MARK: - General

    public func role() async throws -> NSAccessibility.Role {
        try throwsAXError {
            try element.value(attribute: .role)
        }
    }
    public func roleDescription() async throws -> String {
        try throwsAXError {
            try element.value(attribute: .roleDescription)
        }
    }
    public func subrole() async throws -> NSAccessibility.Subrole {
        NSAccessibility.Subrole(rawValue:
            try throwsAXError({
                try element.value(attribute: .subrole)
            })
        )
    }
    public func value() async throws -> Any {
        try throwsAXError {
            try element.value(attribute: .value)
        }
    }
    public func valueDescription() async throws -> String {
        try throwsAXError {
            try element.value(attribute: .valueDescription)
        }
    }
    public func title() async throws -> String {
        try throwsAXError {
            try element.value(attribute: .title)
        }
    }
    public func titleUIElement() async throws -> SystemElement {
        try throwsAXError {
            try element.value(attribute: .titleUIElement)
        }
    }
    public func description() async throws -> String {
        try throwsAXError {
            try element.value(attribute: .description)
        }
    }
    public func help() async throws -> String {
        try throwsAXError {
            try element.value(attribute: .help)
        }
    }
    public func isEnabled() async throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .enabled)
        }
    }
    public func isFocused() async throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .focused)
        }
    }
    public func isSelected() async throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .selected)
        }
    }

    // MARK: - Application Attributes

    public func windows() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .windows) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func mainWindow() async throws -> SystemElement {
        .init(element:
            try throwsAXError({
                try element.value(attribute: .mainWindow)
            })
        )
    }
    public func focusedWindow() async throws -> SystemElement {
        .init(element:
            try throwsAXError({
                try element.value(attribute: .focusedWindow)
            })
        )
    }
    public func focusedUIElement() async throws -> SystemElement {
        .init(element:
            try throwsAXError({
                try element.value(attribute: .focusedUIElement)
            })
        )
    }
    public func enhancedUserInterface() async throws -> Bool {
        try throwsAXError {
            (try element.value(attribute: .enhancedUserInterface) as Bool)
        }
    }
    public func setEnhancedUserInterface(_ enhancedUserInterface: Bool) async throws {
        try throwsAXError {
            try element.set(attribute: .enhancedUserInterface,
                            value: enhancedUserInterface as CFBoolean)
        }
    }
    public func isFrontmost() async throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .frontmost)
        }
    }
    public func isHidden() async throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .hidden)
        }
    }
    public func menuBar() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .menuBar)
        })
    }
    public func extrasMenuBar() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .extrasMenuBar)
        })
    }

    // MARK: - Hierarchy

    public func parent() async throws -> SystemElement {
        .init(element:
            try throwsAXError({
                try element.value(attribute: .parent)
            })
        )
    }
    public func children() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .children) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func childrenView() -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .children)
    }
    public func childrenInNavigationOrder() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .childrenInNavigationOrderAttribute) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func childrenInNavigationOrderView() -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .childrenInNavigationOrderAttribute)
    }
    public func visibleChildren() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .visibleChildren) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func visibleChildrenView() -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .visibleChildren)
    }
    public func selectedChildren() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .selectedChildren) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func selectedChildrenView() -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .selectedChildren)
    }
    public func window() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .window)
        })
    }
    public func topLevelUIElement() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .topLevelUIElement)
        })
    }
    public func index() async throws -> Int {
        try throwsAXError {
            try element.value(attribute: .index)
        }
    }

    // MARK: - Hierarchy (Web)

    public func focusableAncestor() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .focusableAncestor)
        })
    }
    public func editableAncestor() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .editableAncestor)
        })
    }
    public func highestEditableAncestor() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .highestEditableAncestor)
        })
    }

    // MARK: - Actions

    public func actions() async throws -> [NSAccessibility.Action] {
        try throwsAXError {
            try element.actions()
        }
    }
    public func description(action: NSAccessibility.Action) async throws -> String {
        try throwsAXError {
            try element.description(action: action)
        }
    }
    public func perform(action: NSAccessibility.Action) async throws {
        try throwsAXError {
            try element.perform(action: action)
        }
    }

    // MARK: - Text

    public func placeholderValue() async throws -> String {
        try throwsAXError {
            try element.value(attribute: .placeholderValue)
        }
    }

    // MARK: - Text (Integer Indexed)

    public func line(forIndex index: Int) async throws -> Int {
        try throwsAXError {
            try element.value(
                attribute: .lineForIndex,
                parameter: index as NSNumber
            )
        }
    }
    public func range(forLine line: Int) async throws -> Range<Int> {
        try throwsAXError {
            let value = try Value(value: element.value(
                attribute: .rangeForLine,
                parameter: line as NSNumber
            ))
            guard case let .range(range) = value else {
                throw ElementError.noValue
            }
            return range
        }
    }
    public func range(forIndex index: Int) async throws -> Range<Int> {
        try throwsAXError {
            let value = try Value(value: element.value(
                attribute: .rangeForIndex,
                parameter: index as NSNumber
            ))
            guard case let .range(range) = value else {
                throw ElementError.noValue
            }
            return range
        }
    }
    public func range(forPosition position: Int) async throws -> Range<Int> {
        try throwsAXError {
            let value = try Value(value: element.value(
                attribute: .rangeForPosition,
                parameter: position as NSNumber
            ))
            guard case let .range(range) = value else {
                throw ElementError.noValue
            }
            return range
        }
    }
    public func string(for range: Range<Int>) async throws -> String {
        try throwsAXError {
            try element.value(
                attribute: .stringForRange,
                parameter: Value.range(range).value
            )
        }
    }
    public func bounds(for range: Range<Int>) async throws -> NSRect {
        try throwsAXError {
            let value = try Value(value: element.value(
                attribute: .boundsForRange,
                parameter: Value.range(range).value
            ))
            guard case let .rect(rect) = value else {
                throw ElementError.noValue
            }
            return rect
        }
    }
    public func rtf(for range: Range<Int>) async throws -> Data {
        try throwsAXError {
            try element.value(
                attribute: .rtfForRange,
                parameter: Value.range(range).value
            )
        }
    }
    public func attributedString(for range: Range<Int>) async throws -> NSAttributedString {
        try throwsAXError {
            try element.value(
                attribute: .attributedStringForRange,
                parameter: Value.range(range).value
            )
        }
    }
    public func styleRange(for index: Int) async throws -> Range<Int> {
        try throwsAXError {
            let value = try Value(value: element.value(
                attribute: .styleRangeForIndex,
                parameter: index as NSNumber
            ))
            guard case let .range(range) = value else {
                throw ElementError.noValue
            }
            return range
        }
    }
    public func insertionPointLineNumber() async throws -> Int {
        try throwsAXError {
            try element.value(attribute: .insertionPointLineNumber)
        }
    }
    public func sharedCharacterRange() async throws -> Range<Int> {
        try throwsAXError {
            let value = try Value(value: element.value(attribute: .sharedCharacterRange))
            guard case let .range(range) = value else { throw ElementError.noValue }
            return range
        }
    }
    public func sharedTextUIElements() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .sharedTextUIElements) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func visibleCharacterRange() async throws -> Range<Int> {
        try throwsAXError {
            let value = try Value(value: element.value(attribute: .visibleCharacterRange))
            guard case let .range(range) = value else { throw ElementError.noValue }
            return range
        }
    }
    public func setVisibleCharacterRange(_ range: Range<Int>) async throws {
        try throwsAXError {
            try element.set(attribute: .visibleCharacterRange, value: Value.range(range).value)
        }
    }
    public func numberOfCharacters() async throws -> Int {
        try throwsAXError {
            try element.value(attribute: .numberOfCharacters)
        }
    }
    public func selectedText() async throws -> String {
        try throwsAXError {
            try element.value(attribute: .selectedText)
        }
    }
    public func selectedTextRange() async throws -> Range<Int> {
        try throwsAXError {
            let value = try Value(value: element.value(attribute: .selectedTextRange))
            guard case let .range(range) = value else { throw ElementError.noValue }
            return range
        }
    }
    public func selectedTextRanges() async throws -> [Range<Int>] {
        try throwsAXError {
            let axValues: [AXValue] = try element.value(attribute: .selectedTextRanges)
            return try axValues.map { axValue in
                let value = try Value(value: axValue)
                guard case let .range(range) = value else { throw ElementError.noValue }
                return range
            }
        }
    }

    // MARK: - Text (TextMarker Indexed)

    public func line(forTextMarker textMarker: TextMarker) async throws -> Int {
        try throwsAXError {
            try element.value(
                attribute: .lineForTextMarker,
                parameter: textMarker.textMarker
            )
        }
    }
    public func selectedTextMarkerRange() async throws -> TextMarkerRange {
        try throwsAXError {
            TextMarkerRange(textMarkerRange: try element.value(attribute: .selectedTextMarkerRange))
        }
    }
    public func startTextMarker() async throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(attribute: .startTextMarker))
        }
    }
    public func endTextMarker() async throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(attribute: .endTextMarker))
        }
    }
    public func nextTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(
                attribute: .nextTextMarkerForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func previousTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(
                attribute: .previousTextMarkerForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func nextWordEndTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(
                attribute: .nextWordEndTextMarkerForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func previousWordStartTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(
                attribute: .previousWordStartTextMarkerForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func nextLineEndTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(
                attribute: .nextLineEndTextMarkerForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func previousLineStartTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(
                attribute: .previousLineStartTextMarkerForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func nextSentenceEndTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(
                attribute: .nextSentenceEndTextMarkerForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func previousSentenceStartTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(
                attribute: .previousSentenceStartTextMarkerForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func nextParagraphEndTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(
                attribute: .nextParagraphEndTextMarkerForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func previousParagraphStartTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(
                attribute: .previousParagraphStartTextMarkerForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func lineTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        try throwsAXError {
            TextMarkerRange(textMarkerRange: try element.value(
                attribute: .lineForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func leftWordTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        try throwsAXError {
            TextMarkerRange(textMarkerRange: try element.value(
                attribute: .leftWordTextMarkerRangeForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func rightWordTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        try throwsAXError {
            TextMarkerRange(textMarkerRange: try element.value(
                attribute: .rightWordTextMarkerRangeForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func leftLineTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        try throwsAXError {
            TextMarkerRange(textMarkerRange: try element.value(
                attribute: .leftLineTextMarkerRangeForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func rightLineTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        try throwsAXError {
            TextMarkerRange(textMarkerRange: try element.value(
                attribute: .rightLineTextMarkerRangeForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func sentenceTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        try throwsAXError {
            TextMarkerRange(textMarkerRange: try element.value(
                attribute: .sentenceTextMarkerRangeForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func paragraphTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        try throwsAXError {
            TextMarkerRange(textMarkerRange: try element.value(
                attribute: .paragraphTextMarkerRangeForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func styleTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        try throwsAXError {
            TextMarkerRange(textMarkerRange: try element.value(
                attribute: .styleTextMarkerRangeForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func lineNumber(for textMarker: TextMarker) async throws -> Int {
        try throwsAXError {
            try element.value(
                attribute: .lineNumberForTextMarker,
                parameter: textMarker.textMarker
            )
        }
    }
    public func index(for textMarker: TextMarker) async throws -> Int {
        try throwsAXError {
            try element.value(
                attribute: .indexForTextMarker,
                parameter: textMarker.textMarker
            )
        }
    }
    public func element(for textMarker: TextMarker) async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(
                attribute: .uiElementForTextMarker,
                parameter: textMarker.textMarker
            )
        })
    }
    public func string(for textMarkerRange: TextMarkerRange) async throws -> String {
        try throwsAXError {
            try element.value(
                attribute: .stringForTextMarkerRange,
                parameter: textMarkerRange.textMarkerRange
            )
        }
    }
    public func attributedString(for textMarkerRange: TextMarkerRange) async throws -> NSAttributedString {
        try throwsAXError {
            try element.value(
                attribute: .attributedStringForTextMarkerRange,
                parameter: textMarkerRange.textMarkerRange
            )
        }
    }
    public func bounds(for textMarkerRange: TextMarkerRange) async throws -> NSRect {
        try throwsAXError {
            let value = try Value(value: element.value(
                attribute: .boundsForTextMarkerRange,
                parameter: textMarkerRange.textMarkerRange
            ))
            guard case let .rect(rect) = value else { throw ElementError.noValue }
            return rect
        }
    }
    public func length(for textMarkerRange: TextMarkerRange) async throws -> Int {
        try throwsAXError {
            try element.value(
                attribute: .lengthForTextMarkerRange,
                parameter: textMarkerRange.textMarkerRange
            )
        }
    }
    public func textMarker(forIndex index: Int) async throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(
                attribute: .textMarkerForIndex,
                parameter: index as NSNumber
            ))
        }
    }
    public func textMarkerRange(forLine line: Int) async throws -> TextMarkerRange {
        try throwsAXError {
            TextMarkerRange(textMarkerRange: try element.value(
                attribute: .textMarkerRangeForLine,
                parameter: line as NSNumber
            ))
        }
    }
    public func textMarker(forPosition position: CGPoint) async throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(
                attribute: .textMarkerForPosition,
                parameter: Value.point(position).value
            ))
        }
    }
    public func startTextMarker(forBounds bounds: NSRect) async throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(
                attribute: .startTextMarkerForBounds,
                parameter: Value.rect(bounds).value
            ))
        }
    }
    public func endTextMarker(forBounds bounds: NSRect) async throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(
                attribute: .endTextMarkerForBounds,
                parameter: Value.rect(bounds).value
            ))
        }
    }
    public func textMarkerRange(for systemElement: SystemElement) async throws -> TextMarkerRange {
        try throwsAXError {
            TextMarkerRange(textMarkerRange: try element.value(
                attribute: .textMarkerRangeForUIElement,
                parameter: systemElement.element
            ))
        }
    }
    public func textMarkerRange(forUnordered textMarkers: [TextMarker]) async throws -> TextMarkerRange {
        try throwsAXError {
            TextMarkerRange(textMarkerRange: try element.value(
                attribute: .textMarkerRangeForUnorderedTextMarkers,
                parameter: textMarkers.map(\.textMarker) as NSArray
            ))
        }
    }
    public func textMarkerRange(forOrdered textMarkers: [TextMarker]) async throws -> TextMarkerRange {
        try throwsAXError {
            TextMarkerRange(textMarkerRange: try element.value(
                attribute: .textMarkerRangeForOrderedTextMarkers,
                parameter: textMarkers.map(\.textMarker) as NSArray
            ))
        }
    }

    // MARK: - Text marker validation

    public func isNullTextMarker(_ textMarker: TextMarker) async throws -> Bool {
        try throwsAXError {
            try element.value(
                attribute: .textMarkerIsNull,
                parameter: textMarker.textMarker
            )
        }
    }
    public func isValidTextMarker(_ textMarker: TextMarker) async throws -> Bool {
        try throwsAXError {
            try element.value(
                attribute: .textMarkerIsValid,
                parameter: textMarker.textMarker
            )
        }
    }

    // MARK: - Table/Outline/Grid/List/Collection

    public func cell(
        column: Int,
        row: Int
    ) async throws -> SystemElement {
        try throwsAXError {
            try element.value(
                attribute: .cellForColumnAndRow,
                parameter: [column as NSNumber, row as NSNumber]
            )
        }
    }
    public func rows() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .rows) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func rowsView() async throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .rows)
    }
    public func columns() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .columns) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func columnsView() async throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .columns)
    }
    public func selectedRows() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .selectedRows) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func selectedRowsView() async throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .selectedRows)
    }
    public func selectedColumns() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .selectedColumns) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func selectedColumnsView() async throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .selectedColumns)
    }
    public func selectedCells() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .selectedCells) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func selectedCellsView() async throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .selectedCells)
    }
    public func visibleRows() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .visibleRows) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func visibleRowsView() async throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .visibleRows)
    }
    public func visibleColumns() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .visibleColumns) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func visibleColumnsView() async throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .visibleColumns)
    }
    public func visibleCells() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .visibleCells) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func visibleCellsView() async throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .visibleCells)
    }
    public func rowHeaderUIElements() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .rowHeaderUIElements) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func rowHeaderUIElementsView() async throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .rowHeaderUIElements)
    }
    public func columnHeaderUIElements() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .columnHeaderUIElements) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func columnHeaderUIElementsView() async throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .columnHeaderUIElements)
    }
    public func columnTitles() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .columnTitles) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func columnTitlesView() async throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .columnTitles)
    }
    public func sortDirection() async throws -> String {
        try throwsAXError {
            try element.value(attribute: .sortDirection)
        }
    }
    public func rowCount() async throws -> Int {
        try throwsAXError {
            try element.value(attribute: .rowCount)
        }
    }
    public func columnCount() async throws -> Int {
        try throwsAXError {
            try element.value(attribute: .columnCount)
        }
    }
    public func isOrderedByRow() async throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .orderedByRow)
        }
    }
    public func rowIndexRange() async throws -> Range<Int> {
        try throwsAXError {
            let value = try Value(value: element.value(attribute: .rowIndexRange))
            guard case let .range(range) = value else { throw ElementError.noValue }
            return range
        }
    }
    public func columnIndexRange() async throws -> Range<Int> {
        try throwsAXError {
            let value = try Value(value: element.value(attribute: .columnIndexRange))
            guard case let .range(range) = value else { throw ElementError.noValue }
            return range
        }
    }

    // MARK: - Layout

    public func frame() async throws -> NSRect {
        try throwsAXError {
            let value = try Value(value: element.value(attribute: .frame))
            guard case let .rect(rect) = value else {
                throw ElementError.noValue
            }
            return rect
        }
    }
    public func setPosition(_ position: CGPoint) async throws {
        try throwsAXError {
            try element.set(attribute: .position, value: Value.point(position).value)
        }
    }

    // MARK: - Linked Elements

    public func linkedUIElements() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .linkedUIElements) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func servesAsTitleForUIElements() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .servesAsTitleForUIElements) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }

    // MARK: - Slider

    public func minValue() async throws -> Any {
        try throwsAXError {
            try element.value(attribute: .minValue)
        }
    }
    public func maxValue() async throws -> Any {
        try throwsAXError {
            try element.value(attribute: .maxValue)
        }
    }
    public func warningValue() async throws -> Any {
        try throwsAXError {
            try element.value(attribute: .warningValue)
        }
    }
    public func criticalValue() async throws -> Any {
        try throwsAXError {
            try element.value(attribute: .criticalValue)
        }
    }
    public func allowedValues() async throws -> [Double] {
        try throwsAXError {
            (try element.value(attribute: .allowedValues) as [NSNumber])
                .map(\.doubleValue)
        }
    }
    public func labelUIElements() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .labelUIElements) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func labelValue() async throws -> Double {
        try throwsAXError {
            try element.value(attribute: .labelValue)
        }
    }

    // MARK: - Window

    public func isMain() async throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .main)
        }
    }
    public func isMinimized() async throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .minimized)
        }
    }
    public func isModal() async throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .modal)
        }
    }
    public func closeButton() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .closeButton)
        })
    }
    public func zoomButton() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .zoomButton)
        })
    }
    public func minimizeButton() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .minimizeButton)
        })
    }
    public func toolbarButton() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .toolbarButton)
        })
    }
    public func fullScreenButton() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .fullScreenButton)
        })
    }
    public func defaultButton() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .defaultButton)
        })
    }
    public func cancelButton() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .cancelButton)
        })
    }
    public func proxy() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .proxy)
        })
    }
    public func growArea() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .growArea)
        })
    }

    // MARK: - Container / scroll UI

    public func header() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .header)
        })
    }
    public func tabs() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .tabs) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func splitters() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .splitters) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func horizontalScrollBar() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .horizontalScrollBar)
        })
    }
    public func verticalScrollBar() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .verticalScrollBar)
        })
    }
    public func overflowButton() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .overflowButton)
        })
    }
    public func incrementButton() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .incrementButton)
        })
    }
    public func decrementButton() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .decrementButton)
        })
    }
    public func previousContents() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .previousContents) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func nextContents() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .nextContents) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func shownMenu() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .shownMenu)
        })
    }
    public func searchButton() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .searchButton)
        })
    }
    public func searchMenu() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .searchMenu)
        })
    }
    public func clearButton() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .clearButton)
        })
    }

    // MARK: - Outline / tree

    public func isDisclosing() async throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .disclosing)
        }
    }
    public func disclosedRows() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .disclosedRows) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func disclosedByRow() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .disclosedByRow)
        })
    }
    public func disclosureLevel() async throws -> Int {
        try throwsAXError {
            try element.value(attribute: .disclosureLevel)
        }
    }

    // MARK: - Misc

    public func identifier() async throws -> String {
        try throwsAXError {
            try element.value(attribute: .identifier)
        }
    }
    public func url() async throws -> URL {
        try throwsAXError {
            try element.value(attribute: .url)
        }
    }
    public func document() async throws -> String {
        try throwsAXError {
            try element.value(attribute: .document)
        }
    }
    public func filename() async throws -> String {
        try throwsAXError {
            try element.value(attribute: .filename)
        }
    }
    public func orientation() async throws -> String {
        try throwsAXError {
            try element.value(attribute: .orientation)
        }
    }
    public func contents() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .contents) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func sharedFocusElements() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .sharedFocusElements) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func isExpanded() async throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .expanded)
        }
    }
    public func isEdited() async throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .edited)
        }
    }
    public func isRequired() async throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .required)
        }
    }
    public func containsProtectedContent() async throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .containsProtectedContent)
        }
    }
    public func activationPoint() async throws -> CGPoint {
        try throwsAXError {
            let value = try Value(value: element.value(attribute: .activationPoint))
            guard case let .point(point) = value else { throw ElementError.noValue }
            return point
        }
    }

    // MARK: - Web

    public func isLoaded() async throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .loaded)
        }
    }
    public func loadingProgress() async throws -> Double {
        try throwsAXError {
            try element.value(attribute: .loadingProgress)
        }
    }
    public func layoutCount() async throws -> Int {
        try throwsAXError {
            try element.value(attribute: .layoutCount)
        }
    }
    public func preventKeyboardDOMEventDispatch() async throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .preventKeyboardDOMEventDispatch)
        }
    }

    // MARK: - MathML

    public func mathBase() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .mathBase)
        })
    }
    public func mathFencedOpen() async throws -> String {
        try throwsAXError {
            try element.value(attribute: .mathFencedOpen)
        }
    }
    public func mathFencedClose() async throws -> String {
        try throwsAXError {
            try element.value(attribute: .mathFencedClose)
        }
    }
    public func mathFractionNumerator() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .mathFractionNumerator)
        })
    }
    public func mathFractionDenominator() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .mathFractionDenominator)
        })
    }
    public func mathLineThickness() async throws -> Double {
        try throwsAXError {
            try element.value(attribute: .mathLineThickness)
        }
    }
    public func mathOver() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .mathOver)
        })
    }
    public func mathUnder() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .mathUnder)
        })
    }
    public func mathPostscripts() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .mathPostscripts) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func mathPrescripts() async throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .mathPrescripts) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func mathRootIndex() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .mathRootIndex)
        })
    }
    public func mathRootRadicand() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .mathRootRadicand)
        })
    }
    public func mathSubscript() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .mathSubscript)
        })
    }
    public func mathSuperscript() async throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .mathSuperscript)
        })
    }

    // Array Attribute Accessors

    public func count(attribute: NSAccessibility.Attribute) throws -> Int {
        try throwsAXError {
            try element.count(attribute: attribute)
        }
    }

    public func elements(
        attribute: NSAccessibility.Attribute,
        index: Int,
        maxCount: Int
    ) throws -> [Self] {
        try throwsAXError {
            let values = try element.values(
                attribute: attribute,
                index: index,
                maxCount: maxCount
            ) as [UIElement]
            return values.map(SystemElement.init(element:))
        }
    }

    // MARK: - Private

    let element: UIElement
    init(element: UIElement) {
        self.element = element
    }
    
    private func arrayAttributeView(attribute: NSAccessibility.Attribute) -> ArrayAttributeView<SystemElement> {
        ArrayAttributeView(
            count: {
                try throwsAXError {
                    try element.count(attribute: attribute)
                }
            },
            elements: { index, maxCount in
                try throwsAXError {
                    let values = try element.values(
                        attribute: attribute,
                        index: index,
                        maxCount: maxCount
                    ) as [UIElement]
                    return values.map(SystemElement.init(element:))
                }
            }
        )
    }
}

private func throwsAXError<T>(_ work: () throws -> T) rethrows -> T {
    do {
        return try work()
    } catch let error as AX.AXError {
        throw ElementError(error: error)
    } catch {
        throw error
    }
}

extension SystemElement: Hashable {
    public static func ==(lhs: SystemElement,
                          rhs: SystemElement) -> Bool {
        lhs.element == rhs.element
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(element)
    }
}

extension SystemElement: Codable {}

extension SystemElement {
    public var debugInfo: [String:any Sendable] {
        element.debugInfo
    }
}

extension SystemElement {
    public var debugDescription: String {
        var description = [String]()
        description.reserveCapacity(3)
        func append(_ prefix: String,
                    _ attribute: () throws -> Any) {
            guard let value = try? attribute() else {
                return
            }
            description.append(prefix)
            description.append(String(describing: value))
        }
        // TODO: Use Role and Subrole to pick other attributes to grab
        append("Role:", { try element.value(attribute: .role) }) // 1
        append("Subrole:", { try element.value(attribute: .subrole) }) // 2
        append("Title:", { try element.value(attribute: .title) }) // 3
        return "<SystemElement \(description.joined(separator: " "))>"
    }
}
