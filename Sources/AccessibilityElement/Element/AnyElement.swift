//
//  AnyElement.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AX
import Cocoa

public struct AnyElement: Element {
    public static func systemWide() throws -> AnyElement {
        fatalError()
    }

    public static func application(processIdentifier: pid_t) throws -> AnyElement {
        fatalError()
    }

    // MARK: - Private Closures

    private let _processIdentifier: @Sendable () throws -> pid_t

    // General
    private let _role: @Sendable () throws -> NSAccessibility.Role
    private let _roleDescription: @Sendable () throws -> String
    private let _subrole: @Sendable () throws -> NSAccessibility.Subrole
    private let _value: @Sendable () throws -> Any
    private let _valueDescription: @Sendable () throws -> String
    private let _title: @Sendable () throws -> String
    private let _titleUIElement: @Sendable () throws -> AnyElement
    private let _description: @Sendable () throws -> String
    private let _help: @Sendable () throws -> String
    private let _isEnabled: @Sendable () throws -> Bool
    private let _isFocused: @Sendable () throws -> Bool
    private let _isSelected: @Sendable () throws -> Bool
    // Application Attributes
    private let _windows: @Sendable () throws -> [AnyElement]
    private let _mainWindow: @Sendable () throws -> AnyElement
    private let _focusedWindow: @Sendable () throws -> AnyElement
    private let _focusedUIElement: @Sendable () throws -> AnyElement
    private let _enhancedUserInterface: @Sendable () throws -> Bool
    private let _setEnhancedUserInterface: @Sendable (Bool) throws -> Void
    private let _isFrontmost: @Sendable () throws -> Bool
    private let _isHidden: @Sendable () throws -> Bool
    private let _menuBar: @Sendable () throws -> AnyElement
    private let _extrasMenuBar: @Sendable () throws -> AnyElement
    // Hierarchy
    private let _parent: @Sendable () throws -> AnyElement
    private let _children: @Sendable () throws -> [AnyElement]
    private let _childrenInNavigationOrder: @Sendable () throws -> [AnyElement]
    private let _visibleChildren: @Sendable () throws -> [AnyElement]
    private let _selectedChildren: @Sendable () throws -> [AnyElement]
    private let _window: @Sendable () throws -> AnyElement
    private let _topLevelUIElement: @Sendable () throws -> AnyElement
    private let _index: @Sendable () throws -> Int
    // Actions
    private let _actions: @Sendable () throws -> [NSAccessibility.Action]
    private let _descriptionAction: @Sendable (NSAccessibility.Action) throws -> String
    private let _performAction: @Sendable (NSAccessibility.Action) throws -> Void
    // Text
    private let _placeholderValue: @Sendable () throws -> String
    // Text (Integer Indexed)
    private let _lineForIndex: @Sendable (Int) throws -> Int
    private let _rangeForLine: @Sendable (Int) throws -> Range<Int>
    private let _rangeForIndex: @Sendable (Int) throws -> Range<Int>
    private let _rangeForPosition: @Sendable (Int) throws -> Range<Int>
    private let _stringForRange: @Sendable (Range<Int>) throws -> String
    private let _boundsForRange: @Sendable (Range<Int>) throws -> NSRect
    private let _rtfForRange: @Sendable (Range<Int>) throws -> Data
    private let _attributedStringForRange: @Sendable (Range<Int>) throws -> NSAttributedString
    private let _styleRangeForIndex: @Sendable (Int) throws -> Range<Int>
    private let _insertionPointLineNumber: @Sendable () throws -> Int
    private let _sharedCharacterRange: @Sendable () throws -> Range<Int>
    private let _sharedTextUIElements: @Sendable () throws -> [AnyElement]
    private let _visibleCharacterRange: @Sendable () throws -> Range<Int>
    private let _setVisibleCharacterRange: @Sendable (Range<Int>) throws -> Void
    private let _numberOfCharacters: @Sendable () throws -> Int
    private let _selectedText: @Sendable () throws -> String
    private let _selectedTextRange: @Sendable () throws -> Range<Int>
    private let _selectedTextRanges: @Sendable () throws -> [Range<Int>]
    // Text (TextMarker Indexed)
    private let _lineForTextMarker: @Sendable (TextMarker) throws -> Int
    // Table/Outline/Grid/List/Collection
    private let _cellForColumnRow: @Sendable (Int, Int) throws -> SystemElement
    private let _rows: @Sendable () throws -> [AnyElement]
    private let _columns: @Sendable () throws -> [AnyElement]
    private let _selectedRows: @Sendable () throws -> [AnyElement]
    private let _selectedColumns: @Sendable () throws -> [AnyElement]
    private let _selectedCells: @Sendable () throws -> [AnyElement]
    private let _visibleRows: @Sendable () throws -> [AnyElement]
    private let _visibleColumns: @Sendable () throws -> [AnyElement]
    private let _visibleCells: @Sendable () throws -> [AnyElement]
    private let _rowHeaderUIElements: @Sendable () throws -> [AnyElement]
    private let _columnHeaderUIElements: @Sendable () throws -> [AnyElement]
    private let _columnTitles: @Sendable () throws -> [AnyElement]
    private let _sortDirection: @Sendable () throws -> String
    private let _rowCount: @Sendable () throws -> Int
    private let _columnCount: @Sendable () throws -> Int
    private let _isOrderedByRow: @Sendable () throws -> Bool
    private let _rowIndexRange: @Sendable () throws -> Range<Int>
    private let _columnIndexRange: @Sendable () throws -> Range<Int>
    // Layout
    private let _frame: @Sendable () throws -> NSRect
    private let _setPosition: @Sendable (CGPoint) throws -> Void
    // Linked Elements
    private let _linkedUIElements: @Sendable () throws -> [AnyElement]
    private let _servesAsTitleForUIElements: @Sendable () throws -> [AnyElement]
    // Slider
    private let _minValue: @Sendable () throws -> Any
    private let _maxValue: @Sendable () throws -> Any
    private let _warningValue: @Sendable () throws -> Any
    private let _criticalValue: @Sendable () throws -> Any
    private let _allowedValues: @Sendable () throws -> [Double]
    private let _labelUIElements: @Sendable () throws -> [AnyElement]
    private let _labelValue: @Sendable () throws -> Double
    // Window
    private let _isMain: @Sendable () throws -> Bool
    private let _isMinimized: @Sendable () throws -> Bool
    private let _isModal: @Sendable () throws -> Bool
    private let _closeButton: @Sendable () throws -> AnyElement
    private let _zoomButton: @Sendable () throws -> AnyElement
    private let _minimizeButton: @Sendable () throws -> AnyElement
    private let _toolbarButton: @Sendable () throws -> AnyElement
    private let _fullScreenButton: @Sendable () throws -> AnyElement
    private let _defaultButton: @Sendable () throws -> AnyElement
    private let _cancelButton: @Sendable () throws -> AnyElement
    private let _proxy: @Sendable () throws -> AnyElement
    private let _growArea: @Sendable () throws -> AnyElement
    // Container / scroll UI
    private let _header: @Sendable () throws -> AnyElement
    private let _tabs: @Sendable () throws -> [AnyElement]
    private let _splitters: @Sendable () throws -> [AnyElement]
    private let _horizontalScrollBar: @Sendable () throws -> AnyElement
    private let _verticalScrollBar: @Sendable () throws -> AnyElement
    private let _overflowButton: @Sendable () throws -> AnyElement
    private let _incrementButton: @Sendable () throws -> AnyElement
    private let _decrementButton: @Sendable () throws -> AnyElement
    private let _previousContents: @Sendable () throws -> [AnyElement]
    private let _nextContents: @Sendable () throws -> [AnyElement]
    private let _shownMenu: @Sendable () throws -> AnyElement
    private let _searchButton: @Sendable () throws -> AnyElement
    private let _searchMenu: @Sendable () throws -> AnyElement
    private let _clearButton: @Sendable () throws -> AnyElement
    // Outline / tree
    private let _isDisclosing: @Sendable () throws -> Bool
    private let _disclosedRows: @Sendable () throws -> [AnyElement]
    private let _disclosedByRow: @Sendable () throws -> AnyElement
    private let _disclosureLevel: @Sendable () throws -> Int
    // Misc
    private let _identifier: @Sendable () throws -> String
    private let _url: @Sendable () throws -> URL
    private let _document: @Sendable () throws -> String
    private let _filename: @Sendable () throws -> String
    private let _orientation: @Sendable () throws -> String
    private let _contents: @Sendable () throws -> [AnyElement]
    private let _sharedFocusElements: @Sendable () throws -> [AnyElement]
    private let _isExpanded: @Sendable () throws -> Bool
    private let _isEdited: @Sendable () throws -> Bool
    private let _isRequired: @Sendable () throws -> Bool
    private let _containsProtectedContent: @Sendable () throws -> Bool
    private let _activationPoint: @Sendable () throws -> CGPoint

