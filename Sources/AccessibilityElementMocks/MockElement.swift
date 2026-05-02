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
        get async throws { _pid }
    }

    // MARK: - General

    public func role() async throws -> NSAccessibility.Role {
        try getAttribute(.role)
    }
    public func roleDescription() async throws -> String {
        try getAttribute(.roleDescription)
    }
    public func subrole() async throws -> NSAccessibility.Subrole {
        try getAttribute(.subrole)
    }
    public func value() async throws -> Any {
        try getAttribute(.value)
    }
    public func valueDescription() async throws -> String {
        try getAttribute(.valueDescription)
    }
    public func title() async throws -> String {
        try getAttribute(.title)
    }
    public func titleUIElement() async throws -> MockElement {
        try getAttribute(.titleUIElement)
    }
    public func description() async throws -> String {
        try getAttribute(.description)
    }
    public func help() async throws -> String {
        try getAttribute(.help)
    }
    public func isEnabled() async throws -> Bool {
        try getAttribute(.enabled)
    }
    public func isFocused() async throws -> Bool {
        try getAttribute(.focused)
    }
    public func isSelected() async throws -> Bool {
        try getAttribute(.selected)
    }

    // MARK: - Application Attributes

    public func windows() async throws -> [MockElement] {
        try getAttribute(.windows)
    }
    public func mainWindow() async throws -> MockElement {
        try getAttribute(.mainWindow)
    }
    public func focusedWindow() async throws -> MockElement {
        try getAttribute(.focusedWindow)
    }
    public func focusedUIElement() async throws -> MockElement {
        try getAttribute(.focusedUIElement)
    }
    public func enhancedUserInterface() async throws -> Bool {
        try getAttribute(.enhancedUserInterface)
    }
    public func setEnhancedUserInterface(_ enhancedUserInterface: Bool) async throws {
        try setAttribute(enhancedUserInterface,
                         for: .enhancedUserInterface)
    }
    public func isFrontmost() async throws -> Bool {
        try getAttribute(.frontmost)
    }
    public func isHidden() async throws -> Bool {
        try getAttribute(.hidden)
    }
    public func menuBar() async throws -> MockElement {
        try getAttribute(.menuBar)
    }
    public func extrasMenuBar() async throws -> MockElement {
        try getAttribute(.extrasMenuBar)
    }

    // MARK: - Hierarchy

    public func parent() async throws -> MockElement {
        try getAttribute(.parent)
    }
    public func children() async throws -> [MockElement] {
        try getAttribute(.children)
    }
    public func childrenInNavigationOrder() async throws -> [MockElement] {
        try getAttribute(.childrenInNavigationOrderAttribute)
    }
    public func visibleChildren() async throws -> [MockElement] {
        try getAttribute(.visibleChildren)
    }
    public func selectedChildren() async throws -> [MockElement] {
        try getAttribute(.selectedChildren)
    }
    public func childrenView() -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { (try self.getAttribute(.children) as [MockElement]).count },
            elements: { i, n in
                let a: [MockElement] = try self.getAttribute(.children)
                return Array(a[i..<min(i + n, a.count)])
            }
        )
    }
    public func childrenInNavigationOrderView() -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { (try self.getAttribute(.childrenInNavigationOrderAttribute) as [MockElement]).count },
            elements: { i, n in
                let a: [MockElement] = try self.getAttribute(.childrenInNavigationOrderAttribute)
                return Array(a[i..<min(i + n, a.count)])
            }
        )
    }
    public func visibleChildrenView() -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { (try self.getAttribute(.visibleChildren) as [MockElement]).count },
            elements: { i, n in
                let a: [MockElement] = try self.getAttribute(.visibleChildren)
                return Array(a[i..<min(i + n, a.count)])
            }
        )
    }
    public func selectedChildrenView() -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { (try self.getAttribute(.selectedChildren) as [MockElement]).count },
            elements: { i, n in
                let a: [MockElement] = try self.getAttribute(.selectedChildren)
                return Array(a[i..<min(i + n, a.count)])
            }
        )
    }
    public func window() async throws -> MockElement {
        try getAttribute(.window)
    }
    public func topLevelUIElement() async throws -> MockElement {
        try getAttribute(.topLevelUIElement)
    }
    public func index() async throws -> Int {
        try getAttribute(.index)
    }

    // MARK: - Hierarchy (Web)

    public func focusableAncestor() async throws -> MockElement {
        throw ElementError.noValue
    }
    public func editableAncestor() async throws -> MockElement {
        throw ElementError.noValue
    }
    public func highestEditableAncestor() async throws -> MockElement {
        throw ElementError.noValue
    }

    // MARK: - Actions

    public func actions() async throws -> [NSAccessibility.Action] {
        []
    }
    public func description(action: NSAccessibility.Action) async throws -> String {
        ""
    }
    public func perform(action: NSAccessibility.Action) async throws {
    }

    // MARK: - Text

    public func placeholderValue() async throws -> String {
        try getAttribute(.placeholderValue)
    }

    // MARK: - Text (Integer Indexed)

    public func line(forIndex index: Int) async throws -> Int {
        guard let handler = lineForIndexHandler else { throw ElementError.noValue }
        return try handler(self, index)
    }
    public func range(forLine line: Int) async throws -> Range<Int> {
        guard let handler = rangeForLineHandler else { throw ElementError.noValue }
        return try handler(self, line)
    }
    public func range(forIndex index: Int) async throws -> Range<Int> {
        throw ElementError.noValue
    }
    public func range(forPosition position: Int) async throws -> Range<Int> {
        throw ElementError.noValue
    }
    public func string(for range: Range<Int>) async throws -> String {
        guard let handler = stringForHandler else { throw ElementError.noValue }
        return try handler(range)
    }
    public func bounds(for range: Range<Int>) async throws -> NSRect {
        guard let handler = boundsForRangeHandler else { throw ElementError.noValue }
        return try handler(self, range)
    }
    public func rtf(for range: Range<Int>) async throws -> Data {
        throw ElementError.noValue
    }
    public func attributedString(for range: Range<Int>) async throws -> NSAttributedString {
        throw ElementError.noValue
    }
    public func styleRange(for index: Int) async throws -> Range<Int> {
        throw ElementError.noValue
    }
    public func insertionPointLineNumber() async throws -> Int {
        try getAttribute(.insertionPointLineNumber)
    }
    public func sharedCharacterRange() async throws -> Range<Int> {
        throw ElementError.noValue
    }
    public func sharedTextUIElements() async throws -> [MockElement] {
        throw ElementError.noValue
    }
    public func visibleCharacterRange() async throws -> Range<Int> {
        try getAttribute(.visibleCharacterRange)
    }
    public func setVisibleCharacterRange(_ range: Range<Int>) async throws {
        if let handler = setVisibleCharacterRangeHandler {
            try handler(range)
        } else {
            try setAttribute(range,
                             for: .visibleCharacterRange)
        }
    }
    public func numberOfCharacters() async throws -> Int {
        try getAttribute(.numberOfCharacters)
    }
    public func selectedText() async throws -> String {
        try getAttribute(.selectedText)
    }
    public func selectedTextRange() async throws -> Range<Int> {
        try getAttribute(.selectedTextRange)
    }
    public func selectedTextRanges() async throws -> [Range<Int>] {
        throw ElementError.noValue
    }

    // MARK: - Text (TextMarker Indexed)

    public func line(forTextMarker textMarker: TextMarker) async throws -> Int {
        throw ElementError.noValue
    }
    public func selectedTextMarkerRange() async throws -> TextMarkerRange {
        try getAttribute(.selectedTextMarkerRange)
    }
    public func startTextMarker() async throws -> TextMarker {
        try getAttribute(.startTextMarker)
    }
    public func endTextMarker() async throws -> TextMarker {
        try getAttribute(.endTextMarker)
    }
    public func nextTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        throw ElementError.noValue
    }
    public func previousTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        throw ElementError.noValue
    }
    public func nextWordEndTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        throw ElementError.noValue
    }
    public func previousWordStartTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        throw ElementError.noValue
    }
    public func nextLineEndTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        throw ElementError.noValue
    }
    public func previousLineStartTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        throw ElementError.noValue
    }
    public func nextSentenceEndTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        throw ElementError.noValue
    }
    public func previousSentenceStartTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        throw ElementError.noValue
    }
    public func nextParagraphEndTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        throw ElementError.noValue
    }
    public func previousParagraphStartTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        throw ElementError.noValue
    }
    public func lineTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        throw ElementError.noValue
    }
    public func leftWordTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        throw ElementError.noValue
    }
    public func rightWordTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        throw ElementError.noValue
    }
    public func leftLineTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        throw ElementError.noValue
    }
    public func rightLineTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        throw ElementError.noValue
    }
    public func sentenceTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        throw ElementError.noValue
    }
    public func paragraphTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        throw ElementError.noValue
    }
    public func styleTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        throw ElementError.noValue
    }
    public func lineNumber(for textMarker: TextMarker) async throws -> Int {
        throw ElementError.noValue
    }
    public func index(for textMarker: TextMarker) async throws -> Int {
        throw ElementError.noValue
    }
    public func element(for textMarker: TextMarker) async throws -> MockElement {
        throw ElementError.noValue
    }
    public func string(for textMarkerRange: TextMarkerRange) async throws -> String {
        throw ElementError.noValue
    }
    public func attributedString(for textMarkerRange: TextMarkerRange) async throws -> NSAttributedString {
        throw ElementError.noValue
    }
    public func bounds(for textMarkerRange: TextMarkerRange) async throws -> NSRect {
        throw ElementError.noValue
    }
    public func length(for textMarkerRange: TextMarkerRange) async throws -> Int {
        throw ElementError.noValue
    }
    public func textMarker(forIndex index: Int) async throws -> TextMarker {
        throw ElementError.noValue
    }
    public func textMarkerRange(forLine line: Int) async throws -> TextMarkerRange {
        throw ElementError.noValue
    }
    public func textMarker(forPosition position: CGPoint) async throws -> TextMarker {
        throw ElementError.noValue
    }
    public func startTextMarker(forBounds bounds: NSRect) async throws -> TextMarker {
        throw ElementError.noValue
    }
    public func endTextMarker(forBounds bounds: NSRect) async throws -> TextMarker {
        throw ElementError.noValue
    }
    public func textMarkerRange(for element: MockElement) async throws -> TextMarkerRange {
        throw ElementError.noValue
    }
    public func textMarkerRange(forUnordered textMarkers: [TextMarker]) async throws -> TextMarkerRange {
        throw ElementError.noValue
    }
    public func textMarkerRange(forOrdered textMarkers: [TextMarker]) async throws -> TextMarkerRange {
        throw ElementError.noValue
    }
    public func isNullTextMarker(_ textMarker: TextMarker) async throws -> Bool {
        throw ElementError.noValue
    }
    public func isValidTextMarker(_ textMarker: TextMarker) async throws -> Bool {
        throw ElementError.noValue
    }

    // MARK: - Table/Outline/Grid/List/Collection

    public func cell(
        column: Int,
        row: Int
    ) async throws -> MockElement {
        throw ElementError.noValue
    }
    public func rows() async throws -> [MockElement] {
        try getAttribute(.rows)
    }
    public func columns() async throws -> [MockElement] {
        try getAttribute(.columns)
    }
    public func selectedRows() async throws -> [MockElement] {
        try getAttribute(.selectedRows)
    }
    public func selectedColumns() async throws -> [MockElement] {
        try getAttribute(.selectedColumns)
    }
    public func selectedCells() async throws -> [MockElement] {
        try getAttribute(.selectedCells)
    }
    public func visibleRows() async throws -> [MockElement] {
        try getAttribute(.visibleRows)
    }
    public func visibleColumns() async throws -> [MockElement] {
        try getAttribute(.visibleColumns)
    }
    public func visibleCells() async throws -> [MockElement] {
        try getAttribute(.visibleCells)
    }
    public func rowHeaderUIElements() async throws -> [MockElement] {
        try getAttribute(.rowHeaderUIElements)
    }
    public func columnHeaderUIElements() async throws -> [MockElement] {
        try getAttribute(.columnHeaderUIElements)
    }
    public func columnTitles() async throws -> [MockElement] {
        try getAttribute(.columnTitles)
    }
    public func rowsView() async throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { (try self.getAttribute(.rows) as [MockElement]).count },
            elements: { i, n in
                let a: [MockElement] = try self.getAttribute(.rows)
                return Array(a[i..<min(i + n, a.count)])
            }
        )
    }
    public func columnsView() async throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { (try self.getAttribute(.columns) as [MockElement]).count },
            elements: { i, n in
                let a: [MockElement] = try self.getAttribute(.columns)
                return Array(a[i..<min(i + n, a.count)])
            }
        )
    }
    public func selectedRowsView() async throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { (try self.getAttribute(.selectedRows) as [MockElement]).count },
            elements: { i, n in
                let a: [MockElement] = try self.getAttribute(.selectedRows)
                return Array(a[i..<min(i + n, a.count)])
            }
        )
    }
    public func selectedColumnsView() async throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { (try self.getAttribute(.selectedColumns) as [MockElement]).count },
            elements: { i, n in
                let a: [MockElement] = try self.getAttribute(.selectedColumns)
                return Array(a[i..<min(i + n, a.count)])
            }
        )
    }
    public func selectedCellsView() async throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { (try self.getAttribute(.selectedCells) as [MockElement]).count },
            elements: { i, n in
                let a: [MockElement] = try self.getAttribute(.selectedCells)
                return Array(a[i..<min(i + n, a.count)])
            }
        )
    }
    public func visibleRowsView() async throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { (try self.getAttribute(.visibleRows) as [MockElement]).count },
            elements: { i, n in
                let a: [MockElement] = try self.getAttribute(.visibleRows)
                return Array(a[i..<min(i + n, a.count)])
            }
        )
    }
    public func visibleColumnsView() async throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { (try self.getAttribute(.visibleColumns) as [MockElement]).count },
            elements: { i, n in
                let a: [MockElement] = try self.getAttribute(.visibleColumns)
                return Array(a[i..<min(i + n, a.count)])
            }
        )
    }
    public func visibleCellsView() async throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { (try self.getAttribute(.visibleCells) as [MockElement]).count },
            elements: { i, n in
                let a: [MockElement] = try self.getAttribute(.visibleCells)
                return Array(a[i..<min(i + n, a.count)])
            }
        )
    }
    public func rowHeaderUIElementsView() async throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { (try self.getAttribute(.rowHeaderUIElements) as [MockElement]).count },
            elements: { i, n in
                let a: [MockElement] = try self.getAttribute(.rowHeaderUIElements)
                return Array(a[i..<min(i + n, a.count)])
            }
        )
    }
    public func columnHeaderUIElementsView() async throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { (try self.getAttribute(.columnHeaderUIElements) as [MockElement]).count },
            elements: { i, n in
                let a: [MockElement] = try self.getAttribute(.columnHeaderUIElements)
                return Array(a[i..<min(i + n, a.count)])
            }
        )
    }
    public func columnTitlesView() async throws -> ArrayAttributeView<MockElement> {
        ArrayAttributeView(
            count: { (try self.getAttribute(.columnTitles) as [MockElement]).count },
            elements: { i, n in
                let a: [MockElement] = try self.getAttribute(.columnTitles)
                return Array(a[i..<min(i + n, a.count)])
            }
        )
    }
    public func sortDirection() async throws -> String {
        try getAttribute(.sortDirection)
    }
    public func rowCount() async throws -> Int {
        try getAttribute(.rowCount)
    }
    public func columnCount() async throws -> Int {
        try getAttribute(.columnCount)
    }
    public func isOrderedByRow() async throws -> Bool {
        try getAttribute(.orderedByRow)
    }
    public func rowIndexRange() async throws -> Range<Int> {
        try getAttribute(.rowIndexRange)
    }
    public func columnIndexRange() async throws -> Range<Int> {
        try getAttribute(.columnIndexRange)
    }

    // MARK: - Layout

    public func frame() async throws -> NSRect {
        try getAttribute(.frame)
    }
    public func setPosition(_ position: CGPoint) async throws {
        guard let handler = setPositionHandler else { throw ElementError.noValue }
        try handler(self, position)
    }

    // MARK: - Linked Elements

    public func linkedUIElements() async throws -> [MockElement] {
        try getAttribute(.linkedUIElements)
    }
    public func servesAsTitleForUIElements() async throws -> [MockElement] {
        try getAttribute(.servesAsTitleForUIElements)
    }

    // MARK: - Slider

    public func minValue() async throws -> Any {
        try getAttribute(.minValue)
    }
    public func maxValue() async throws -> Any {
        try getAttribute(.maxValue)
    }
    public func warningValue() async throws -> Any {
        try getAttribute(.warningValue)
    }
    public func criticalValue() async throws -> Any {
        try getAttribute(.criticalValue)
    }
    public func allowedValues() async throws -> [Double] {
        try getAttribute(.allowedValues)
    }
    public func labelUIElements() async throws -> [MockElement] {
        try getAttribute(.labelUIElements)
    }
    public func labelValue() async throws -> Double {
        try getAttribute(.labelValue)
    }

    // MARK: - Window

    public func isMain() async throws -> Bool {
        try getAttribute(.main)
    }
    public func isMinimized() async throws -> Bool {
        try getAttribute(.minimized)
    }
    public func isModal() async throws -> Bool {
        try getAttribute(.modal)
    }
    public func closeButton() async throws -> MockElement {
        try getAttribute(.closeButton)
    }
    public func zoomButton() async throws -> MockElement {
        try getAttribute(.zoomButton)
    }
    public func minimizeButton() async throws -> MockElement {
        try getAttribute(.minimizeButton)
    }
    public func toolbarButton() async throws -> MockElement {
        try getAttribute(.toolbarButton)
    }
    public func fullScreenButton() async throws -> MockElement {
        try getAttribute(.fullScreenButton)
    }
    public func defaultButton() async throws -> MockElement {
        try getAttribute(.defaultButton)
    }
    public func cancelButton() async throws -> MockElement {
        try getAttribute(.cancelButton)
    }
    public func proxy() async throws -> MockElement {
        try getAttribute(.proxy)
    }
    public func growArea() async throws -> MockElement {
        try getAttribute(.growArea)
    }

    // MARK: - Container / scroll UI

    public func header() async throws -> MockElement {
        try getAttribute(.header)
    }
    public func tabs() async throws -> [MockElement] {
        try getAttribute(.tabs)
    }
    public func splitters() async throws -> [MockElement] {
        try getAttribute(.splitters)
    }
    public func horizontalScrollBar() async throws -> MockElement {
        try getAttribute(.horizontalScrollBar)
    }
    public func verticalScrollBar() async throws -> MockElement {
        try getAttribute(.verticalScrollBar)
    }
    public func overflowButton() async throws -> MockElement {
        try getAttribute(.overflowButton)
    }
    public func incrementButton() async throws -> MockElement {
        try getAttribute(.incrementButton)
    }
    public func decrementButton() async throws -> MockElement {
        try getAttribute(.decrementButton)
    }
    public func previousContents() async throws -> [MockElement] {
        try getAttribute(.previousContents)
    }
    public func nextContents() async throws -> [MockElement] {
        try getAttribute(.nextContents)
    }
    public func shownMenu() async throws -> MockElement {
        try getAttribute(.shownMenu)
    }
    public func searchButton() async throws -> MockElement {
        try getAttribute(.searchButton)
    }
    public func searchMenu() async throws -> MockElement {
        try getAttribute(.searchMenu)
    }
    public func clearButton() async throws -> MockElement {
        try getAttribute(.clearButton)
    }

    // MARK: - Outline / tree

    public func isDisclosing() async throws -> Bool {
        try getAttribute(.disclosing)
    }
    public func disclosedRows() async throws -> [MockElement] {
        try getAttribute(.disclosedRows)
    }
    public func disclosedByRow() async throws -> MockElement {
        try getAttribute(.disclosedByRow)
    }
    public func disclosureLevel() async throws -> Int {
        try getAttribute(.disclosureLevel)
    }

    // MARK: - Misc

    public func identifier() async throws -> String {
        try getAttribute(.identifier)
    }
    public func url() async throws -> URL {
        try getAttribute(.url)
    }
    public func document() async throws -> String {
        try getAttribute(.document)
    }
    public func filename() async throws -> String {
        try getAttribute(.filename)
    }
    public func orientation() async throws -> String {
        try getAttribute(.orientation)
    }
    public func contents() async throws -> [MockElement] {
        try getAttribute(.contents)
    }
    public func sharedFocusElements() async throws -> [MockElement] {
        try getAttribute(.sharedFocusElements)
    }
    public func isExpanded() async throws -> Bool {
        try getAttribute(.expanded)
    }
    public func isEdited() async throws -> Bool {
        try getAttribute(.edited)
    }
    public func isRequired() async throws -> Bool {
        try getAttribute(.required)
    }
    public func containsProtectedContent() async throws -> Bool {
        try getAttribute(.containsProtectedContent)
    }
    public func activationPoint() async throws -> CGPoint {
        try getAttribute(.activationPoint)
    }

    // MARK: - Web

    public func isLoaded() async throws -> Bool {
        try getAttribute(.loaded)
    }
    public func loadingProgress() async throws -> Double {
        try getAttribute(.loadingProgress)
    }
    public func layoutCount() async throws -> Int {
        try getAttribute(.layoutCount)
    }
    public func preventKeyboardDOMEventDispatch() async throws -> Bool {
        try getAttribute(.preventKeyboardDOMEventDispatch)
    }

    // MARK: - MathML

    public func mathBase() async throws -> Self {
        try getAttribute(.mathBase)
    }

    public func mathFencedOpen() async throws -> String {
        try getAttribute(.mathFencedOpen)
    }

    public func mathFencedClose() async throws -> String {
        try getAttribute(.mathFencedClose)
    }

    public func mathFractionNumerator() async throws -> Self {
        try getAttribute(.mathFractionNumerator)
    }

    public func mathFractionDenominator() async throws -> Self {
        try getAttribute(.mathFractionDenominator)
    }

    public func mathLineThickness() async throws -> Double {
        try getAttribute(.mathLineThickness)
    }

    public func mathOver() async throws -> Self {
        try getAttribute(.mathOver)
    }

    public func mathUnder() async throws -> Self {
        try getAttribute(.mathUnder)
    }

    public func mathPostscripts() async throws -> [MockElement] {
        try getAttribute(.mathPostscripts)
    }

    public func mathPrescripts() async throws -> [MockElement] {
        try getAttribute(.mathPrescripts)
    }

    public func mathRootIndex() async throws -> Self {
        try getAttribute(.mathRootIndex)
    }

    public func mathRootRadicand() async throws -> Self {
        try getAttribute(.mathRootRadicand)
    }

    public func mathSubscript() async throws -> Self {
        try getAttribute(.mathSubscript)
    }

    public func mathSuperscript() async throws -> Self {
        try getAttribute(.mathSuperscript)
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
    public nonisolated(unsafe) var lineForIndexHandler: (@Sendable (MockElement, Int) throws -> Int)?
    public nonisolated(unsafe) var rangeForLineHandler: (@Sendable (MockElement, Int) throws -> Range<Int>)?
    public nonisolated(unsafe) var stringForHandler: (@Sendable (Range<Int>) throws -> String)?
    public nonisolated(unsafe) var boundsForRangeHandler: (@Sendable (MockElement, Range<Int>) throws -> NSRect)?
    public nonisolated(unsafe) var setPositionHandler: (@Sendable (MockElement, CGPoint) throws -> Void)?
    public nonisolated(unsafe) var setVisibleCharacterRangeHandler: (@Sendable (Range<Int>) throws -> Void)?
    public init(
        pid: pid_t = 0,
        storage: [NSAccessibility.Attribute:any Sendable]
    ) {
        _pid = pid
        attributeStorage = .init(initialState: storage)
        extendedStorage = .init(initialState: [:])
        setErrorStorage = .init(initialState: [:])
        (setAttributeStream, setAttributeStreamContinuation) = AsyncStream.makeStream()
    }
}
