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

    private let _role: @Sendable () throws -> NSAccessibility.Role
    private let _roleDescription: @Sendable () throws -> String
    private let _subrole: @Sendable () throws -> NSAccessibility.Subrole
    private let _value: @Sendable () throws -> any Sendable
    private let _title: @Sendable () throws -> String
    private let _titleUIElement: @Sendable () throws -> AnyElement
    private let _processIdentifier: @Sendable () throws -> pid_t
    private let _windows: @Sendable () throws -> [AnyElement]
    private let _mainWindow: @Sendable () throws -> AnyElement
    private let _focusedWindow: @Sendable () throws -> AnyElement
    private let _focusedUIElement: @Sendable () throws -> AnyElement
    private let _parent: @Sendable () throws -> AnyElement
    private let _children: @Sendable () throws -> [AnyElement]
    private let _childrenInNavigationOrder: @Sendable () throws -> [AnyElement]
    private let _visibleChildren: @Sendable () throws -> [AnyElement]
    private let _selectedChildren: @Sendable () throws -> [AnyElement]
    private let _rows: @Sendable () throws -> [AnyElement]
    private let _columns: @Sendable () throws -> [AnyElement]
    private let _selectedRows: @Sendable () throws -> [AnyElement]
    private let _selectedColumns: @Sendable () throws -> [AnyElement]
    private let _selectedCells: @Sendable () throws -> [AnyElement]
    private let _enhancedUserInterface: @Sendable () throws -> Bool
    private let _setEnhancedUserInterface: @Sendable (Bool) throws -> Void
    private let _actions: @Sendable () throws -> [NSAccessibility.Action]
    private let _descriptionAction: @Sendable (NSAccessibility.Action) throws -> String
    private let _performAction: @Sendable (NSAccessibility.Action) throws -> Void
    private let _lineForIndex: @Sendable (Int) throws -> Int
    private let _lineForTextMarker: @Sendable (TextMarker) throws -> Int
    private let _rangeForLine: @Sendable (Int) throws -> Range<Int>
    private let _rangeForIndex: @Sendable (Int) throws -> Range<Int>
    private let _rangeForPosition: @Sendable (Int) throws -> Range<Int>
    private let _stringForRange: @Sendable (Range<Int>) throws -> String
    private let _boundsForRange: @Sendable (Range<Int>) throws -> NSRect
    private let _rtfForRange: @Sendable (Range<Int>) throws -> Data
    private let _attributedStringForRange: @Sendable (Range<Int>) throws -> NSAttributedString
    private let _styleRangeForIndex: @Sendable (Int) throws -> Range<Int>
    private let _cellForColumnRow: @Sendable (Int, Int) throws -> SystemElement
    private let _insertionPointLineNumber: @Sendable () throws -> Int
    private let _sharedCharacterRange: @Sendable () throws -> Range<Int>
    private let _sharedTextUIElements: @Sendable () throws -> [AnyElement]
    private let _visibleCharacterRange: @Sendable () throws -> Range<Int>
    private let _numberOfCharacters: @Sendable () throws -> Int
    private let _selectedText: @Sendable () throws -> String
    private let _selectedTextRange: @Sendable () throws -> Range<Int>
    private let _selectedTextRanges: @Sendable () throws -> [Range<Int>]

    // MARK: - Initializer

    public init<E: Element>(element: E) {
        if let alreadyAny = element as? AnyElement {
            self = alreadyAny
        } else {
            _role = element.role
            _roleDescription = element.roleDescription
            _subrole = element.subrole
            _value = element.value
            _title = element.title
            _titleUIElement = { AnyElement(element: try element.titleUIElement()) }
            _processIdentifier = { try element.processIdentifier }
            _windows = { try element.windows().map(AnyElement.init) }
            _mainWindow = { AnyElement(element: try element.mainWindow()) }
            _focusedWindow = { AnyElement(element: try element.focusedWindow()) }
            _focusedUIElement = { AnyElement(element: try element.focusedUIElement()) }
            _parent = { AnyElement(element: try element.parent()) }
            _children = { try element.children().map(AnyElement.init) }
            _childrenInNavigationOrder = { try element.childrenInNavigationOrder().map(AnyElement.init) }
            _visibleChildren = { try element.visibleChildren().map(AnyElement.init) }
            _selectedChildren = { try element.selectedChildren().map(AnyElement.init) }
            _rows = { try element.rows().map(AnyElement.init) }
            _columns = { try element.columns().map(AnyElement.init) }
            _selectedRows = { try element.selectedRows().map(AnyElement.init) }
            _selectedColumns = { try element.selectedColumns().map(AnyElement.init) }
            _selectedCells = { try element.selectedCells().map(AnyElement.init) }
            _enhancedUserInterface = element.enhancedUserInterface
            _setEnhancedUserInterface = element.setEnhancedUserInterface
            _actions = element.actions
            _descriptionAction = element.description(action:)
            _performAction = element.perform(action:)
            _lineForIndex = element.line(forIndex:)
            _lineForTextMarker = element.line(forTextMarker:)
            _rangeForLine = element.range(forLine:)
            _rangeForIndex = element.range(forIndex:)
            _rangeForPosition = element.range(forPosition:)
            _stringForRange = element.string(for:)
            _boundsForRange = element.bounds(for:)
            _rtfForRange = element.rtf(for:)
            _attributedStringForRange = element.attributedString(for:)
            _styleRangeForIndex = element.styleRange(for:)
            _cellForColumnRow = element.cell(column:row:)
            _insertionPointLineNumber = element.insertionPointLineNumber
            _sharedCharacterRange = element.sharedCharacterRange
            _sharedTextUIElements = { try element.sharedTextUIElements().map(AnyElement.init) }
            _visibleCharacterRange = element.visibleCharacterRange
            _numberOfCharacters = element.numberOfCharacters
            _selectedText = element.selectedText
            _selectedTextRange = element.selectedTextRange
            _selectedTextRanges = element.selectedTextRanges
        }
    }

    // MARK: - Public Element API

    public func role() throws -> NSAccessibility.Role {
        try _role()
    }

    public func roleDescription() throws -> String {
        try _roleDescription()
    }

    public func subrole() throws -> NSAccessibility.Subrole {
        try _subrole()
    }

    public func value() throws -> any Sendable {
        try _value()
    }

    public func title() throws -> String {
        try _title()
    }

    public func titleUIElement() throws -> AnyElement {
        try _titleUIElement()
    }

    public var processIdentifier: pid_t {
        get throws {
            try _processIdentifier()
        }
    }

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

    public func enhancedUserInterface() throws -> Bool {
        try _enhancedUserInterface()
    }

    public func setEnhancedUserInterface(_ enhancedUserInterface: Bool) throws {
        try _setEnhancedUserInterface(enhancedUserInterface)
    }

    public func actions() throws -> [NSAccessibility.Action] {
        try _actions()
    }

    public func description(action: NSAccessibility.Action) throws -> String {
        try _descriptionAction(action)
    }

    public func perform(action: NSAccessibility.Action) throws {
        try _performAction(action)
    }

    public func line(forIndex index: Int) throws -> Int {
        try _lineForIndex(index)
    }

    public func line(forTextMarker textMarker: TextMarker) throws -> Int {
        try _lineForTextMarker(textMarker)
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

    public func cell(column: Int, row: Int) throws -> SystemElement {
        try _cellForColumnRow(column, row)
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
}
