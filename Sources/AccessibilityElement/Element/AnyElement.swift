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

    private let _processIdentifier: @Sendable () async throws -> pid_t

    // General
    private let _role: @Sendable () async throws -> NSAccessibility.Role
    private let _roleDescription: @Sendable () async throws -> String
    private let _subrole: @Sendable () async throws -> NSAccessibility.Subrole
    private let _value: @Sendable () async throws -> Any
    private let _valueDescription: @Sendable () async throws -> String
    private let _title: @Sendable () async throws -> String
    private let _titleUIElement: @Sendable () async throws -> AnyElement
    private let _description: @Sendable () async throws -> String
    private let _help: @Sendable () async throws -> String
    private let _isEnabled: @Sendable () async throws -> Bool
    private let _isFocused: @Sendable () async throws -> Bool
    private let _isSelected: @Sendable () async throws -> Bool
    // Application Attributes
    private let _windows: @Sendable () async throws -> [AnyElement]
    private let _mainWindow: @Sendable () async throws -> AnyElement
    private let _focusedWindow: @Sendable () async throws -> AnyElement
    private let _focusedUIElement: @Sendable () async throws -> AnyElement
    private let _enhancedUserInterface: @Sendable () async throws -> Bool
    private let _setEnhancedUserInterface: @Sendable (Bool) async throws -> Void
    private let _isFrontmost: @Sendable () async throws -> Bool
    private let _isHidden: @Sendable () async throws -> Bool
    private let _menuBar: @Sendable () async throws -> AnyElement
    private let _extrasMenuBar: @Sendable () async throws -> AnyElement
    // Hierarchy
    private let _parent: @Sendable () async throws -> AnyElement
    private let _children: @Sendable () async throws -> [AnyElement]
    private let _childrenView: @Sendable () -> ArrayAttributeView<AnyElement>
    private let _childrenInNavigationOrder: @Sendable () async throws -> [AnyElement]
    private let _childrenInNavigationOrderView: @Sendable () -> ArrayAttributeView<AnyElement>
    private let _visibleChildren: @Sendable () async throws -> [AnyElement]
    private let _visibleChildrenView: @Sendable () -> ArrayAttributeView<AnyElement>
    private let _selectedChildren: @Sendable () async throws -> [AnyElement]
    private let _selectedChildrenView: @Sendable () -> ArrayAttributeView<AnyElement>
    private let _window: @Sendable () async throws -> AnyElement
    private let _topLevelUIElement: @Sendable () async throws -> AnyElement
    private let _index: @Sendable () async throws -> Int
    // Hierarchy (Web)
    private let _focusableAncestor: @Sendable () async throws -> AnyElement
    private let _editableAncestor: @Sendable () async throws -> AnyElement
    private let _highestEditableAncestor: @Sendable () async throws -> AnyElement
    // Actions
    private let _actions: @Sendable () async throws -> [NSAccessibility.Action]
    private let _descriptionAction: @Sendable (NSAccessibility.Action) async throws -> String
    private let _performAction: @Sendable (NSAccessibility.Action) async throws -> Void
    // Text
    private let _placeholderValue: @Sendable () async throws -> String
    // Text (Integer Indexed)
    private let _lineForIndex: @Sendable (Int) async throws -> Int
    private let _rangeForLine: @Sendable (Int) async throws -> Range<Int>
    private let _rangeForIndex: @Sendable (Int) async throws -> Range<Int>
    private let _rangeForPosition: @Sendable (Int) async throws -> Range<Int>
    private let _stringForRange: @Sendable (Range<Int>) async throws -> String
    private let _boundsForRange: @Sendable (Range<Int>) async throws -> NSRect
    private let _rtfForRange: @Sendable (Range<Int>) async throws -> Data
    private let _attributedStringForRange: @Sendable (Range<Int>) async throws -> NSAttributedString
    private let _styleRangeForIndex: @Sendable (Int) async throws -> Range<Int>
    private let _insertionPointLineNumber: @Sendable () async throws -> Int
    private let _sharedCharacterRange: @Sendable () async throws -> Range<Int>
    private let _sharedTextUIElements: @Sendable () async throws -> [AnyElement]
    private let _visibleCharacterRange: @Sendable () async throws -> Range<Int>
    private let _setVisibleCharacterRange: @Sendable (Range<Int>) async throws -> Void
    private let _numberOfCharacters: @Sendable () async throws -> Int
    private let _selectedText: @Sendable () async throws -> String
    private let _selectedTextRange: @Sendable () async throws -> Range<Int>
    private let _selectedTextRanges: @Sendable () async throws -> [Range<Int>]
    // Text (TextMarker Indexed)
    private let _lineForTextMarker: @Sendable (TextMarker) async throws -> Int
    private let _selectedTextMarkerRange: @Sendable () async throws -> TextMarkerRange
    private let _startTextMarker: @Sendable () async throws -> TextMarker
    private let _endTextMarker: @Sendable () async throws -> TextMarker
    private let _nextTextMarker: @Sendable (TextMarker) async throws -> TextMarker
    private let _previousTextMarker: @Sendable (TextMarker) async throws -> TextMarker
    private let _nextWordEndTextMarker: @Sendable (TextMarker) async throws -> TextMarker
    private let _previousWordStartTextMarker: @Sendable (TextMarker) async throws -> TextMarker
    private let _nextLineEndTextMarker: @Sendable (TextMarker) async throws -> TextMarker
    private let _previousLineStartTextMarker: @Sendable (TextMarker) async throws -> TextMarker
    private let _nextSentenceEndTextMarker: @Sendable (TextMarker) async throws -> TextMarker
    private let _previousSentenceStartTextMarker: @Sendable (TextMarker) async throws -> TextMarker
    private let _nextParagraphEndTextMarker: @Sendable (TextMarker) async throws -> TextMarker
    private let _previousParagraphStartTextMarker: @Sendable (TextMarker) async throws -> TextMarker
    private let _lineTextMarkerRange: @Sendable (TextMarker) async throws -> TextMarkerRange
    private let _leftWordTextMarkerRange: @Sendable (TextMarker) async throws -> TextMarkerRange
    private let _rightWordTextMarkerRange: @Sendable (TextMarker) async throws -> TextMarkerRange
    private let _leftLineTextMarkerRange: @Sendable (TextMarker) async throws -> TextMarkerRange
    private let _rightLineTextMarkerRange: @Sendable (TextMarker) async throws -> TextMarkerRange
    private let _sentenceTextMarkerRange: @Sendable (TextMarker) async throws -> TextMarkerRange
    private let _paragraphTextMarkerRange: @Sendable (TextMarker) async throws -> TextMarkerRange
    private let _styleTextMarkerRange: @Sendable (TextMarker) async throws -> TextMarkerRange
    private let _lineNumberForTextMarker: @Sendable (TextMarker) async throws -> Int
    private let _indexForTextMarker: @Sendable (TextMarker) async throws -> Int
    private let _elementForTextMarker: @Sendable (TextMarker) async throws -> AnyElement
    private let _stringForTextMarkerRange: @Sendable (TextMarkerRange) async throws -> String
    private let _attributedStringForTextMarkerRange: @Sendable (TextMarkerRange) async throws -> NSAttributedString
    private let _boundsForTextMarkerRange: @Sendable (TextMarkerRange) async throws -> NSRect
    private let _lengthForTextMarkerRange: @Sendable (TextMarkerRange) async throws -> Int
    private let _textMarkerForIndex: @Sendable (Int) async throws -> TextMarker
    private let _textMarkerRangeForLine: @Sendable (Int) async throws -> TextMarkerRange
    private let _textMarkerForPosition: @Sendable (CGPoint) async throws -> TextMarker
    private let _startTextMarkerForBounds: @Sendable (NSRect) async throws -> TextMarker
    private let _endTextMarkerForBounds: @Sendable (NSRect) async throws -> TextMarker
    private let _textMarkerRangeForUnordered: @Sendable ([TextMarker]) async throws -> TextMarkerRange
    private let _textMarkerRangeForOrdered: @Sendable ([TextMarker]) async throws -> TextMarkerRange
    // Text marker validation
    private let _isNullTextMarker: @Sendable (TextMarker) async throws -> Bool
    private let _isValidTextMarker: @Sendable (TextMarker) async throws -> Bool
    // Table/Outline/Grid/List/Collection
    private let _cellForColumnRow: @Sendable (Int, Int) async throws -> AnyElement
    private let _rows: @Sendable () async throws -> [AnyElement]
    private let _rowsView: @Sendable () async throws -> ArrayAttributeView<AnyElement>
    private let _columns: @Sendable () async throws -> [AnyElement]
    private let _columnsView: @Sendable () async throws -> ArrayAttributeView<AnyElement>
    private let _selectedRows: @Sendable () async throws -> [AnyElement]
    private let _selectedRowsView: @Sendable () async throws -> ArrayAttributeView<AnyElement>
    private let _selectedColumns: @Sendable () async throws -> [AnyElement]
    private let _selectedColumnsView: @Sendable () async throws -> ArrayAttributeView<AnyElement>
    private let _selectedCells: @Sendable () async throws -> [AnyElement]
    private let _selectedCellsView: @Sendable () async throws -> ArrayAttributeView<AnyElement>
    private let _visibleRows: @Sendable () async throws -> [AnyElement]
    private let _visibleRowsView: @Sendable () async throws -> ArrayAttributeView<AnyElement>
    private let _visibleColumns: @Sendable () async throws -> [AnyElement]
    private let _visibleColumnsView: @Sendable () async throws -> ArrayAttributeView<AnyElement>
    private let _visibleCells: @Sendable () async throws -> [AnyElement]
    private let _visibleCellsView: @Sendable () async throws -> ArrayAttributeView<AnyElement>
    private let _rowHeaderUIElements: @Sendable () async throws -> [AnyElement]
    private let _rowHeaderUIElementsView: @Sendable () async throws -> ArrayAttributeView<AnyElement>
    private let _columnHeaderUIElements: @Sendable () async throws -> [AnyElement]
    private let _columnHeaderUIElementsView: @Sendable () async throws -> ArrayAttributeView<AnyElement>
    private let _columnTitles: @Sendable () async throws -> [AnyElement]
    private let _columnTitlesView: @Sendable () async throws -> ArrayAttributeView<AnyElement>
    private let _sortDirection: @Sendable () async throws -> String
    private let _rowCount: @Sendable () async throws -> Int
    private let _columnCount: @Sendable () async throws -> Int
    private let _isOrderedByRow: @Sendable () async throws -> Bool
    private let _rowIndexRange: @Sendable () async throws -> Range<Int>
    private let _columnIndexRange: @Sendable () async throws -> Range<Int>
    // Layout
    private let _frame: @Sendable () async throws -> NSRect
    private let _setPosition: @Sendable (CGPoint) async throws -> Void
    // Linked Elements
    private let _linkedUIElements: @Sendable () async throws -> [AnyElement]
    private let _servesAsTitleForUIElements: @Sendable () async throws -> [AnyElement]
    // Slider
    private let _minValue: @Sendable () async throws -> Any
    private let _maxValue: @Sendable () async throws -> Any
    private let _warningValue: @Sendable () async throws -> Any
    private let _criticalValue: @Sendable () async throws -> Any
    private let _allowedValues: @Sendable () async throws -> [Double]
    private let _labelUIElements: @Sendable () async throws -> [AnyElement]
    private let _labelValue: @Sendable () async throws -> Double
    // Window
    private let _isMain: @Sendable () async throws -> Bool
    private let _isMinimized: @Sendable () async throws -> Bool
    private let _isModal: @Sendable () async throws -> Bool
    private let _closeButton: @Sendable () async throws -> AnyElement
    private let _zoomButton: @Sendable () async throws -> AnyElement
    private let _minimizeButton: @Sendable () async throws -> AnyElement
    private let _toolbarButton: @Sendable () async throws -> AnyElement
    private let _fullScreenButton: @Sendable () async throws -> AnyElement
    private let _defaultButton: @Sendable () async throws -> AnyElement
    private let _cancelButton: @Sendable () async throws -> AnyElement
    private let _proxy: @Sendable () async throws -> AnyElement
    private let _growArea: @Sendable () async throws -> AnyElement
    // Container / scroll UI
    private let _header: @Sendable () async throws -> AnyElement
    private let _tabs: @Sendable () async throws -> [AnyElement]
    private let _splitters: @Sendable () async throws -> [AnyElement]
    private let _horizontalScrollBar: @Sendable () async throws -> AnyElement
    private let _verticalScrollBar: @Sendable () async throws -> AnyElement
    private let _overflowButton: @Sendable () async throws -> AnyElement
    private let _incrementButton: @Sendable () async throws -> AnyElement
    private let _decrementButton: @Sendable () async throws -> AnyElement
    private let _previousContents: @Sendable () async throws -> [AnyElement]
    private let _nextContents: @Sendable () async throws -> [AnyElement]
    private let _shownMenu: @Sendable () async throws -> AnyElement
    private let _searchButton: @Sendable () async throws -> AnyElement
    private let _searchMenu: @Sendable () async throws -> AnyElement
    private let _clearButton: @Sendable () async throws -> AnyElement
    // Outline / tree
    private let _isDisclosing: @Sendable () async throws -> Bool
    private let _disclosedRows: @Sendable () async throws -> [AnyElement]
    private let _disclosedByRow: @Sendable () async throws -> AnyElement
    private let _disclosureLevel: @Sendable () async throws -> Int
    // Misc
    private let _identifier: @Sendable () async throws -> String
    private let _url: @Sendable () async throws -> URL
    private let _document: @Sendable () async throws -> String
    private let _filename: @Sendable () async throws -> String
    private let _orientation: @Sendable () async throws -> String
    private let _contents: @Sendable () async throws -> [AnyElement]
    private let _sharedFocusElements: @Sendable () async throws -> [AnyElement]
    private let _isExpanded: @Sendable () async throws -> Bool
    private let _isEdited: @Sendable () async throws -> Bool
    private let _isRequired: @Sendable () async throws -> Bool
    private let _containsProtectedContent: @Sendable () async throws -> Bool
    private let _activationPoint: @Sendable () async throws -> CGPoint
    // Web
    private let _isLoaded: @Sendable () async throws -> Bool
    private let _loadingProgress: @Sendable () async throws -> Double
    private let _layoutCount: @Sendable () async throws -> Int
    private let _preventKeyboardDOMEventDispatch: @Sendable () async throws -> Bool
    // MathML
    private let _mathBase: @Sendable () async throws -> AnyElement
    private let _mathFencedOpen: @Sendable () async throws -> String
    private let _mathFencedClose: @Sendable () async throws -> String
    private let _mathFractionNumerator: @Sendable () async throws -> AnyElement
    private let _mathFractionDenominator: @Sendable () async throws -> AnyElement
    private let _mathLineThickness: @Sendable () async throws -> Double
    private let _mathOver: @Sendable () async throws -> AnyElement
    private let _mathUnder: @Sendable () async throws -> AnyElement
    private let _mathPostscripts: @Sendable () async throws -> [AnyElement]
    private let _mathPrescripts: @Sendable () async throws -> [AnyElement]
    private let _mathRootIndex: @Sendable () async throws -> AnyElement
    private let _mathRootRadicand: @Sendable () async throws -> AnyElement
    private let _mathSubscript: @Sendable () async throws -> AnyElement
    private let _mathSuperscript: @Sendable () async throws -> AnyElement

    // MARK: - Initializer

    public init<E: Element>(element: E) where E: ArrayAttributeElement {
        if let alreadyAny = element as? AnyElement {
            self = alreadyAny
        } else {
            _processIdentifier = { try await element.processIdentifier }
            // General
            _role = element.role
            _roleDescription = element.roleDescription
            _subrole = element.subrole
            _value = element.value
            _valueDescription = element.valueDescription
            _title = element.title
            _titleUIElement = { AnyElement(element: try await element.titleUIElement()) }
            _description = element.description
            _help = element.help
            _isEnabled = element.isEnabled
            _isFocused = element.isFocused
            _isSelected = element.isSelected
            // Application Attributes
            _windows = { try await element.windows().map(AnyElement.init) }
            _mainWindow = { AnyElement(element: try await element.mainWindow()) }
            _focusedWindow = { AnyElement(element: try await element.focusedWindow()) }
            _focusedUIElement = { AnyElement(element: try await element.focusedUIElement()) }
            _enhancedUserInterface = element.enhancedUserInterface
            _setEnhancedUserInterface = element.setEnhancedUserInterface
            _isFrontmost = element.isFrontmost
            _isHidden = element.isHidden
            _menuBar = { AnyElement(element: try await element.menuBar()) }
            _extrasMenuBar = { AnyElement(element: try await element.extrasMenuBar()) }
            // Hierarchy
            @Sendable
            func view(attribute: NSAccessibility.Attribute) -> ArrayAttributeView<AnyElement> {
                ArrayAttributeView(
                    count: {
                        try element.count(attribute: attribute)
                    },
                    elements: { i, n in
                        try element
                            .elements(
                                attribute: attribute,
                                index: i,
                                maxCount: n
                            )
                            .map(AnyElement.init)
                    }
                )
            }
            _parent = { AnyElement(element: try await element.parent()) }
            _children = { try await element.children().map(AnyElement.init) }
            _childrenView = { view(attribute: .children) }
            _childrenInNavigationOrder = { try await element.childrenInNavigationOrder().map(AnyElement.init) }
            _childrenInNavigationOrderView = { view(attribute: .childrenInNavigationOrderAttribute) }
            _visibleChildren = { try await element.visibleChildren().map(AnyElement.init) }
            _visibleChildrenView = { view(attribute: .visibleChildren) }
            _selectedChildren = { try await element.selectedChildren().map(AnyElement.init) }
            _selectedChildrenView = { view(attribute: .selectedChildren) }
            _window = { AnyElement(element: try await element.window()) }
            _topLevelUIElement = { AnyElement(element: try await element.topLevelUIElement()) }
            _index = element.index
            // Hierarchy (Web)
            _focusableAncestor = { AnyElement(element: try await element.focusableAncestor()) }
            _editableAncestor = { AnyElement(element: try await element.editableAncestor()) }
            _highestEditableAncestor = { AnyElement(element: try await element.highestEditableAncestor()) }
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
            _sharedTextUIElements = { try await element.sharedTextUIElements().map(AnyElement.init) }
            _visibleCharacterRange = element.visibleCharacterRange
            _setVisibleCharacterRange = element.setVisibleCharacterRange
            _numberOfCharacters = element.numberOfCharacters
            _selectedText = element.selectedText
            _selectedTextRange = element.selectedTextRange
            _selectedTextRanges = element.selectedTextRanges
            // Text (TextMarker Indexed)
            _lineForTextMarker = element.line(forTextMarker:)
            _selectedTextMarkerRange = element.selectedTextMarkerRange
            _startTextMarker = element.startTextMarker
            _endTextMarker = element.endTextMarker
            _nextTextMarker = element.nextTextMarker(for:)
            _previousTextMarker = element.previousTextMarker(for:)
            _nextWordEndTextMarker = element.nextWordEndTextMarker(for:)
            _previousWordStartTextMarker = element.previousWordStartTextMarker(for:)
            _nextLineEndTextMarker = element.nextLineEndTextMarker(for:)
            _previousLineStartTextMarker = element.previousLineStartTextMarker(for:)
            _nextSentenceEndTextMarker = element.nextSentenceEndTextMarker(for:)
            _previousSentenceStartTextMarker = element.previousSentenceStartTextMarker(for:)
            _nextParagraphEndTextMarker = element.nextParagraphEndTextMarker(for:)
            _previousParagraphStartTextMarker = element.previousParagraphStartTextMarker(for:)
            _lineTextMarkerRange = element.lineTextMarkerRange(for:)
            _leftWordTextMarkerRange = element.leftWordTextMarkerRange(for:)
            _rightWordTextMarkerRange = element.rightWordTextMarkerRange(for:)
            _leftLineTextMarkerRange = element.leftLineTextMarkerRange(for:)
            _rightLineTextMarkerRange = element.rightLineTextMarkerRange(for:)
            _sentenceTextMarkerRange = element.sentenceTextMarkerRange(for:)
            _paragraphTextMarkerRange = element.paragraphTextMarkerRange(for:)
            _styleTextMarkerRange = element.styleTextMarkerRange(for:)
            _lineNumberForTextMarker = element.lineNumber(for:)
            _indexForTextMarker = element.index(for:)
            _elementForTextMarker = { AnyElement(element: try await element.element(for: $0)) }
            _stringForTextMarkerRange = element.string(for:)
            _attributedStringForTextMarkerRange = element.attributedString(for:)
            _boundsForTextMarkerRange = element.bounds(for:)
            _lengthForTextMarkerRange = element.length(for:)
            _textMarkerForIndex = element.textMarker(forIndex:)
            _textMarkerRangeForLine = element.textMarkerRange(forLine:)
            _textMarkerForPosition = element.textMarker(forPosition:)
            _startTextMarkerForBounds = element.startTextMarker(forBounds:)
            _endTextMarkerForBounds = element.endTextMarker(forBounds:)
            _textMarkerRangeForUnordered = element.textMarkerRange(forUnordered:)
            _textMarkerRangeForOrdered = element.textMarkerRange(forOrdered:)
            // Text marker validation
            _isNullTextMarker = element.isNullTextMarker(_:)
            _isValidTextMarker = element.isValidTextMarker(_:)
            // Table/Outline/Grid/List/Collection
            _cellForColumnRow = { try await AnyElement(element: element.cell(column: $0, row:$1)) }
            _rows = { try await element.rows().map(AnyElement.init) }
            _rowsView = { view(attribute: .rows) }
            _columns = { try await element.columns().map(AnyElement.init) }
            _columnsView = { view(attribute: .columns) }
            _selectedRows = { try await element.selectedRows().map(AnyElement.init) }
            _selectedRowsView = { view(attribute: .selectedRows) }
            _selectedColumns = { try await element.selectedColumns().map(AnyElement.init) }
            _selectedColumnsView = { view(attribute: .selectedColumns) }
            _selectedCells = { try await element.selectedCells().map(AnyElement.init) }
            _selectedCellsView = { view(attribute: .selectedCells) }
            _visibleRows = { try await element.visibleRows().map(AnyElement.init) }
            _visibleRowsView = { view(attribute: .visibleRows) }
            _visibleColumns = { try await element.visibleColumns().map(AnyElement.init) }
            _visibleColumnsView = { view(attribute: .visibleColumns) }
            _visibleCells = { try await element.visibleCells().map(AnyElement.init) }
            _visibleCellsView = { view(attribute: .visibleCells) }
            _rowHeaderUIElements = { try await element.rowHeaderUIElements().map(AnyElement.init) }
            _rowHeaderUIElementsView = { view(attribute: .rowHeaderUIElements) }
            _columnHeaderUIElements = { try await element.columnHeaderUIElements().map(AnyElement.init) }
            _columnHeaderUIElementsView = { view(attribute: .columnHeaderUIElements) }
            _columnTitles = { try await element.columnTitles().map(AnyElement.init) }
            _columnTitlesView = { view(attribute: .columnTitles) }
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
            _linkedUIElements = { try await element.linkedUIElements().map(AnyElement.init) }
            _servesAsTitleForUIElements = { try await element.servesAsTitleForUIElements().map(AnyElement.init) }
            // Slider
            _minValue = element.minValue
            _maxValue = element.maxValue
            _warningValue = element.warningValue
            _criticalValue = element.criticalValue
            _allowedValues = element.allowedValues
            _labelUIElements = { try await element.labelUIElements().map(AnyElement.init) }
            _labelValue = element.labelValue
            // Window
            _isMain = element.isMain
            _isMinimized = element.isMinimized
            _isModal = element.isModal
            _closeButton = { AnyElement(element: try await element.closeButton()) }
            _zoomButton = { AnyElement(element: try await element.zoomButton()) }
            _minimizeButton = { AnyElement(element: try await element.minimizeButton()) }
            _toolbarButton = { AnyElement(element: try await element.toolbarButton()) }
            _fullScreenButton = { AnyElement(element: try await element.fullScreenButton()) }
            _defaultButton = { AnyElement(element: try await element.defaultButton()) }
            _cancelButton = { AnyElement(element: try await element.cancelButton()) }
            _proxy = { AnyElement(element: try await element.proxy()) }
            _growArea = { AnyElement(element: try await element.growArea()) }
            // Container / scroll UI
            _header = { AnyElement(element: try await element.header()) }
            _tabs = { try await element.tabs().map(AnyElement.init) }
            _splitters = { try await element.splitters().map(AnyElement.init) }
            _horizontalScrollBar = { AnyElement(element: try await element.horizontalScrollBar()) }
            _verticalScrollBar = { AnyElement(element: try await element.verticalScrollBar()) }
            _overflowButton = { AnyElement(element: try await element.overflowButton()) }
            _incrementButton = { AnyElement(element: try await element.incrementButton()) }
            _decrementButton = { AnyElement(element: try await element.decrementButton()) }
            _previousContents = { try await element.previousContents().map(AnyElement.init) }
            _nextContents = { try await element.nextContents().map(AnyElement.init) }
            _shownMenu = { AnyElement(element: try await element.shownMenu()) }
            _searchButton = { AnyElement(element: try await element.searchButton()) }
            _searchMenu = { AnyElement(element: try await element.searchMenu()) }
            _clearButton = { AnyElement(element: try await element.clearButton()) }
            // Outline / tree
            _isDisclosing = element.isDisclosing
            _disclosedRows = { try await element.disclosedRows().map(AnyElement.init) }
            _disclosedByRow = { AnyElement(element: try await element.disclosedByRow()) }
            _disclosureLevel = element.disclosureLevel
            // Misc
            _identifier = element.identifier
            _url = element.url
            _document = element.document
            _filename = element.filename
            _orientation = element.orientation
            _contents = { try await element.contents().map(AnyElement.init) }
            _sharedFocusElements = { try await element.sharedFocusElements().map(AnyElement.init) }
            _isExpanded = element.isExpanded
            _isEdited = element.isEdited
            _isRequired = element.isRequired
            _containsProtectedContent = element.containsProtectedContent
            _activationPoint = element.activationPoint
            // Web
            _isLoaded = element.isLoaded
            _loadingProgress = element.loadingProgress
            _layoutCount = element.layoutCount
            _preventKeyboardDOMEventDispatch = element.preventKeyboardDOMEventDispatch
            // MathML
            _mathBase = { AnyElement(element: try await element.mathBase()) }
            _mathFencedOpen = element.mathFencedOpen
            _mathFencedClose = element.mathFencedClose
            _mathFractionNumerator = { AnyElement(element: try await element.mathFractionNumerator()) }
            _mathFractionDenominator = { AnyElement(element: try await element.mathFractionDenominator()) }
            _mathLineThickness = element.mathLineThickness
            _mathOver = { AnyElement(element: try await element.mathOver()) }
            _mathUnder = { AnyElement(element: try await element.mathUnder()) }
            _mathPostscripts = { try await element.mathPostscripts().map(AnyElement.init) }
            _mathPrescripts = { try await element.mathPrescripts().map(AnyElement.init) }
            _mathRootIndex = { AnyElement(element: try await element.mathRootIndex()) }
            _mathRootRadicand = { AnyElement(element: try await element.mathRootRadicand()) }
            _mathSubscript = { AnyElement(element: try await element.mathSubscript()) }
            _mathSuperscript = { AnyElement(element: try await element.mathSuperscript()) }
        }
    }

    public init<E: Element>(element: E) {
        if let alreadyAny = element as? AnyElement {
            self = alreadyAny
        } else {
            _processIdentifier = { try await element.processIdentifier }
            // General
            _role = element.role
            _roleDescription = element.roleDescription
            _subrole = element.subrole
            _value = element.value
            _valueDescription = element.valueDescription
            _title = element.title
            _titleUIElement = { AnyElement(element: try await element.titleUIElement()) }
            _description = element.description
            _help = element.help
            _isEnabled = element.isEnabled
            _isFocused = element.isFocused
            _isSelected = element.isSelected
            // Application Attributes
            _windows = { try await element.windows().map(AnyElement.init) }
            _mainWindow = { AnyElement(element: try await element.mainWindow()) }
            _focusedWindow = { AnyElement(element: try await element.focusedWindow()) }
            _focusedUIElement = { AnyElement(element: try await element.focusedUIElement()) }
            _enhancedUserInterface = element.enhancedUserInterface
            _setEnhancedUserInterface = element.setEnhancedUserInterface
            _isFrontmost = element.isFrontmost
            _isHidden = element.isHidden
            _menuBar = { AnyElement(element: try await element.menuBar()) }
            _extrasMenuBar = { AnyElement(element: try await element.extrasMenuBar()) }
            // Hierarchy
            _parent = { AnyElement(element: try await element.parent()) }
            _children = { try await element.children().map(AnyElement.init) }
            _childrenView = {
                let v = element.childrenView()
                return ArrayAttributeView(
                    count: v.count,
                    elements: { i, n in
                        try await v.elements(index: i,
                                       maxCount: n)
                            .map(AnyElement.init)
                    }
                )
            }
            _childrenInNavigationOrder = { try await element.childrenInNavigationOrder().map(AnyElement.init) }
            _childrenInNavigationOrderView = {
                let v = element.childrenInNavigationOrderView()
                return ArrayAttributeView(
                    count: v.count,
                    elements: { i, n in
                        try await v.elements(index: i,
                                       maxCount: n)
                            .map(AnyElement.init)
                    }
                )
            }
            _visibleChildren = { try await element.visibleChildren().map(AnyElement.init) }
            _visibleChildrenView = {
                let v = element.visibleChildrenView()
                return ArrayAttributeView(
                    count: v.count,
                    elements: { i, n in
                        try await v.elements(index: i,
                                       maxCount: n)
                            .map(AnyElement.init)
                    }
                )
            }
            _selectedChildren = { try await element.selectedChildren().map(AnyElement.init) }
            _selectedChildrenView = {
                let v = element.selectedChildrenView()
                return ArrayAttributeView(
                    count: v.count,
                    elements: { i, n in
                        try await v.elements(index: i,
                                       maxCount: n)
                            .map(AnyElement.init)
                    }
                )
            }
            _window = { AnyElement(element: try await element.window()) }
            _topLevelUIElement = { AnyElement(element: try await element.topLevelUIElement()) }
            _index = element.index
            // Hierarchy (Web)
            _focusableAncestor = { AnyElement(element: try await element.focusableAncestor()) }
            _editableAncestor = { AnyElement(element: try await element.editableAncestor()) }
            _highestEditableAncestor = { AnyElement(element: try await element.highestEditableAncestor()) }
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
            _sharedTextUIElements = { try await element.sharedTextUIElements().map(AnyElement.init) }
            _visibleCharacterRange = element.visibleCharacterRange
            _setVisibleCharacterRange = element.setVisibleCharacterRange
            _numberOfCharacters = element.numberOfCharacters
            _selectedText = element.selectedText
            _selectedTextRange = element.selectedTextRange
            _selectedTextRanges = element.selectedTextRanges
            // Text (TextMarker Indexed)
            _lineForTextMarker = element.line(forTextMarker:)
            _selectedTextMarkerRange = element.selectedTextMarkerRange
            _startTextMarker = element.startTextMarker
            _endTextMarker = element.endTextMarker
            _nextTextMarker = element.nextTextMarker(for:)
            _previousTextMarker = element.previousTextMarker(for:)
            _nextWordEndTextMarker = element.nextWordEndTextMarker(for:)
            _previousWordStartTextMarker = element.previousWordStartTextMarker(for:)
            _nextLineEndTextMarker = element.nextLineEndTextMarker(for:)
            _previousLineStartTextMarker = element.previousLineStartTextMarker(for:)
            _nextSentenceEndTextMarker = element.nextSentenceEndTextMarker(for:)
            _previousSentenceStartTextMarker = element.previousSentenceStartTextMarker(for:)
            _nextParagraphEndTextMarker = element.nextParagraphEndTextMarker(for:)
            _previousParagraphStartTextMarker = element.previousParagraphStartTextMarker(for:)
            _lineTextMarkerRange = element.lineTextMarkerRange(for:)
            _leftWordTextMarkerRange = element.leftWordTextMarkerRange(for:)
            _rightWordTextMarkerRange = element.rightWordTextMarkerRange(for:)
            _leftLineTextMarkerRange = element.leftLineTextMarkerRange(for:)
            _rightLineTextMarkerRange = element.rightLineTextMarkerRange(for:)
            _sentenceTextMarkerRange = element.sentenceTextMarkerRange(for:)
            _paragraphTextMarkerRange = element.paragraphTextMarkerRange(for:)
            _styleTextMarkerRange = element.styleTextMarkerRange(for:)
            _lineNumberForTextMarker = element.lineNumber(for:)
            _indexForTextMarker = element.index(for:)
            _elementForTextMarker = { AnyElement(element: try await element.element(for: $0)) }
            _stringForTextMarkerRange = element.string(for:)
            _attributedStringForTextMarkerRange = element.attributedString(for:)
            _boundsForTextMarkerRange = element.bounds(for:)
            _lengthForTextMarkerRange = element.length(for:)
            _textMarkerForIndex = element.textMarker(forIndex:)
            _textMarkerRangeForLine = element.textMarkerRange(forLine:)
            _textMarkerForPosition = element.textMarker(forPosition:)
            _startTextMarkerForBounds = element.startTextMarker(forBounds:)
            _endTextMarkerForBounds = element.endTextMarker(forBounds:)
            _textMarkerRangeForUnordered = element.textMarkerRange(forUnordered:)
            _textMarkerRangeForOrdered = element.textMarkerRange(forOrdered:)
            // Text marker validation
            _isNullTextMarker = element.isNullTextMarker(_:)
            _isValidTextMarker = element.isValidTextMarker(_:)
            // Table/Outline/Grid/List/Collection
            _cellForColumnRow = { try await AnyElement(element: element.cell(column: $0, row:$1)) }
            _rows = { try await element.rows().map(AnyElement.init) }
            _rowsView = {
                let v = try await element.rowsView()
                return ArrayAttributeView(
                    count: v.count,
                    elements: { i, n in
                        try await v.elements(index: i,
                                       maxCount: n)
                            .map(AnyElement.init)
                    }
                )
            }
            _columns = { try await element.columns().map(AnyElement.init) }
            _columnsView = {
                let v = try await element.columnsView()
                return ArrayAttributeView(
                    count: v.count,
                    elements: { i, n in
                        try await v.elements(index: i,
                                       maxCount: n)
                            .map(AnyElement.init)
                    }
                )
            }
            _selectedRows = { try await element.selectedRows().map(AnyElement.init) }
            _selectedRowsView = {
                let v = try await element.selectedRowsView()
                return ArrayAttributeView(
                    count: v.count,
                    elements: { i, n in
                        try await v.elements(index: i,
                                       maxCount: n)
                            .map(AnyElement.init)
                    }
                )
            }
            _selectedColumns = { try await element.selectedColumns().map(AnyElement.init) }
            _selectedColumnsView = {
                let v = try await element.selectedColumnsView()
                return ArrayAttributeView(
                    count: v.count,
                    elements: { i, n in
                        try await v.elements(index: i,
                                       maxCount: n)
                            .map(AnyElement.init)
                    }
                )
            }
            _selectedCells = { try await element.selectedCells().map(AnyElement.init) }
            _selectedCellsView = {
                let v = try await element.selectedCellsView()
                return ArrayAttributeView(count: v.count, elements: { i, n in try await v.elements(index: i, maxCount: n).map(AnyElement.init) })
            }
            _visibleRows = { try await element.visibleRows().map(AnyElement.init) }
            _visibleRowsView = {
                let v = try await element.visibleRowsView()
                return ArrayAttributeView(count: v.count, elements: { i, n in try await v.elements(index: i, maxCount: n).map(AnyElement.init) })
            }
            _visibleColumns = { try await element.visibleColumns().map(AnyElement.init) }
            _visibleColumnsView = {
                let v = try await element.visibleColumnsView()
                return ArrayAttributeView(
                    count: v.count,
                    elements: { i, n in
                        try await v.elements(index: i,
                                       maxCount: n)
                            .map(AnyElement.init)
                    }
                )
            }
            _visibleCells = { try await element.visibleCells().map(AnyElement.init) }
            _visibleCellsView = {
                let v = try await element.visibleCellsView()
                return ArrayAttributeView(
                    count: v.count,
                    elements: { i, n in
                        try await v.elements(index: i,
                                       maxCount: n)
                            .map(AnyElement.init)
                    }
                )
            }
            _rowHeaderUIElements = { try await element.rowHeaderUIElements().map(AnyElement.init) }
            _rowHeaderUIElementsView = {
                let v = try await element.rowHeaderUIElementsView()
                return ArrayAttributeView(
                    count: v.count,
                    elements: { i, n in
                        try await v.elements(index: i,
                                       maxCount: n)
                            .map(AnyElement.init)
                    }
                )
            }
            _columnHeaderUIElements = { try await element.columnHeaderUIElements().map(AnyElement.init) }
            _columnHeaderUIElementsView = {
                let v = try await element.columnHeaderUIElementsView()
                return ArrayAttributeView(
                    count: v.count,
                    elements: { i, n in
                        try await v.elements(index: i,
                                       maxCount: n)
                            .map(AnyElement.init)
                    }
                )
            }
            _columnTitles = { try await element.columnTitles().map(AnyElement.init) }
            _columnTitlesView = {
                let v = try await element.columnTitlesView()
                return ArrayAttributeView(
                    count: v.count,
                    elements: { i, n in
                        try await v.elements(index: i,
                                       maxCount: n)
                            .map(AnyElement.init)
                    }
                )
            }
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
            _linkedUIElements = { try await element.linkedUIElements().map(AnyElement.init) }
            _servesAsTitleForUIElements = { try await element.servesAsTitleForUIElements().map(AnyElement.init) }
            // Slider
            _minValue = element.minValue
            _maxValue = element.maxValue
            _warningValue = element.warningValue
            _criticalValue = element.criticalValue
            _allowedValues = element.allowedValues
            _labelUIElements = { try await element.labelUIElements().map(AnyElement.init) }
            _labelValue = element.labelValue
            // Window
            _isMain = element.isMain
            _isMinimized = element.isMinimized
            _isModal = element.isModal
            _closeButton = { AnyElement(element: try await element.closeButton()) }
            _zoomButton = { AnyElement(element: try await element.zoomButton()) }
            _minimizeButton = { AnyElement(element: try await element.minimizeButton()) }
            _toolbarButton = { AnyElement(element: try await element.toolbarButton()) }
            _fullScreenButton = { AnyElement(element: try await element.fullScreenButton()) }
            _defaultButton = { AnyElement(element: try await element.defaultButton()) }
            _cancelButton = { AnyElement(element: try await element.cancelButton()) }
            _proxy = { AnyElement(element: try await element.proxy()) }
            _growArea = { AnyElement(element: try await element.growArea()) }
            // Container / scroll UI
            _header = { AnyElement(element: try await element.header()) }
            _tabs = { try await element.tabs().map(AnyElement.init) }
            _splitters = { try await element.splitters().map(AnyElement.init) }
            _horizontalScrollBar = { AnyElement(element: try await element.horizontalScrollBar()) }
            _verticalScrollBar = { AnyElement(element: try await element.verticalScrollBar()) }
            _overflowButton = { AnyElement(element: try await element.overflowButton()) }
            _incrementButton = { AnyElement(element: try await element.incrementButton()) }
            _decrementButton = { AnyElement(element: try await element.decrementButton()) }
            _previousContents = { try await element.previousContents().map(AnyElement.init) }
            _nextContents = { try await element.nextContents().map(AnyElement.init) }
            _shownMenu = { AnyElement(element: try await element.shownMenu()) }
            _searchButton = { AnyElement(element: try await element.searchButton()) }
            _searchMenu = { AnyElement(element: try await element.searchMenu()) }
            _clearButton = { AnyElement(element: try await element.clearButton()) }
            // Outline / tree
            _isDisclosing = element.isDisclosing
            _disclosedRows = { try await element.disclosedRows().map(AnyElement.init) }
            _disclosedByRow = { AnyElement(element: try await element.disclosedByRow()) }
            _disclosureLevel = element.disclosureLevel
            // Misc
            _identifier = element.identifier
            _url = element.url
            _document = element.document
            _filename = element.filename
            _orientation = element.orientation
            _contents = { try await element.contents().map(AnyElement.init) }
            _sharedFocusElements = { try await element.sharedFocusElements().map(AnyElement.init) }
            _isExpanded = element.isExpanded
            _isEdited = element.isEdited
            _isRequired = element.isRequired
            _containsProtectedContent = element.containsProtectedContent
            _activationPoint = element.activationPoint
            // Web
            _isLoaded = element.isLoaded
            _loadingProgress = element.loadingProgress
            _layoutCount = element.layoutCount
            _preventKeyboardDOMEventDispatch = element.preventKeyboardDOMEventDispatch
            // MathML
            _mathBase = { AnyElement(element: try await element.mathBase()) }
            _mathFencedOpen = element.mathFencedOpen
            _mathFencedClose = element.mathFencedClose
            _mathFractionNumerator = { AnyElement(element: try await element.mathFractionNumerator()) }
            _mathFractionDenominator = { AnyElement(element: try await element.mathFractionDenominator()) }
            _mathLineThickness = element.mathLineThickness
            _mathOver = { AnyElement(element: try await element.mathOver()) }
            _mathUnder = { AnyElement(element: try await element.mathUnder()) }
            _mathPostscripts = { try await element.mathPostscripts().map(AnyElement.init) }
            _mathPrescripts = { try await element.mathPrescripts().map(AnyElement.init) }
            _mathRootIndex = { AnyElement(element: try await element.mathRootIndex()) }
            _mathRootRadicand = { AnyElement(element: try await element.mathRootRadicand()) }
            _mathSubscript = { AnyElement(element: try await element.mathSubscript()) }
            _mathSuperscript = { AnyElement(element: try await element.mathSuperscript()) }
        }
    }

    public var processIdentifier: pid_t {
        get async throws {
            try await _processIdentifier()
        }
    }

    // MARK: - General

    public func role() async throws -> NSAccessibility.Role {
        try await _role()
    }
    public func roleDescription() async throws -> String {
        try await _roleDescription()
    }
    public func subrole() async throws -> NSAccessibility.Subrole {
        try await _subrole()
    }
    public func value() async throws -> Any {
        try await _value()
    }
    public func valueDescription() async throws -> String {
        try await _valueDescription()
    }
    public func title() async throws -> String {
        try await _title()
    }
    public func titleUIElement() async throws -> AnyElement {
        try await _titleUIElement()
    }
    public func description() async throws -> String {
        try await _description()
    }
    public func help() async throws -> String {
        try await _help()
    }
    public func isEnabled() async throws -> Bool {
        try await _isEnabled()
    }
    public func isFocused() async throws -> Bool {
        try await _isFocused()
    }
    public func isSelected() async throws -> Bool {
        try await _isSelected()
    }

    // MARK: - Application Attributes

    public func windows() async throws -> [AnyElement] {
        try await _windows()
    }
    public func mainWindow() async throws -> AnyElement {
        try await _mainWindow()
    }
    public func focusedWindow() async throws -> AnyElement {
        try await _focusedWindow()
    }
    public func focusedUIElement() async throws -> AnyElement {
        try await _focusedUIElement()
    }
    public func enhancedUserInterface() async throws -> Bool {
        try await _enhancedUserInterface()
    }
    public func setEnhancedUserInterface(_ enhancedUserInterface: Bool) async throws {
        try await _setEnhancedUserInterface(enhancedUserInterface)
    }
    public func isFrontmost() async throws -> Bool {
        try await _isFrontmost()
    }
    public func isHidden() async throws -> Bool {
        try await _isHidden()
    }
    public func menuBar() async throws -> AnyElement {
        try await _menuBar()
    }
    public func extrasMenuBar() async throws -> AnyElement {
        try await _extrasMenuBar()
    }

    // MARK: - Hierarchy

    public func parent() async throws -> AnyElement {
        try await _parent()
    }
    public func children() async throws -> [AnyElement] {
        try await _children()
    }
    public func childrenInNavigationOrder() async throws -> [AnyElement] {
        try await _childrenInNavigationOrder()
    }
    public func visibleChildren() async throws -> [AnyElement] {
        try await _visibleChildren()
    }
    public func selectedChildren() async throws -> [AnyElement] {
        try await _selectedChildren()
    }
    public func childrenView() -> ArrayAttributeView<AnyElement> {
        _childrenView()
    }
    public func childrenInNavigationOrderView() -> ArrayAttributeView<AnyElement> {
        _childrenInNavigationOrderView()
    }
    public func visibleChildrenView() -> ArrayAttributeView<AnyElement> {
        _visibleChildrenView()
    }
    public func selectedChildrenView() -> ArrayAttributeView<AnyElement> {
        _selectedChildrenView()
    }
    public func window() async throws -> AnyElement {
        try await _window()
    }
    public func topLevelUIElement() async throws -> AnyElement {
        try await _topLevelUIElement()
    }
    public func index() async throws -> Int {
        try await _index()
    }

    // MARK: - Hierarchy (Web)

    public func focusableAncestor() async throws -> AnyElement {
        try await _focusableAncestor()
    }
    public func editableAncestor() async throws -> AnyElement {
        try await _editableAncestor()
    }
    public func highestEditableAncestor() async throws -> AnyElement {
        try await _highestEditableAncestor()
    }

    // MARK: - Actions

    public func actions() async throws -> [NSAccessibility.Action] {
        try await _actions()
    }
    public func description(action: NSAccessibility.Action) async throws -> String {
        try await _descriptionAction(action)
    }
    public func perform(action: NSAccessibility.Action) async throws {
        try await _performAction(action)
    }

    // MARK: - Text

    public func placeholderValue() async throws -> String {
        try await _placeholderValue()
    }

    // MARK: - Text (Integer Indexed)

    public func line(forIndex index: Int) async throws -> Int {
        try await _lineForIndex(index)
    }
    public func range(forLine line: Int) async throws -> Range<Int> {
        try await _rangeForLine(line)
    }
    public func range(forIndex index: Int) async throws -> Range<Int> {
        try await _rangeForIndex(index)
    }
    public func range(forPosition position: Int) async throws -> Range<Int> {
        try await _rangeForPosition(position)
    }
    public func string(for range: Range<Int>) async throws -> String {
        try await _stringForRange(range)
    }
    public func bounds(for range: Range<Int>) async throws -> NSRect {
        try await _boundsForRange(range)
    }
    public func rtf(for range: Range<Int>) async throws -> Data {
        try await _rtfForRange(range)
    }
    public func attributedString(for range: Range<Int>) async throws -> NSAttributedString {
        try await _attributedStringForRange(range)
    }
    public func styleRange(for index: Int) async throws -> Range<Int> {
        try await _styleRangeForIndex(index)
    }
    public func insertionPointLineNumber() async throws -> Int {
        try await _insertionPointLineNumber()
    }
    public func sharedCharacterRange() async throws -> Range<Int> {
        try await _sharedCharacterRange()
    }
    public func sharedTextUIElements() async throws -> [AnyElement] {
        try await _sharedTextUIElements()
    }
    public func visibleCharacterRange() async throws -> Range<Int> {
        try await _visibleCharacterRange()
    }
    public func setVisibleCharacterRange(_ range: Range<Int>) async throws {
        try await _setVisibleCharacterRange(range)
    }
    public func numberOfCharacters() async throws -> Int {
        try await _numberOfCharacters()
    }
    public func selectedText() async throws -> String {
        try await _selectedText()
    }
    public func selectedTextRange() async throws -> Range<Int> {
        try await _selectedTextRange()
    }
    public func selectedTextRanges() async throws -> [Range<Int>] {
        try await _selectedTextRanges()
    }

    // MARK: - Text (TextMarker Indexed)

    public func line(forTextMarker textMarker: TextMarker) async throws -> Int {
        try await _lineForTextMarker(textMarker)
    }
    public func selectedTextMarkerRange() async throws -> TextMarkerRange {
        try await _selectedTextMarkerRange()
    }
    public func startTextMarker() async throws -> TextMarker {
        try await _startTextMarker()
    }
    public func endTextMarker() async throws -> TextMarker {
        try await _endTextMarker()
    }
    public func nextTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try await _nextTextMarker(textMarker)
    }
    public func previousTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try await _previousTextMarker(textMarker)
    }
    public func nextWordEndTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try await _nextWordEndTextMarker(textMarker)
    }
    public func previousWordStartTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try await _previousWordStartTextMarker(textMarker)
    }
    public func nextLineEndTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try await _nextLineEndTextMarker(textMarker)
    }
    public func previousLineStartTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try await _previousLineStartTextMarker(textMarker)
    }
    public func nextSentenceEndTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try await _nextSentenceEndTextMarker(textMarker)
    }
    public func previousSentenceStartTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try await _previousSentenceStartTextMarker(textMarker)
    }
    public func nextParagraphEndTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try await _nextParagraphEndTextMarker(textMarker)
    }
    public func previousParagraphStartTextMarker(for textMarker: TextMarker) async throws -> TextMarker {
        try await _previousParagraphStartTextMarker(textMarker)
    }
    public func lineTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        try await _lineTextMarkerRange(textMarker)
    }
    public func leftWordTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        try await _leftWordTextMarkerRange(textMarker)
    }
    public func rightWordTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        try await _rightWordTextMarkerRange(textMarker)
    }
    public func leftLineTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        try await _leftLineTextMarkerRange(textMarker)
    }
    public func rightLineTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        try await _rightLineTextMarkerRange(textMarker)
    }
    public func sentenceTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        try await _sentenceTextMarkerRange(textMarker)
    }
    public func paragraphTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        try await _paragraphTextMarkerRange(textMarker)
    }
    public func styleTextMarkerRange(for textMarker: TextMarker) async throws -> TextMarkerRange {
        try await _styleTextMarkerRange(textMarker)
    }
    public func lineNumber(for textMarker: TextMarker) async throws -> Int {
        try await _lineNumberForTextMarker(textMarker)
    }
    public func index(for textMarker: TextMarker) async throws -> Int {
        try await _indexForTextMarker(textMarker)
    }
    public func element(for textMarker: TextMarker) async throws -> AnyElement {
        try await _elementForTextMarker(textMarker)
    }
    public func string(for textMarkerRange: TextMarkerRange) async throws -> String {
        try await _stringForTextMarkerRange(textMarkerRange)
    }
    public func attributedString(for textMarkerRange: TextMarkerRange) async throws -> NSAttributedString {
        try await _attributedStringForTextMarkerRange(textMarkerRange)
    }
    public func bounds(for textMarkerRange: TextMarkerRange) async throws -> NSRect {
        try await _boundsForTextMarkerRange(textMarkerRange)
    }
    public func length(for textMarkerRange: TextMarkerRange) async throws -> Int {
        try await _lengthForTextMarkerRange(textMarkerRange)
    }
    public func textMarker(forIndex index: Int) async throws -> TextMarker {
        try await _textMarkerForIndex(index)
    }
    public func textMarkerRange(forLine line: Int) async throws -> TextMarkerRange {
        try await _textMarkerRangeForLine(line)
    }
    public func textMarker(forPosition position: CGPoint) async throws -> TextMarker {
        try await _textMarkerForPosition(position)
    }
    public func startTextMarker(forBounds bounds: NSRect) async throws -> TextMarker {
        try await _startTextMarkerForBounds(bounds)
    }
    public func endTextMarker(forBounds bounds: NSRect) async throws -> TextMarker {
        try await _endTextMarkerForBounds(bounds)
    }
    public func textMarkerRange(for element: AnyElement) async throws -> TextMarkerRange {
        throw ElementError.noValue
    }
    public func textMarkerRange(forUnordered textMarkers: [TextMarker]) async throws -> TextMarkerRange {
        try await _textMarkerRangeForUnordered(textMarkers)
    }
    public func textMarkerRange(forOrdered textMarkers: [TextMarker]) async throws -> TextMarkerRange {
        try await _textMarkerRangeForOrdered(textMarkers)
    }

    // MARK: - Text marker validation

    public func isNullTextMarker(_ textMarker: TextMarker) async throws -> Bool {
        try await _isNullTextMarker(textMarker)
    }
    public func isValidTextMarker(_ textMarker: TextMarker) async throws -> Bool {
        try await _isValidTextMarker(textMarker)
    }

    // MARK: - Table/Outline/Grid/List/Collection

    public func cell(
        column: Int,
        row: Int
    ) async throws -> AnyElement {
        try await _cellForColumnRow(column, row)
    }
    public func rows() async throws -> [AnyElement] {
        try await _rows()
    }
    public func columns() async throws -> [AnyElement] {
        try await _columns()
    }
    public func selectedRows() async throws -> [AnyElement] {
        try await _selectedRows()
    }
    public func selectedColumns() async throws -> [AnyElement] {
        try await _selectedColumns()
    }
    public func selectedCells() async throws -> [AnyElement] {
        try await _selectedCells()
    }
    public func visibleRows() async throws -> [AnyElement] {
        try await _visibleRows()
    }
    public func visibleColumns() async throws -> [AnyElement] {
        try await _visibleColumns()
    }
    public func visibleCells() async throws -> [AnyElement] {
        try await _visibleCells()
    }
    public func rowHeaderUIElements() async throws -> [AnyElement] {
        try await _rowHeaderUIElements()
    }
    public func columnHeaderUIElements() async throws -> [AnyElement] {
        try await _columnHeaderUIElements()
    }
    public func columnTitles() async throws -> [AnyElement] {
        try await _columnTitles()
    }
    public func rowsView() async throws -> ArrayAttributeView<AnyElement> {
        try await _rowsView()
    }
    public func columnsView() async throws -> ArrayAttributeView<AnyElement> {
        try await _columnsView()
    }
    public func selectedRowsView() async throws -> ArrayAttributeView<AnyElement> {
        try await _selectedRowsView()
    }
    public func selectedColumnsView() async throws -> ArrayAttributeView<AnyElement> {
        try await _selectedColumnsView()
    }
    public func selectedCellsView() async throws -> ArrayAttributeView<AnyElement> {
        try await _selectedCellsView()
    }
    public func visibleRowsView() async throws -> ArrayAttributeView<AnyElement> {
        try await _visibleRowsView()
    }
    public func visibleColumnsView() async throws -> ArrayAttributeView<AnyElement> {
        try await _visibleColumnsView()
    }
    public func visibleCellsView() async throws -> ArrayAttributeView<AnyElement> {
        try await _visibleCellsView()
    }
    public func rowHeaderUIElementsView() async throws -> ArrayAttributeView<AnyElement> {
        try await _rowHeaderUIElementsView()
    }
    public func columnHeaderUIElementsView() async throws -> ArrayAttributeView<AnyElement> {
        try await _columnHeaderUIElementsView()
    }
    public func columnTitlesView() async throws -> ArrayAttributeView<AnyElement> {
        try await _columnTitlesView()
    }
    public func sortDirection() async throws -> String {
        try await _sortDirection()
    }
    public func rowCount() async throws -> Int {
        try await _rowCount()
    }
    public func columnCount() async throws -> Int {
        try await _columnCount()
    }
    public func isOrderedByRow() async throws -> Bool {
        try await _isOrderedByRow()
    }
    public func rowIndexRange() async throws -> Range<Int> {
        try await _rowIndexRange()
    }
    public func columnIndexRange() async throws -> Range<Int> {
        try await _columnIndexRange()
    }

    // MARK: - Layout

    public func frame() async throws -> NSRect {
        try await _frame()
    }
    public func setPosition(_ position: CGPoint) async throws {
        try await _setPosition(position)
    }

    // MARK: - Linked Elements

    public func linkedUIElements() async throws -> [AnyElement] {
        try await _linkedUIElements()
    }
    public func servesAsTitleForUIElements() async throws -> [AnyElement] {
        try await _servesAsTitleForUIElements()
    }

    // MARK: - Slider

    public func minValue() async throws -> Any {
        try await _minValue()
    }
    public func maxValue() async throws -> Any {
        try await _maxValue()
    }
    public func warningValue() async throws -> Any {
        try await _warningValue()
    }
    public func criticalValue() async throws -> Any {
        try await _criticalValue()
    }
    public func allowedValues() async throws -> [Double] {
        try await _allowedValues()
    }
    public func labelUIElements() async throws -> [AnyElement] {
        try await _labelUIElements()
    }
    public func labelValue() async throws -> Double {
        try await _labelValue()
    }

    // MARK: - Window

    public func isMain() async throws -> Bool {
        try await _isMain()
    }
    public func isMinimized() async throws -> Bool {
        try await _isMinimized()
    }
    public func isModal() async throws -> Bool {
        try await _isModal()
    }
    public func closeButton() async throws -> AnyElement {
        try await _closeButton()
    }
    public func zoomButton() async throws -> AnyElement {
        try await _zoomButton()
    }
    public func minimizeButton() async throws -> AnyElement {
        try await _minimizeButton()
    }
    public func toolbarButton() async throws -> AnyElement {
        try await _toolbarButton()
    }
    public func fullScreenButton() async throws -> AnyElement {
        try await _fullScreenButton()
    }
    public func defaultButton() async throws -> AnyElement {
        try await _defaultButton()
    }
    public func cancelButton() async throws -> AnyElement {
        try await _cancelButton()
    }
    public func proxy() async throws -> AnyElement {
        try await _proxy()
    }
    public func growArea() async throws -> AnyElement {
        try await _growArea()
    }

    // MARK: - Container / scroll UI

    public func header() async throws -> AnyElement {
        try await _header()
    }
    public func tabs() async throws -> [AnyElement] {
        try await _tabs()
    }
    public func splitters() async throws -> [AnyElement] {
        try await _splitters()
    }
    public func horizontalScrollBar() async throws -> AnyElement {
        try await _horizontalScrollBar()
    }
    public func verticalScrollBar() async throws -> AnyElement {
        try await _verticalScrollBar()
    }
    public func overflowButton() async throws -> AnyElement {
        try await _overflowButton()
    }
    public func incrementButton() async throws -> AnyElement {
        try await _incrementButton()
    }
    public func decrementButton() async throws -> AnyElement {
        try await _decrementButton()
    }
    public func previousContents() async throws -> [AnyElement] {
        try await _previousContents()
    }
    public func nextContents() async throws -> [AnyElement] {
        try await _nextContents()
    }
    public func shownMenu() async throws -> AnyElement {
        try await _shownMenu()
    }
    public func searchButton() async throws -> AnyElement {
        try await _searchButton()
    }
    public func searchMenu() async throws -> AnyElement {
        try await _searchMenu()
    }
    public func clearButton() async throws -> AnyElement {
        try await _clearButton()
    }

    // MARK: - Outline / tree

    public func isDisclosing() async throws -> Bool {
        try await _isDisclosing()
    }
    public func disclosedRows() async throws -> [AnyElement] {
        try await _disclosedRows()
    }
    public func disclosedByRow() async throws -> AnyElement {
        try await _disclosedByRow()
    }
    public func disclosureLevel() async throws -> Int {
        try await _disclosureLevel()
    }

    // MARK: - Misc

    public func identifier() async throws -> String {
        try await _identifier()
    }
    public func url() async throws -> URL {
        try await _url()
    }
    public func document() async throws -> String {
        try await _document()
    }
    public func filename() async throws -> String {
        try await _filename()
    }
    public func orientation() async throws -> String {
        try await _orientation()
    }
    public func contents() async throws -> [AnyElement] {
        try await _contents()
    }
    public func sharedFocusElements() async throws -> [AnyElement] {
        try await _sharedFocusElements()
    }
    public func isExpanded() async throws -> Bool {
        try await _isExpanded()
    }
    public func isEdited() async throws -> Bool {
        try await _isEdited()
    }
    public func isRequired() async throws -> Bool {
        try await _isRequired()
    }
    public func containsProtectedContent() async throws -> Bool {
        try await _containsProtectedContent()
    }
    public func activationPoint() async throws -> CGPoint {
        try await _activationPoint()
    }

    // MARK: - Web

    public func isLoaded() async throws -> Bool {
        try await _isLoaded()
    }
    public func loadingProgress() async throws -> Double {
        try await _loadingProgress()
    }
    public func layoutCount() async throws -> Int {
        try await _layoutCount()
    }
    public func preventKeyboardDOMEventDispatch() async throws -> Bool {
        try await _preventKeyboardDOMEventDispatch()
    }

    // MARK: - MathML

    public func mathBase() async throws -> AnyElement {
        try await _mathBase()
    }
    public func mathFencedOpen() async throws -> String {
        try await _mathFencedOpen()
    }
    public func mathFencedClose() async throws -> String {
        try await _mathFencedClose()
    }
    public func mathFractionNumerator() async throws -> AnyElement {
        try await _mathFractionNumerator()
    }
    public func mathFractionDenominator() async throws -> AnyElement {
        try await _mathFractionDenominator()
    }
    public func mathLineThickness() async throws -> Double {
        try await _mathLineThickness()
    }
    public func mathOver() async throws -> AnyElement {
        try await _mathOver()
    }
    public func mathUnder() async throws -> AnyElement {
        try await _mathUnder()
    }
    public func mathPostscripts() async throws -> [AnyElement] {
        try await _mathPostscripts()
    }
    public func mathPrescripts() async throws -> [AnyElement] {
        try await _mathPrescripts()
    }
    public func mathRootIndex() async throws -> AnyElement {
        try await _mathRootIndex()
    }
    public func mathRootRadicand() async throws -> AnyElement {
        try await _mathRootRadicand()
    }
    public func mathSubscript() async throws -> AnyElement {
        try await _mathSubscript()
    }
    public func mathSuperscript() async throws -> AnyElement {
        try await _mathSuperscript()
    }
}
