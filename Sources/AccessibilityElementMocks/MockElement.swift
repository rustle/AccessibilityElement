//
//  MockElement.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AccessibilityElement
import AppKit
import AX
import os

public final class MockElement: Element, Hashable, Sendable {
    public static func == (
        lhs: MockElement,
        rhs: MockElement
    ) -> Bool {
        lhs === rhs
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    public var processIdentifier: pid_t {
        get throws { _pid }
    }

    // MARK: - General

    public func role() throws -> NSAccessibility.Role {
        try getAttribute(.role)
    }
    public func roleDescription() throws -> String {
        try getAttribute(.roleDescription)
    }
    public func subrole() throws -> NSAccessibility.Subrole {
        try getAttribute(.subrole)
    }
    public func value() throws -> Any {
        try getAttribute(.value)
    }
    public func valueDescription() throws -> String {
        try getAttribute(.valueDescription)
    }
    public func title() throws -> String {
        try getAttribute(.title)
    }
    public func titleUIElement() throws -> MockElement {
        try getAttribute(.titleUIElement)
    }
    public func description() throws -> String {
        try getAttribute(.description)
    }
    public func help() throws -> String {
        try getAttribute(.help)
    }
    public func isEnabled() throws -> Bool {
        try getAttribute(.enabled)
    }
    public func isFocused() throws -> Bool {
        try getAttribute(.focused)
    }
    public func isSelected() throws -> Bool {
        try getAttribute(.selected)
    }

    // MARK: - Application Attributes

    public func windows() throws -> [MockElement] {
        try getAttribute(.windows)
    }
    public func mainWindow() throws -> MockElement {
        try getAttribute(.mainWindow)
    }
    public func focusedWindow() throws -> MockElement {
        try getAttribute(.focusedWindow)
    }
    public func focusedUIElement() throws -> MockElement {
        try getAttribute(.focusedUIElement)
    }
    public func enhancedUserInterface() throws -> Bool {
        try getAttribute(.enhancedUserInterface)
    }
    public func setEnhancedUserInterface(_ enhancedUserInterface: Bool) throws {
        try setAttribute(enhancedUserInterface,
                         for: .enhancedUserInterface)
    }
    public func isFrontmost() throws -> Bool {
        try getAttribute(.frontmost)
    }
    public func isHidden() throws -> Bool {
        try getAttribute(.hidden)
    }
    public func menuBar() throws -> MockElement {
        try getAttribute(.menuBar)
    }
    public func extrasMenuBar() throws -> MockElement {
        try getAttribute(.extrasMenuBar)
    }

    // MARK: - Hierarchy

    public func parent() throws -> MockElement {
        try getAttribute(.parent)
    }
    public func children() throws -> [MockElement] {
        try getAttribute(.children)
    }
    public func childrenInNavigationOrder() throws -> [MockElement] {
        try getAttribute(.childrenInNavigationOrderAttribute)
    }
    public func visibleChildren() throws -> [MockElement] {
        try getAttribute(.visibleChildren)
    }
    public func selectedChildren() throws -> [MockElement] {
        try getAttribute(.selectedChildren)
    }
    public func childrenView() -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { try self.children().count },
            elements: { i, n in let a = try self.children(); return Array(a[i..<min(i + n, a.count)]) }
        )
    }
    public func childrenInNavigationOrderView() -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { try self.childrenInNavigationOrder().count },
            elements: { i, n in let a = try self.childrenInNavigationOrder(); return Array(a[i..<min(i + n, a.count)]) }
        )
    }
    public func visibleChildrenView() -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { try self.visibleChildren().count },
            elements: { i, n in let a = try self.visibleChildren(); return Array(a[i..<min(i + n, a.count)]) }
        )
    }
    public func selectedChildrenView() -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { try self.selectedChildren().count },
            elements: { i, n in let a = try self.selectedChildren(); return Array(a[i..<min(i + n, a.count)]) }
        )
    }
    public func window() throws -> MockElement {
        try getAttribute(.window)
    }
    public func topLevelUIElement() throws -> MockElement {
        try getAttribute(.topLevelUIElement)
    }
    public func index() throws -> Int {
        try getAttribute(.index)
    }

    // MARK: - Actions

    public func actions() throws -> [NSAccessibility.Action] {
        []
    }
    public func description(action: NSAccessibility.Action) throws -> String {
        ""
    }
    public func perform(action: NSAccessibility.Action) throws {
    }

    // MARK: - Text

    public func placeholderValue() throws -> String {
        try getAttribute(.placeholderValue)
    }

    // MARK: - Text (Integer Indexed)

    public func line(forIndex index: Int) throws -> Int {
        guard let handler = lineForIndexHandler else { throw ElementError.noValue }
        return try handler(self, index)
    }
    public func range(forLine line: Int) throws -> Range<Int> {
        guard let handler = rangeForLineHandler else { throw ElementError.noValue }
        return try handler(self, line)
    }
    public func range(forIndex index: Int) throws -> Range<Int> {
        throw ElementError.noValue
    }
    public func range(forPosition position: Int) throws -> Range<Int> {
        throw ElementError.noValue
    }
    public func string(for range: Range<Int>) throws -> String {
        guard let handler = stringForRangeHandler else { throw ElementError.noValue }
        return try handler(self, range)
    }
    public func bounds(for range: Range<Int>) throws -> NSRect {
        guard let handler = boundsForRangeHandler else { throw ElementError.noValue }
        return try handler(self, range)
    }
    public func rtf(for range: Range<Int>) throws -> Data {
        throw ElementError.noValue
    }
    public func attributedString(for range: Range<Int>) throws -> NSAttributedString {
        throw ElementError.noValue
    }
    public func styleRange(for index: Int) throws -> Range<Int> {
        throw ElementError.noValue
    }
    public func insertionPointLineNumber() throws -> Int {
        try getAttribute(.insertionPointLineNumber)
    }
    public func sharedCharacterRange() throws -> Range<Int> {
        throw ElementError.noValue
    }
    public func sharedTextUIElements() throws -> [MockElement] {
        throw ElementError.noValue
    }
    public func visibleCharacterRange() throws -> Range<Int> {
        try getAttribute(.visibleCharacterRange)
    }
    public func setVisibleCharacterRange(_ range: Range<Int>) throws {
        try setAttribute(range,
                         for: .visibleCharacterRange)
    }
    public func numberOfCharacters() throws -> Int {
        try getAttribute(.numberOfCharacters)
    }
    public func selectedText() throws -> String {
        try getAttribute(.selectedText)
    }
    public func selectedTextRange() throws -> Range<Int> {
        try getAttribute(.selectedTextRange)
    }
    public func selectedTextRanges() throws -> [Range<Int>] {
        throw ElementError.noValue
    }

    // MARK: - Text (TextMarker Indexed)

    public func line(forTextMarker textMarker: TextMarker) throws -> Int {
        throw ElementError.noValue
    }
    public func selectedTextMarkerRange() throws -> TextMarkerRange {
        try getAttribute(.selectedTextMarkerRange)
    }
    public func startTextMarker() throws -> TextMarker {
        try getAttribute(.startTextMarker)
    }
    public func endTextMarker() throws -> TextMarker {
        try getAttribute(.endTextMarker)
    }

    // MARK: - Table/Outline/Grid/List/Collection

    public func cell(
        column: Int,
        row: Int
    ) throws -> SystemElement {
        throw ElementError.noValue
    }
    public func rows() throws -> [MockElement] {
        try getAttribute(.rows)
    }
    public func columns() throws -> [MockElement] {
        try getAttribute(.columns)
    }
    public func selectedRows() throws -> [MockElement] {
        try getAttribute(.selectedRows)
    }
    public func selectedColumns() throws -> [MockElement] {
        try getAttribute(.selectedColumns)
    }
    public func selectedCells() throws -> [MockElement] {
        try getAttribute(.selectedCells)
    }
    public func visibleRows() throws -> [MockElement] {
        try getAttribute(.visibleRows)
    }
    public func visibleColumns() throws -> [MockElement] {
        try getAttribute(.visibleColumns)
    }
    public func visibleCells() throws -> [MockElement] {
        try getAttribute(.visibleCells)
    }
    public func rowHeaderUIElements() throws -> [MockElement] {
        try getAttribute(.rowHeaderUIElements)
    }
    public func columnHeaderUIElements() throws -> [MockElement] {
        try getAttribute(.columnHeaderUIElements)
    }
    public func columnTitles() throws -> [MockElement] {
        try getAttribute(.columnTitles)
    }
    public func rowsView() throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { try self.rows().count },
            elements: { i, n in let a = try self.rows(); return Array(a[i..<min(i + n, a.count)]) }
        )
    }
    public func columnsView() throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { try self.columns().count },
            elements: { i, n in let a = try self.columns(); return Array(a[i..<min(i + n, a.count)]) }
        )
    }
    public func selectedRowsView() throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { try self.selectedRows().count },
            elements: { i, n in let a = try self.selectedRows(); return Array(a[i..<min(i + n, a.count)]) }
        )
    }
    public func selectedColumnsView() throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { try self.selectedColumns().count },
            elements: { i, n in let a = try self.selectedColumns(); return Array(a[i..<min(i + n, a.count)]) }
        )
    }
    public func selectedCellsView() throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { try self.selectedCells().count },
            elements: { i, n in let a = try self.selectedCells(); return Array(a[i..<min(i + n, a.count)]) }
        )
    }
    public func visibleRowsView() throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { try self.visibleRows().count },
            elements: { i, n in let a = try self.visibleRows(); return Array(a[i..<min(i + n, a.count)]) }
        )
    }
    public func visibleColumnsView() throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { try self.visibleColumns().count },
            elements: { i, n in let a = try self.visibleColumns(); return Array(a[i..<min(i + n, a.count)]) }
        )
    }
    public func visibleCellsView() throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { try self.visibleCells().count },
            elements: { i, n in let a = try self.visibleCells(); return Array(a[i..<min(i + n, a.count)]) }
        )
    }
    public func rowHeaderUIElementsView() throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { try self.rowHeaderUIElements().count },
            elements: { i, n in let a = try self.rowHeaderUIElements(); return Array(a[i..<min(i + n, a.count)]) }
        )
    }
    public func columnHeaderUIElementsView() throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { try self.columnHeaderUIElements().count },
            elements: { i, n in let a = try self.columnHeaderUIElements(); return Array(a[i..<min(i + n, a.count)]) }
        )
    }
    public func columnTitlesView() throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { try self.columnTitles().count },
            elements: { i, n in let a = try self.columnTitles(); return Array(a[i..<min(i + n, a.count)]) }
        )
    }
    public func sortDirection() throws -> String {
        try getAttribute(.sortDirection)
    }
    public func rowCount() throws -> Int {
        try getAttribute(.rowCount)
    }
    public func columnCount() throws -> Int {
        try getAttribute(.columnCount)
    }
    public func isOrderedByRow() throws -> Bool {
        try getAttribute(.orderedByRow)
    }
    public func rowIndexRange() throws -> Range<Int> {
        try getAttribute(.rowIndexRange)
    }
    public func columnIndexRange() throws -> Range<Int> {
        try getAttribute(.columnIndexRange)
    }

    // MARK: - Layout

    public func frame() throws -> NSRect {
        try getAttribute(.frame)
    }
    public func setPosition(_ position: CGPoint) throws {
        guard let handler = setPositionHandler else { throw ElementError.noValue }
        try handler(self, position)
    }

    // MARK: - Linked Elements

    public func linkedUIElements() throws -> [MockElement] {
        try getAttribute(.linkedUIElements)
    }
    public func servesAsTitleForUIElements() throws -> [MockElement] {
        try getAttribute(.servesAsTitleForUIElements)
    }

    // MARK: - Slider

    public func minValue() throws -> Any {
        try getAttribute(.minValue)
    }
    public func maxValue() throws -> Any {
        try getAttribute(.maxValue)
    }
    public func warningValue() throws -> Any {
        try getAttribute(.warningValue)
    }
    public func criticalValue() throws -> Any {
        try getAttribute(.criticalValue)
    }
    public func allowedValues() throws -> [Double] {
        try getAttribute(.allowedValues)
    }
    public func labelUIElements() throws -> [MockElement] {
        try getAttribute(.labelUIElements)
    }
    public func labelValue() throws -> Double {
        try getAttribute(.labelValue)
    }

    // MARK: - Window

    public func isMain() throws -> Bool {
        try getAttribute(.main)
    }
    public func isMinimized() throws -> Bool {
        try getAttribute(.minimized)
    }
    public func isModal() throws -> Bool {
        try getAttribute(.modal)
    }
    public func closeButton() throws -> MockElement {
        try getAttribute(.closeButton)
    }
    public func zoomButton() throws -> MockElement {
        try getAttribute(.zoomButton)
    }
    public func minimizeButton() throws -> MockElement {
        try getAttribute(.minimizeButton)
    }
    public func toolbarButton() throws -> MockElement {
        try getAttribute(.toolbarButton)
    }
    public func fullScreenButton() throws -> MockElement {
        try getAttribute(.fullScreenButton)
    }
    public func defaultButton() throws -> MockElement {
        try getAttribute(.defaultButton)
    }
    public func cancelButton() throws -> MockElement {
        try getAttribute(.cancelButton)
    }
    public func proxy() throws -> MockElement {
        try getAttribute(.proxy)
    }
    public func growArea() throws -> MockElement {
        try getAttribute(.growArea)
    }

    // MARK: - Container / scroll UI

    public func header() throws -> MockElement {
        try getAttribute(.header)
    }
    public func tabs() throws -> [MockElement] {
        try getAttribute(.tabs)
    }
    public func splitters() throws -> [MockElement] {
        try getAttribute(.splitters)
    }
    public func horizontalScrollBar() throws -> MockElement {
        try getAttribute(.horizontalScrollBar)
    }
    public func verticalScrollBar() throws -> MockElement {
        try getAttribute(.verticalScrollBar)
    }
    public func overflowButton() throws -> MockElement {
        try getAttribute(.overflowButton)
    }
    public func incrementButton() throws -> MockElement {
        try getAttribute(.incrementButton)
    }
    public func decrementButton() throws -> MockElement {
        try getAttribute(.decrementButton)
    }
    public func previousContents() throws -> [MockElement] {
        try getAttribute(.previousContents)
    }
    public func nextContents() throws -> [MockElement] {
        try getAttribute(.nextContents)
    }
    public func shownMenu() throws -> MockElement {
        try getAttribute(.shownMenu)
    }
    public func searchButton() throws -> MockElement {
        try getAttribute(.searchButton)
    }
    public func searchMenu() throws -> MockElement {
        try getAttribute(.searchMenu)
    }
    public func clearButton() throws -> MockElement {
        try getAttribute(.clearButton)
    }

    // MARK: - Outline / tree

    public func isDisclosing() throws -> Bool {
        try getAttribute(.disclosing)
    }
    public func disclosedRows() throws -> [MockElement] {
        try getAttribute(.disclosedRows)
    }
    public func disclosedByRow() throws -> MockElement {
        try getAttribute(.disclosedByRow)
    }
    public func disclosureLevel() throws -> Int {
        try getAttribute(.disclosureLevel)
    }

    // MARK: - Misc

    public func identifier() throws -> String {
        try getAttribute(.identifier)
    }
    public func url() throws -> URL {
        try getAttribute(.url)
    }
    public func document() throws -> String {
        try getAttribute(.document)
    }
    public func filename() throws -> String {
        try getAttribute(.filename)
    }
    public func orientation() throws -> String {
        try getAttribute(.orientation)
    }
    public func contents() throws -> [MockElement] {
        try getAttribute(.contents)
    }
    public func sharedFocusElements() throws -> [MockElement] {
        try getAttribute(.sharedFocusElements)
    }
    public func isExpanded() throws -> Bool {
        try getAttribute(.expanded)
    }
    public func isEdited() throws -> Bool {
        try getAttribute(.edited)
    }
    public func isRequired() throws -> Bool {
        try getAttribute(.required)
    }
    public func containsProtectedContent() throws -> Bool {
        try getAttribute(.containsProtectedContent)
    }
    public func activationPoint() throws -> CGPoint {
        try getAttribute(.activationPoint)
    }

    // MARK: - Storage

    public func setAttribute<V: Sendable>(_ value: V, for attribute: NSAccessibility.Attribute) throws {
        if let error = setErrorStorage.withLock({ $0[attribute] }) {
            setAttributeStreamContinuation.yield((attribute, error))
            throw error
        }
        setAttributeStreamContinuation.yield((attribute, value))
        attributeStorage.withLock {
            $0[attribute] = value
        }
    }

    public func getAttribute<V>(_ attribute: NSAccessibility.Attribute) throws -> V {
        guard let value = attributeStorage.withLock({ $0[attribute] }) else {
            throw ElementError.noValue
        }
        guard let checkedValue = value as? V else {
            throw AccessibilityError.typeMismatch
        }
        return checkedValue
    }

    public func setAttributeShouldThrow(_ error: any Error, for attribute: NSAccessibility.Attribute) {
        setErrorStorage.withLock {
            $0[attribute] = error
        }
    }

    public func set<V: Sendable>(_ value: V, for key: String) {
        extendedStorage.withLock {
            $0[key] = value
        }
    }

    public func `get`<V>(_ key: String) throws -> V {
        guard let value = extendedStorage.withLock({ $0[key] }) else {
            throw ElementError.noValue
        }
        guard let checkedValue = value as? V else {
            throw AccessibilityError.typeMismatch
        }
        return checkedValue
    }

    private let _pid: pid_t
    private let attributeStorage: OSAllocatedUnfairLock<[NSAccessibility.Attribute:any Sendable]>
    private let extendedStorage: OSAllocatedUnfairLock<[String:any Sendable]>
    private let setErrorStorage: OSAllocatedUnfairLock<[NSAccessibility.Attribute:any Error]>
    public let setAttributeStream: AsyncStream<(NSAccessibility.Attribute, any Sendable)>
    private let setAttributeStreamContinuation: AsyncStream<(NSAccessibility.Attribute, any Sendable)>.Continuation
    private let lineForIndexHandler: (@Sendable (MockElement, Int) throws -> Int)?
    private let rangeForLineHandler: (@Sendable (MockElement, Int) throws -> Range<Int>)?
    private let stringForRangeHandler: (@Sendable (MockElement, Range<Int>) throws -> String)?
    private let boundsForRangeHandler: (@Sendable (MockElement, Range<Int>) throws -> NSRect)?
    private let setPositionHandler: (@Sendable (MockElement, CGPoint) throws -> Void)?
    public init(
        pid: pid_t = 0,
        storage: [NSAccessibility.Attribute:any Sendable],
        lineForIndexHandler: (@Sendable (MockElement, Int) throws -> Int)? = nil,
        rangeForLineHandler: (@Sendable (MockElement, Int) throws -> Range<Int>)? = nil,
        stringForRangeHandler: (@Sendable (MockElement, Range<Int>) throws -> String)? = nil,
        boundsForRangeHandler: (@Sendable (MockElement, Range<Int>) throws -> NSRect)? = nil,
        setPositionHandler: (@Sendable (MockElement, CGPoint) throws -> Void)? = nil
    ) {
        _pid = pid
        attributeStorage = .init(initialState: storage)
        extendedStorage = .init(initialState: [:])
        setErrorStorage = .init(initialState: [:])
        (setAttributeStream, setAttributeStreamContinuation) = AsyncStream.makeStream()
        self.lineForIndexHandler = lineForIndexHandler
        self.rangeForLineHandler = rangeForLineHandler
        self.stringForRangeHandler = stringForRangeHandler
        self.boundsForRangeHandler = boundsForRangeHandler
        self.setPositionHandler = setPositionHandler
    }
}
