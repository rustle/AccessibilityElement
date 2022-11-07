//
//  MockElement.swift
//
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

import AccessibilityElement
import Cocoa

public struct MockElement: Element {
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

    private func `get`<V>(_ attribute: NSAccessibility.Attribute) throws -> V {
        guard let value = storage[attribute] else {
            throw ElementError.noValue
        }
        guard let checkedValue = value as? V else {
            throw AccessibilityError.typeMismatch
        }
        return checkedValue
    }

    private let _pid: pid_t
    private var storage: [NSAccessibility.Attribute:Any] = [:]
    public init(pid: pid_t = 0, storage: [NSAccessibility.Attribute:Any]) {
        _pid = pid
        self.storage = storage
    }
}