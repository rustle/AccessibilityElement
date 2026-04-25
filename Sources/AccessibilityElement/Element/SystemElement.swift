//
//  SystemElement.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AppKit
import AX

public struct SystemElement: Element, Sendable {
    public static func systemWide() throws -> SystemElement {
        .init(element: UIElement.systemWide())
    }

    public static func application(processIdentifier: pid_t) throws -> SystemElement {
        .init(element: UIElement.application(pid: processIdentifier))
    }

    public var processIdentifier: pid_t {
        get throws {
            try element.pid
        }
    }

    // MARK: - General

    public func role() throws -> NSAccessibility.Role {
        try throwsAXError {
            try element.value(attribute: .role)
        }
    }
    public func roleDescription() throws -> String {
        try throwsAXError {
            try element.value(attribute: .roleDescription)
        }
    }
    public func subrole() throws -> NSAccessibility.Subrole {
        NSAccessibility.Subrole(rawValue:
            try throwsAXError({
                try element.value(attribute: .subrole)
            })
        )
    }
    public func value() throws -> Any {
        try throwsAXError {
            try element.value(attribute: .value)
        }
    }
    public func valueDescription() throws -> String {
        try throwsAXError {
            try element.value(attribute: .valueDescription)
        }
    }
    public func title() throws -> String {
        try throwsAXError {
            try element.value(attribute: .title)
        }
    }
    public func titleUIElement() throws -> SystemElement {
        try throwsAXError {
            try element.value(attribute: .titleUIElement)
        }
    }
    public func description() throws -> String {
        try throwsAXError {
            try element.value(attribute: .description)
        }
    }
    public func help() throws -> String {
        try throwsAXError {
            try element.value(attribute: .help)
        }
    }
    public func isEnabled() throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .enabled)
        }
    }
    public func isFocused() throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .focused)
        }
    }
    public func isSelected() throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .selected)
        }
    }

    // MARK: - Application Attributes

    public func windows() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .windows) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func mainWindow() throws -> SystemElement {
        .init(element:
            try throwsAXError({
                try element.value(attribute: .mainWindow)
            })
        )
    }
    public func focusedWindow() throws -> SystemElement {
        .init(element:
            try throwsAXError({
                try element.value(attribute: .focusedWindow)
            })
        )
    }
    public func focusedUIElement() throws -> SystemElement {
        .init(element:
            try throwsAXError({
                try element.value(attribute: .focusedUIElement)
            })
        )
    }
    public func enhancedUserInterface() throws -> Bool {
        try throwsAXError {
            (try element.value(attribute: .enhancedUserInterface) as Bool)
        }
    }
    public func setEnhancedUserInterface(_ enhancedUserInterface: Bool) throws {
        try throwsAXError {
            try element.set(attribute: .enhancedUserInterface,
                            value: enhancedUserInterface as CFBoolean)
        }
    }
    public func isFrontmost() throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .frontmost)
        }
    }
    public func isHidden() throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .hidden)
        }
    }
    public func menuBar() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .menuBar)
        })
    }
    public func extrasMenuBar() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .extrasMenuBar)
        })
    }

    // MARK: - Hierarchy

    public func parent() throws -> SystemElement {
        .init(element:
            try throwsAXError({
                try element.value(attribute: .parent)
            })
        )
    }
    public func children() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .children) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func childrenView() -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .children)
    }
    public func childrenInNavigationOrder() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .childrenInNavigationOrderAttribute) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func childrenInNavigationOrderView() -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .childrenInNavigationOrderAttribute)
    }
    public func visibleChildren() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .visibleChildren) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func visibleChildrenView() -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .visibleChildren)
    }
    public func selectedChildren() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .selectedChildren) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func selectedChildrenView() -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .selectedChildren)
    }
    public func window() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .window)
        })
    }
    public func topLevelUIElement() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .topLevelUIElement)
        })
    }
    public func index() throws -> Int {
        try throwsAXError {
            try element.value(attribute: .index)
        }
    }

    // MARK: - Actions

    public func actions() throws -> [NSAccessibility.Action] {
        try throwsAXError {
            try element.actions()
        }
    }
    public func description(action: NSAccessibility.Action) throws -> String {
        try throwsAXError {
            try element.description(action: action)
        }
    }
    public func perform(action: NSAccessibility.Action) throws {
        try throwsAXError {
            try element.perform(action: action)
        }
    }

    // MARK: - Text

    public func placeholderValue() throws -> String {
        try throwsAXError {
            try element.value(attribute: .placeholderValue)
        }
    }

    // MARK: - Text (Integer Indexed)

    public func line(forIndex index: Int) throws -> Int {
        try throwsAXError {
            try element.value(
                attribute: .lineForIndex,
                parameter: index as NSNumber
            )
        }
    }
    public func range(forLine line: Int) throws -> Range<Int> {
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
    public func range(forIndex index: Int) throws -> Range<Int> {
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
    public func range(forPosition position: Int) throws -> Range<Int> {
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
    public func string(for range: Range<Int>) throws -> String {
        try throwsAXError {
            try element.value(
                attribute: .stringForRange,
                parameter: Value.range(range).value
            )
        }
    }
    public func bounds(for range: Range<Int>) throws -> NSRect {
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
    public func rtf(for range: Range<Int>) throws -> Data {
        try throwsAXError {
            try element.value(
                attribute: .rtfForRange,
                parameter: Value.range(range).value
            )
        }
    }
    public func attributedString(for range: Range<Int>) throws -> NSAttributedString {
        try throwsAXError {
            try element.value(
                attribute: .attributedStringForRange,
                parameter: Value.range(range).value
            )
        }
    }
    public func styleRange(for index: Int) throws -> Range<Int> {
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
    public func insertionPointLineNumber() throws -> Int {
        try throwsAXError {
            try element.value(attribute: .insertionPointLineNumber)
        }
    }
    public func sharedCharacterRange() throws -> Range<Int> {
        try throwsAXError {
            let value = try Value(value: element.value(attribute: .sharedCharacterRange))
            guard case let .range(range) = value else { throw ElementError.noValue }
            return range
        }
    }
    public func sharedTextUIElements() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .sharedTextUIElements) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func visibleCharacterRange() throws -> Range<Int> {
        try throwsAXError {
            let value = try Value(value: element.value(attribute: .visibleCharacterRange))
            guard case let .range(range) = value else { throw ElementError.noValue }
            return range
        }
    }
    public func setVisibleCharacterRange(_ range: Range<Int>) throws {
        try throwsAXError {
            try element.set(attribute: .visibleCharacterRange, value: Value.range(range).value)
        }
    }
    public func numberOfCharacters() throws -> Int {
        try throwsAXError {
            try element.value(attribute: .numberOfCharacters)
        }
    }
    public func selectedText() throws -> String {
        try throwsAXError {
            try element.value(attribute: .selectedText)
        }
    }
    public func selectedTextRange() throws -> Range<Int> {
        try throwsAXError {
            let value = try Value(value: element.value(attribute: .selectedTextRange))
            guard case let .range(range) = value else { throw ElementError.noValue }
            return range
        }
    }
    public func selectedTextRanges() throws -> [Range<Int>] {
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

    public func line(forTextMarker textMarker: TextMarker) throws -> Int {
        try throwsAXError {
            try element.value(
                attribute: .lineForTextMarker,
                parameter: textMarker.textMarker
            )
        }
    }
    public func selectedTextMarkerRange() throws -> TextMarkerRange {
        try throwsAXError {
            TextMarkerRange(textMarkerRange: try element.value(attribute: .selectedTextMarkerRange))
        }
    }
    public func startTextMarker() throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(attribute: .startTextMarker))
        }
    }
    public func endTextMarker() throws -> TextMarker {
        try throwsAXError {
            TextMarker(textMarker: try element.value(attribute: .endTextMarker))
        }
    }
    public func lineTextMarkerRange(for textMarker: TextMarker) throws -> TextMarkerRange {
        try throwsAXError {
            TextMarkerRange(textMarkerRange: try element.value(
                attribute: .lineForTextMarker,
                parameter: textMarker.textMarker
            ))
        }
    }
    public func string(for textMarkerRange: TextMarkerRange) throws -> String {
        try throwsAXError {
            try element.value(
                attribute: .stringForTextMarkerRange,
                parameter: textMarkerRange.textMarkerRange
            )
        }
    }
    public func attributedString(for textMarkerRange: TextMarkerRange) throws -> NSAttributedString {
        try throwsAXError {
            try element.value(
                attribute: .attributedStringForTextMarkerRange,
                parameter: textMarkerRange.textMarkerRange
            )
        }
    }
    public func textMarkerRange(forUnordered textMarkers: [TextMarker]) throws -> TextMarkerRange {
        try throwsAXError {
            TextMarkerRange(textMarkerRange: try element.value(
                attribute: .textMarkerRangeForUnorderedTextMarkers,
                parameter: textMarkers.map(\.textMarker) as NSArray
            ))
        }
    }

    // MARK: - Table/Outline/Grid/List/Collection

    public func cell(
        column: Int,
        row: Int
    ) throws -> SystemElement {
        try throwsAXError {
            try element.value(
                attribute: .cellForColumnAndRow,
                parameter: [column as NSNumber, row as NSNumber]
            )
        }
    }
    public func rows() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .rows) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func rowsView() throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .rows)
    }
    public func columns() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .columns) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func columnsView() throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .columns)
    }
    public func selectedRows() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .selectedRows) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func selectedRowsView() throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .selectedRows)
    }
    public func selectedColumns() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .selectedColumns) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func selectedColumnsView() throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .selectedColumns)
    }
    public func selectedCells() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .selectedCells) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func selectedCellsView() throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .selectedCells)
    }
    public func visibleRows() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .visibleRows) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func visibleRowsView() throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .visibleRows)
    }
    public func visibleColumns() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .visibleColumns) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func visibleColumnsView() throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .visibleColumns)
    }
    public func visibleCells() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .visibleCells) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func visibleCellsView() throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .visibleCells)
    }
    public func rowHeaderUIElements() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .rowHeaderUIElements) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func rowHeaderUIElementsView() throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .rowHeaderUIElements)
    }
    public func columnHeaderUIElements() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .columnHeaderUIElements) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func columnHeaderUIElementsView() throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .columnHeaderUIElements)
    }
    public func columnTitles() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .columnTitles) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func columnTitlesView() throws -> ArrayAttributeView<SystemElement> {
        arrayAttributeView(attribute: .columnTitles)
    }
    public func sortDirection() throws -> String {
        try throwsAXError {
            try element.value(attribute: .sortDirection)
        }
    }
    public func rowCount() throws -> Int {
        try throwsAXError {
            try element.value(attribute: .rowCount)
        }
    }
    public func columnCount() throws -> Int {
        try throwsAXError {
            try element.value(attribute: .columnCount)
        }
    }
    public func isOrderedByRow() throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .orderedByRow)
        }
    }
    public func rowIndexRange() throws -> Range<Int> {
        try throwsAXError {
            let value = try Value(value: element.value(attribute: .rowIndexRange))
            guard case let .range(range) = value else { throw ElementError.noValue }
            return range
        }
    }
    public func columnIndexRange() throws -> Range<Int> {
        try throwsAXError {
            let value = try Value(value: element.value(attribute: .columnIndexRange))
            guard case let .range(range) = value else { throw ElementError.noValue }
            return range
        }
    }

    // MARK: - Layout

    public func frame() throws -> NSRect {
        try throwsAXError {
            let value = try Value(value: element.value(attribute: .frame))
            guard case let .rect(rect) = value else {
                throw ElementError.noValue
            }
            return rect
        }
    }
    public func setPosition(_ position: CGPoint) throws {
        try throwsAXError {
            try element.set(attribute: .position, value: Value.point(position).value)
        }
    }

    // MARK: - Linked Elements

    public func linkedUIElements() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .linkedUIElements) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func servesAsTitleForUIElements() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .servesAsTitleForUIElements) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }

    // MARK: - Slider

    public func minValue() throws -> Any {
        try throwsAXError {
            try element.value(attribute: .minValue)
        }
    }
    public func maxValue() throws -> Any {
        try throwsAXError {
            try element.value(attribute: .maxValue)
        }
    }
    public func warningValue() throws -> Any {
        try throwsAXError {
            try element.value(attribute: .warningValue)
        }
    }
    public func criticalValue() throws -> Any {
        try throwsAXError {
            try element.value(attribute: .criticalValue)
        }
    }
    public func allowedValues() throws -> [Double] {
        try throwsAXError {
            (try element.value(attribute: .allowedValues) as [NSNumber])
                .map(\.doubleValue)
        }
    }
    public func labelUIElements() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .labelUIElements) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func labelValue() throws -> Double {
        try throwsAXError {
            try element.value(attribute: .labelValue)
        }
    }

    // MARK: - Window

    public func isMain() throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .main)
        }
    }
    public func isMinimized() throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .minimized)
        }
    }
    public func isModal() throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .modal)
        }
    }
    public func closeButton() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .closeButton)
        })
    }
    public func zoomButton() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .zoomButton)
        })
    }
    public func minimizeButton() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .minimizeButton)
        })
    }
    public func toolbarButton() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .toolbarButton)
        })
    }
    public func fullScreenButton() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .fullScreenButton)
        })
    }
    public func defaultButton() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .defaultButton)
        })
    }
    public func cancelButton() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .cancelButton)
        })
    }
    public func proxy() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .proxy)
        })
    }
    public func growArea() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .growArea)
        })
    }

    // MARK: - Container / scroll UI

    public func header() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .header)
        })
    }
    public func tabs() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .tabs) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func splitters() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .splitters) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func horizontalScrollBar() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .horizontalScrollBar)
        })
    }
    public func verticalScrollBar() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .verticalScrollBar)
        })
    }
    public func overflowButton() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .overflowButton)
        })
    }
    public func incrementButton() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .incrementButton)
        })
    }
    public func decrementButton() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .decrementButton)
        })
    }
    public func previousContents() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .previousContents) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func nextContents() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .nextContents) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func shownMenu() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .shownMenu)
        })
    }
    public func searchButton() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .searchButton)
        })
    }
    public func searchMenu() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .searchMenu)
        })
    }
    public func clearButton() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .clearButton)
        })
    }

    // MARK: - Outline / tree

    public func isDisclosing() throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .disclosing)
        }
    }
    public func disclosedRows() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .disclosedRows) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func disclosedByRow() throws -> SystemElement {
        .init(element: try throwsAXError {
            try element.value(attribute: .disclosedByRow)
        })
    }
    public func disclosureLevel() throws -> Int {
        try throwsAXError {
            try element.value(attribute: .disclosureLevel)
        }
    }

    // MARK: - Misc

    public func identifier() throws -> String {
        try throwsAXError {
            try element.value(attribute: .identifier)
        }
    }
    public func url() throws -> URL {
        try throwsAXError {
            try element.value(attribute: .url)
        }
    }
    public func document() throws -> String {
        try throwsAXError {
            try element.value(attribute: .document)
        }
    }
    public func filename() throws -> String {
        try throwsAXError {
            try element.value(attribute: .filename)
        }
    }
    public func orientation() throws -> String {
        try throwsAXError {
            try element.value(attribute: .orientation)
        }
    }
    public func contents() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .contents) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func sharedFocusElements() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .sharedFocusElements) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }
    public func isExpanded() throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .expanded)
        }
    }
    public func isEdited() throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .edited)
        }
    }
    public func isRequired() throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .required)
        }
    }
    public func containsProtectedContent() throws -> Bool {
        try throwsAXError {
            try element.value(attribute: .containsProtectedContent)
        }
    }
    public func activationPoint() throws -> CGPoint {
        try throwsAXError {
            let value = try Value(value: element.value(attribute: .activationPoint))
            guard case let .point(point) = value else { throw ElementError.noValue }
            return point
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

    private func throwsAXError<T>(_ work: () throws -> T) rethrows -> T {
        do {
            return try work()
        } catch let error as AX.AXError {
            throw ElementError(error: error)
        } catch {
            throw error
        }
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

extension SystemElement {
    public var debugInfo: [String:any Sendable] {
        element.debugInfo
    }
}