    // MARK: - Initializer

    public init<E: Element>(element: E) {
        if let alreadyAny = element as? AnyElement {
            self = alreadyAny
        } else {
            _processIdentifier = { try element.processIdentifier }
            // General
            _role = element.role
            _roleDescription = element.roleDescription
            _subrole = element.subrole
            _value = element.value
            _valueDescription = element.valueDescription
            _title = element.title
            _titleUIElement = { AnyElement(element: try element.titleUIElement()) }
            _description = element.description
            _help = element.help
            _isEnabled = element.isEnabled
            _isFocused = element.isFocused
            _isSelected = element.isSelected
            // Application Attributes
            _windows = { try element.windows().map(AnyElement.init) }
            _mainWindow = { AnyElement(element: try element.mainWindow()) }
            _focusedWindow = { AnyElement(element: try element.focusedWindow()) }
            _focusedUIElement = { AnyElement(element: try element.focusedUIElement()) }
            _enhancedUserInterface = element.enhancedUserInterface
            _setEnhancedUserInterface = element.setEnhancedUserInterface
            _isFrontmost = element.isFrontmost
            _isHidden = element.isHidden
            _menuBar = { AnyElement(element: try element.menuBar()) }
            _extrasMenuBar = { AnyElement(element: try element.extrasMenuBar()) }
            // Hierarchy
            _parent = { AnyElement(element: try element.parent()) }
            _children = { try element.children().map(AnyElement.init) }
            _childrenInNavigationOrder = { try element.childrenInNavigationOrder().map(AnyElement.init) }
            _visibleChildren = { try element.visibleChildren().map(AnyElement.init) }
            _selectedChildren = { try element.selectedChildren().map(AnyElement.init) }
            _window = { AnyElement(element: try element.window()) }
            _topLevelUIElement = { AnyElement(element: try element.topLevelUIElement()) }
            _index = element.index
            // Actions
            _actions = element.actions
            _descriptionAction = element.description(action:)
            _performAction = element.perform(action:)
            // Text
            _placeholderValue = element.placeholderValue
            // Text (Integer Indexed)
            _lineForIndex = element.line(forIndex:)
            _rangeForLine = element.range(forLine:)
            _rangeForIndex = element.range(forIndex:)
            _rangeForPosition = element.range(forPosition:)
            _stringForRange = element.string(for:)
            _boundsForRange = element.bounds(for:)
            _rtfForRange = element.rtf(for:)
            _attributedStringForRange = element.attributedString(for:)
            _styleRangeForIndex = element.styleRange(for:)
            _insertionPointLineNumber = element.insertionPointLineNumber
            _sharedCharacterRange = element.sharedCharacterRange
            _sharedTextUIElements = { try element.sharedTextUIElements().map(AnyElement.init) }
            _visibleCharacterRange = element.visibleCharacterRange
            _setVisibleCharacterRange = element.setVisibleCharacterRange
            _numberOfCharacters = element.numberOfCharacters
            _selectedText = element.selectedText
            _selectedTextRange = element.selectedTextRange
            _selectedTextRanges = element.selectedTextRanges
            // Text (TextMarker Indexed)
            _lineForTextMarker = element.line(forTextMarker:)
            // Table/Outline/Grid/List/Collection
            _cellForColumnRow = element.cell(column:row:)
            _rows = { try element.rows().map(AnyElement.init) }
            _columns = { try element.columns().map(AnyElement.init) }
            _selectedRows = { try element.selectedRows().map(AnyElement.init) }
            _selectedColumns = { try element.selectedColumns().map(AnyElement.init) }
            _selectedCells = { try element.selectedCells().map(AnyElement.init) }
            _visibleRows = { try element.visibleRows().map(AnyElement.init) }
            _visibleColumns = { try element.visibleColumns().map(AnyElement.init) }
            _visibleCells = { try element.visibleCells().map(AnyElement.init) }
            _rowHeaderUIElements = { try element.rowHeaderUIElements().map(AnyElement.init) }
            _columnHeaderUIElements = { try element.columnHeaderUIElements().map(AnyElement.init) }
            _columnTitles = { try element.columnTitles().map(AnyElement.init) }
            _sortDirection = element.sortDirection
            _rowCount = element.rowCount
            _columnCount = element.columnCount
            _isOrderedByRow = element.isOrderedByRow
            _rowIndexRange = element.rowIndexRange
            _columnIndexRange = element.columnIndexRange
            // Layout
            _frame = element.frame
            _setPosition = element.setPosition
            // Linked Elements
            _linkedUIElements = { try element.linkedUIElements().map(AnyElement.init) }
            _servesAsTitleForUIElements = { try element.servesAsTitleForUIElements().map(AnyElement.init) }
            // Slider
            _minValue = element.minValue
            _maxValue = element.maxValue
            _warningValue = element.warningValue
            _criticalValue = element.criticalValue
            _allowedValues = element.allowedValues
            _labelUIElements = { try element.labelUIElements().map(AnyElement.init) }
            _labelValue = element.labelValue
            // Window
            _isMain = element.isMain
            _isMinimized = element.isMinimized
            _isModal = element.isModal
            _closeButton = { AnyElement(element: try element.closeButton()) }
            _zoomButton = { AnyElement(element: try element.zoomButton()) }
            _minimizeButton = { AnyElement(element: try element.minimizeButton()) }
            _toolbarButton = { AnyElement(element: try element.toolbarButton()) }
            _fullScreenButton = { AnyElement(element: try element.fullScreenButton()) }
            _defaultButton = { AnyElement(element: try element.defaultButton()) }
            _cancelButton = { AnyElement(element: try element.cancelButton()) }
            _proxy = { AnyElement(element: try element.proxy()) }
            _growArea = { AnyElement(element: try element.growArea()) }
            // Container / scroll UI
            _header = { AnyElement(element: try element.header()) }
            _tabs = { try element.tabs().map(AnyElement.init) }
            _splitters = { try element.splitters().map(AnyElement.init) }
            _horizontalScrollBar = { AnyElement(element: try element.horizontalScrollBar()) }
            _verticalScrollBar = { AnyElement(element: try element.verticalScrollBar()) }
            _overflowButton = { AnyElement(element: try element.overflowButton()) }
            _incrementButton = { AnyElement(element: try element.incrementButton()) }
            _decrementButton = { AnyElement(element: try element.decrementButton()) }
            _previousContents = { try element.previousContents().map(AnyElement.init) }
            _nextContents = { try element.nextContents().map(AnyElement.init) }
            _shownMenu = { AnyElement(element: try element.shownMenu()) }
            _searchButton = { AnyElement(element: try element.searchButton()) }
            _searchMenu = { AnyElement(element: try element.searchMenu()) }
            _clearButton = { AnyElement(element: try element.clearButton()) }
            // Outline / tree
            _isDisclosing = element.isDisclosing
            _disclosedRows = { try element.disclosedRows().map(AnyElement.init) }
            _disclosedByRow = { AnyElement(element: try element.disclosedByRow()) }
            _disclosureLevel = element.disclosureLevel
            // Misc
            _identifier = element.identifier
            _url = element.url
            _document = element.document
            _filename = element.filename
            _orientation = element.orientation
            _contents = { try element.contents().map(AnyElement.init) }
            _sharedFocusElements = { try element.sharedFocusElements().map(AnyElement.init) }
            _isExpanded = element.isExpanded
            _isEdited = element.isEdited
            _isRequired = element.isRequired
            _containsProtectedContent = element.containsProtectedContent
            _activationPoint = element.activationPoint
        }
    }

