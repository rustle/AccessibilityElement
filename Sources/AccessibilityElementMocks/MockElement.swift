//
//  MockElement.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AccessibilityElement
import AppKit
import AX
import os

public final class MockElement: Element, Hashable, @unchecked Sendable {
    public static func == (
        lhs: MockElement,
        rhs: MockElement
    ) -> Bool {
        lhs === rhs
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    // Handler closures for parameterized methods that can't be served by attribute
    // storage alone. Set these before the element is used concurrently.
    public var lineForIndexHandler: (@Sendable (Int) throws -> Int)?
    public var rangeForLineHandler: (@Sendable (Int) throws -> Range<Int>)?
    public var stringForHandler: (@Sendable (Range<Int>) throws -> String)?
    public var boundsForHandler: (@Sendable (Range<Int>) throws -> NSRect)?
    public var setPositionHandler: (@Sendable (CGPoint) throws -> Void)?
    public var setVisibleCharacterRangeHandler: (@Sendable (Range<Int>) throws -> Void)?

    public func role() throws -> NSAccessibility.Role {
        try get(.role)
    }
    
    public func roleDescription() throws -> String {
        try get(.roleDescription)
    }

    public func subrole() throws -> NSAccessibility.Subrole {
        try get(.subrole)
    }

    public func value() throws -> Any {
        try get(.value)
    }

    public func title() throws -> String {
        try get(.title)
    }

    public func titleUIElement() throws -> MockElement {
        try get(.titleUIElement)
    }

    public var processIdentifier: pid_t {
        get throws {
            _pid
        }
    }

    public func windows() throws -> [MockElement] {
        try get(.windows)
    }

    public func mainWindow() throws -> MockElement {
        try get(.mainWindow)
    }

    public func focusedWindow() throws -> MockElement {
        try get(.focusedWindow)
    }

    public func focusedUIElement() throws -> MockElement {
        try get(.focusedUIElement)
    }

    public func parent() throws -> MockElement {
        try get(.parent)
    }

    public func children() throws -> [MockElement] {
        try get(.children)
    }

    public func childrenInNavigationOrder() throws -> [MockElement] {
        try get(.childrenInNavigationOrder)
    }

    public func visibleChildren() throws -> [MockElement] {
        try get(.visibleChildren)
    }

    public func selectedChildren() throws -> [MockElement] {
        try get(.selectedChildren)
    }

    public func rows() throws -> [MockElement] {
        try get(.rows)
    }

    public func columns() throws -> [MockElement] {
        try get(.columns)
    }

    public func selectedRows() throws -> [MockElement] {
        try get(.selectedRows)
    }

    public func selectedColumns() throws -> [MockElement] {
        try get(.selectedColumns)
    }

    public func selectedCells() throws -> [MockElement] {
        try get(.selectedCells)
    }

    public func enhancedUserInterface() throws -> Bool {
        try get(.enhancedUserInterface)
    }

    public func setEnhancedUserInterface(_ enhancedUserInterface: Bool) throws {
        set(enhancedUserInterface,
            for: .enhancedUserInterface)
    }
    
    public func actions() throws -> [NSAccessibility.Action] {
        []
    }

    public func description(action: NSAccessibility.Action) throws -> String {
        ""
    }

    public func perform(action: NSAccessibility.Action) throws {
    }

    public func line(forIndex index: Int) throws -> Int {
        guard let handler = lineForIndexHandler else {
            throw ElementError.noValue
        }
        return try handler(index)
    }

    public func line(forTextMarker textMarker: TextMarker) throws -> Int {
        throw ElementError.noValue
    }

    public func range(forLine line: Int) throws -> Range<Int> {
        guard let handler = rangeForLineHandler else {
            throw ElementError.noValue
        }
        return try handler(line)
    }

    public func range(forIndex index: Int) throws -> Range<Int> {
        throw ElementError.noValue
    }

    public func range(forPosition position: Int) throws -> Range<Int> {
        throw ElementError.noValue
    }

    public func string(for range: Range<Int>) throws -> String {
        guard let handler = stringForHandler else {
            throw ElementError.noValue
        }
        return try handler(range)
    }
    
    public func bounds(for range: Range<Int>) throws -> NSRect {
        guard let handler = boundsForHandler else { throw ElementError.noValue }
        return try handler(range)
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

    public func cell(
        column: Int,
        row: Int
    ) throws -> SystemElement {
        throw ElementError.noValue
    }

    public func insertionPointLineNumber() throws -> Int {
        try get(.insertionPointLineNumber)
    }

    public func sharedCharacterRange() throws -> Range<Int> {
        throw ElementError.noValue
    }

    public func sharedTextUIElements() throws -> [MockElement] {
        throw ElementError.noValue
    }

    public func visibleCharacterRange() throws -> Range<Int> {
        throw ElementError.noValue
    }

    public func numberOfCharacters() throws -> Int {
        try get(.numberOfCharacters)
    }

    public func selectedText() throws -> String {
        try get(.selectedText)
    }

    public func selectedTextRange() throws -> Range<Int> {
        try get(.selectedTextRange)
    }

    public func selectedTextRanges() throws -> [Range<Int>] {
        throw ElementError.noValue
    }

    public func frame() throws -> NSRect {
        try get(.frame)
    }

    public func setPosition(_ position: CGPoint) throws {
        guard let handler = setPositionHandler else { throw ElementError.noValue }
        try handler(position)
    }

    public func setVisibleCharacterRange(_ range: Range<Int>) throws {
        guard let handler = setVisibleCharacterRangeHandler else { throw ElementError.noValue }
        try handler(range)
    }

    public func set<V: Sendable>(_ value: V, for attribute: NSAccessibility.Attribute) {
        storage.withLock {
            $0[attribute] = value
        }
    }

    private func `get`<V>(_ attribute: NSAccessibility.Attribute) throws -> V {
        guard let value = storage.withLockUnchecked({ $0[attribute] }) else {
            throw ElementError.noValue
        }
        guard let checkedValue = value as? V else {
            throw AccessibilityError.typeMismatch
        }
        return checkedValue
    }

    private let _pid: pid_t
    private var storage: OSAllocatedUnfairLock<[NSAccessibility.Attribute:Any]>
    public init(
        pid: pid_t = 0,
        storage: [NSAccessibility.Attribute:Sendable]
    ) {
        _pid = pid
        self.storage = .init(uncheckedState: storage)
    }
}
