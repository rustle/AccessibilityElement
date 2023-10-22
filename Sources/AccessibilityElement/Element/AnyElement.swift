//
//  AnyElement.swift
//
//  Copyright © 2017-2021 Doug Russell. All rights reserved.
//

import AppKit

public struct AnyElement: Element {
    public static func systemWide() throws -> AnyElement {
        fatalError()
    }

    public static func application(processIdentifier: pid_t) throws -> AnyElement {
        fatalError()
    }

    private let _role: () throws -> NSAccessibility.Role
    private let _roleDescription: () throws -> String
    private let _subrole: () throws -> NSAccessibility.Subrole
    private let _value: () throws -> Any
    private let _title: () throws -> String
    private let _titleUIElement: () throws -> AnyElement
    private let _processIdentifier: () throws -> pid_t
    private let _windows: () throws -> [AnyElement]
    private let _mainWindow: () throws -> AnyElement
    private let _focusedWindow: () throws -> AnyElement
    private let _focusedUIElement: () throws -> AnyElement
    private let _parent: () throws -> AnyElement
    private let _children: () throws -> [AnyElement]
    private let _childrenInNavigationOrder: () throws -> [AnyElement]
    private let _visibleChildren: () throws -> [AnyElement]
    private let _selectedChildren: () throws -> [AnyElement]
    private let _rows: () throws -> [AnyElement]
    private let _columns: () throws -> [AnyElement]
    private let _selectedRows: () throws -> [AnyElement]
    private let _selectedColumns: () throws -> [AnyElement]
    private let _selectedCells: () throws -> [AnyElement]

    public init<E: Element>(element: E) {
        if E.self == AnyElement.self {
            self = element as! AnyElement
        } else {
            _role = element.role
            _roleDescription = element.roleDescription
            _subrole = element.subrole
            _value = element.value
            _title = element.title
            _titleUIElement = {
                AnyElement(element: try element.titleUIElement())
            }
            _processIdentifier = { try element.processIdentifier }
            _windows = {
                try element
                    .windows()
                    .map(AnyElement.init)
            }
            _mainWindow = {
                AnyElement(element: try element.mainWindow())
            }
            _focusedWindow = {
                AnyElement(element: try element.focusedWindow())
            }
            _focusedUIElement = {
                AnyElement(element: try element.focusedUIElement())
            }
            _parent = {
                AnyElement(element: try element.parent())
            }
            _children = {
                try element
                    .children()
                    .map(AnyElement.init)
            }
            _childrenInNavigationOrder = {
                try element
                    .childrenInNavigationOrder()
                    .map(AnyElement.init)
            }
            _visibleChildren = {
                try element
                    .visibleChildren()
                    .map(AnyElement.init)
            }
            _selectedChildren = {
                try element
                    .selectedChildren()
                    .map(AnyElement.init)
            }
            _rows = {
                try element
                    .rows()
                    .map(AnyElement.init)
            }
            _columns = {
                try element
                    .columns()
                    .map(AnyElement.init)
            }
            _selectedRows = {
                try element
                    .selectedRows()
                    .map(AnyElement.init)
            }
            _selectedColumns = {
                try element
                    .selectedColumns()
                    .map(AnyElement.init)
            }
            _selectedCells = {
                try element
                    .selectedCells()
                    .map(AnyElement.init)
            }
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
}