    // MARK: - General

    public var processIdentifier: pid_t {
        get throws {
            try _processIdentifier()
        }
    }

    public func role() throws -> NSAccessibility.Role {
        try _role()
    }
    public func roleDescription() throws -> String {
        try _roleDescription()
    }
    public func subrole() throws -> NSAccessibility.Subrole {
        try _subrole()
    }
    public func value() throws -> Any {
        try _value()
    }
    public func valueDescription() throws -> String {
        try _valueDescription()
    }
    public func title() throws -> String {
        try _title()
    }
    public func titleUIElement() throws -> AnyElement {
        try _titleUIElement()
    }
    public func description() throws -> String {
        try _description()
    }
    public func help() throws -> String {
        try _help()
    }
    public func isEnabled() throws -> Bool {
        try _isEnabled()
    }
    public func isFocused() throws -> Bool {
        try _isFocused()
    }
    public func isSelected() throws -> Bool {
        try _isSelected()
    }

    // MARK: - Application Attributes

    public func windows() throws -> [AnyElement] {
        try _windows()
    }
    public func mainWindow() throws -> AnyElement {
        try _mainWindow()
    }
    public func focusedWindow() throws -> AnyElement {
        try _focusedWindow()
    }
    public func focusedUIElement() throws -> AnyElement {
        try _focusedUIElement()
    }
    public func enhancedUserInterface() throws -> Bool {
        try _enhancedUserInterface()
    }
    public func setEnhancedUserInterface(_ enhancedUserInterface: Bool) throws {
        try _setEnhancedUserInterface(enhancedUserInterface)
    }
    public func isFrontmost() throws -> Bool {
        try _isFrontmost()
    }
    public func isHidden() throws -> Bool {
        try _isHidden()
    }
    public func menuBar() throws -> AnyElement {
        try _menuBar()
    }
    public func extrasMenuBar() throws -> AnyElement {
        try _extrasMenuBar()
    }

    // MARK: - Hierarchy

    public func parent() throws -> AnyElement {
        try _parent()
    }
    public func children() throws -> [AnyElement] {
        try _children()
    }
    public func childrenInNavigationOrder() throws -> [AnyElement] {
        try _childrenInNavigationOrder()
    }
    public func visibleChildren() throws -> [AnyElement] {
        try _visibleChildren()
    }
    public func selectedChildren() throws -> [AnyElement] {
        try _selectedChildren()
    }
    public func window() throws -> AnyElement {
        try _window()
    }
    public func topLevelUIElement() throws -> AnyElement {
        try _topLevelUIElement()
    }
    public func index() throws -> Int {
        try _index()
    }

    // MARK: - Actions

    public func actions() throws -> [NSAccessibility.Action] {
        try _actions()
    }
    public func description(action: NSAccessibility.Action) throws -> String {
        try _descriptionAction(action)
    }
    public func perform(action: NSAccessibility.Action) throws {
        try _performAction(action)
    }

    // MARK: - Text

    public func placeholderValue() throws -> String {
        try _placeholderValue()
    }

    // MARK: - Text (Integer Indexed)

    public func line(forIndex index: Int) throws -> Int {
        try _lineForIndex(index)
    }
    public func range(forLine line: Int) throws -> Range<Int> {
        try _rangeForLine(line)
    }
    public func range(forIndex index: Int) throws -> Range<Int> {
        try _rangeForIndex(index)
    }
    public func range(forPosition position: Int) throws -> Range<Int> {
        try _rangeForPosition(position)
    }
    public func string(for range: Range<Int>) throws -> String {
        try _stringForRange(range)
    }
    public func bounds(for range: Range<Int>) throws -> NSRect {
        try _boundsForRange(range)
    }
    public func rtf(for range: Range<Int>) throws -> Data {
        try _rtfForRange(range)
    }
    public func attributedString(for range: Range<Int>) throws -> NSAttributedString {
        try _attributedStringForRange(range)
    }
    public func styleRange(for index: Int) throws -> Range<Int> {
        try _styleRangeForIndex(index)
    }
    public func insertionPointLineNumber() throws -> Int {
        try _insertionPointLineNumber()
    }
    public func sharedCharacterRange() throws -> Range<Int> {
        try _sharedCharacterRange()
    }
    public func sharedTextUIElements() throws -> [AnyElement] {
        try _sharedTextUIElements()
    }
    public func visibleCharacterRange() throws -> Range<Int> {
        try _visibleCharacterRange()
    }
    public func setVisibleCharacterRange(_ range: Range<Int>) throws {
        try _setVisibleCharacterRange(range)
    }
    public func numberOfCharacters() throws -> Int {
        try _numberOfCharacters()
    }
    public func selectedText() throws -> String {
        try _selectedText()
    }
    public func selectedTextRange() throws -> Range<Int> {
        try _selectedTextRange()
    }
    public func selectedTextRanges() throws -> [Range<Int>] {
        try _selectedTextRanges()
    }

    // MARK: - Text (TextMarker Indexed)

    public func line(forTextMarker textMarker: TextMarker) throws -> Int {
        try _lineForTextMarker(textMarker)
    }

    // MARK: - Table/Outline/Grid/List/Collection

    public func cell(column: Int, row: Int) throws -> SystemElement {
        try _cellForColumnRow(column, row)
    }
    public func rows() throws -> [AnyElement] {
        try _rows()
    }
    public func columns() throws -> [AnyElement] {
        try _columns()
    }
    public func selectedRows() throws -> [AnyElement] {
        try _selectedRows()
    }
    public func selectedColumns() throws -> [AnyElement] {
        try _selectedColumns()
    }
    public func selectedCells() throws -> [AnyElement] {
        try _selectedCells()
    }
    public func visibleRows() throws -> [AnyElement] {
        try _visibleRows()
    }
    public func visibleColumns() throws -> [AnyElement] {
        try _visibleColumns()
    }
    public func visibleCells() throws -> [AnyElement] {
        try _visibleCells()
    }
    public func rowHeaderUIElements() throws -> [AnyElement] {
        try _rowHeaderUIElements()
    }
    public func columnHeaderUIElements() throws -> [AnyElement] {
        try _columnHeaderUIElements()
    }
    public func columnTitles() throws -> [AnyElement] {
        try _columnTitles()
    }
    public func sortDirection() throws -> String {
        try _sortDirection()
    }
    public func rowCount() throws -> Int {
        try _rowCount()
    }
    public func columnCount() throws -> Int {
        try _columnCount()
    }
    public func isOrderedByRow() throws -> Bool {
        try _isOrderedByRow()
    }
    public func rowIndexRange() throws -> Range<Int> {
        try _rowIndexRange()
    }
    public func columnIndexRange() throws -> Range<Int> {
        try _columnIndexRange()
    }

    // MARK: - Layout

    public func frame() throws -> NSRect {
        try _frame()
    }
    public func setPosition(_ position: CGPoint) throws {
        try _setPosition(position)
    }

    // MARK: - Linked Elements

    public func linkedUIElements() throws -> [AnyElement] {
        try _linkedUIElements()
    }
    public func servesAsTitleForUIElements() throws -> [AnyElement] {
        try _servesAsTitleForUIElements()
    }

    // MARK: - Slider

    public func minValue() throws -> Any {
        try _minValue()
    }
    public func maxValue() throws -> Any {
        try _maxValue()
    }
    public func warningValue() throws -> Any {
        try _warningValue()
    }
    public func criticalValue() throws -> Any {
        try _criticalValue()
    }
    public func allowedValues() throws -> [Double] {
        try _allowedValues()
    }
    public func labelUIElements() throws -> [AnyElement] {
        try _labelUIElements()
    }
    public func labelValue() throws -> Double {
        try _labelValue()
    }

    // MARK: - Window

    public func isMain() throws -> Bool {
        try _isMain()
    }
    public func isMinimized() throws -> Bool {
        try _isMinimized()
    }
    public func isModal() throws -> Bool {
        try _isModal()
    }
    public func closeButton() throws -> AnyElement {
        try _closeButton()
    }
    public func zoomButton() throws -> AnyElement {
        try _zoomButton()
    }
    public func minimizeButton() throws -> AnyElement {
        try _minimizeButton()
    }
    public func toolbarButton() throws -> AnyElement {
        try _toolbarButton()
    }
    public func fullScreenButton() throws -> AnyElement {
        try _fullScreenButton()
    }
    public func defaultButton() throws -> AnyElement {
        try _defaultButton()
    }
    public func cancelButton() throws -> AnyElement {
        try _cancelButton()
    }
    public func proxy() throws -> AnyElement {
        try _proxy()
    }
    public func growArea() throws -> AnyElement {
        try _growArea()
    }

    // MARK: - Container / scroll UI

    public func header() throws -> AnyElement {
        try _header()
    }
    public func tabs() throws -> [AnyElement] {
        try _tabs()
    }
    public func splitters() throws -> [AnyElement] {
        try _splitters()
    }
    public func horizontalScrollBar() throws -> AnyElement {
        try _horizontalScrollBar()
    }
    public func verticalScrollBar() throws -> AnyElement {
        try _verticalScrollBar()
    }
    public func overflowButton() throws -> AnyElement {
        try _overflowButton()
    }
    public func incrementButton() throws -> AnyElement {
        try _incrementButton()
    }
    public func decrementButton() throws -> AnyElement {
        try _decrementButton()
    }
    public func previousContents() throws -> [AnyElement] {
        try _previousContents()
    }
    public func nextContents() throws -> [AnyElement] {
        try _nextContents()
    }
    public func shownMenu() throws -> AnyElement {
        try _shownMenu()
    }
    public func searchButton() throws -> AnyElement {
        try _searchButton()
    }
    public func searchMenu() throws -> AnyElement {
        try _searchMenu()
    }
    public func clearButton() throws -> AnyElement {
        try _clearButton()
    }

    // MARK: - Outline / tree

    public func isDisclosing() throws -> Bool {
        try _isDisclosing()
    }
    public func disclosedRows() throws -> [AnyElement] {
        try _disclosedRows()
    }
    public func disclosedByRow() throws -> AnyElement {
        try _disclosedByRow()
    }
    public func disclosureLevel() throws -> Int {
        try _disclosureLevel()
    }

    // MARK: - Misc

    public func identifier() throws -> String {
        try _identifier()
    }
    public func url() throws -> URL {
        try _url()
    }
    public func document() throws -> String {
        try _document()
    }
    public func filename() throws -> String {
        try _filename()
    }
    public func orientation() throws -> String {
        try _orientation()
    }
    public func contents() throws -> [AnyElement] {
        try _contents()
    }
    public func sharedFocusElements() throws -> [AnyElement] {
        try _sharedFocusElements()
    }
    public func isExpanded() throws -> Bool {
        try _isExpanded()
    }
    public func isEdited() throws -> Bool {
        try _isEdited()
    }
    public func isRequired() throws -> Bool {
        try _isRequired()
    }
    public func containsProtectedContent() throws -> Bool {
        try _containsProtectedContent()
    }
    public func activationPoint() throws -> CGPoint {
        try _activationPoint()
    }
}
