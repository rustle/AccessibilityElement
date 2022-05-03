//
//  AnyElement.swift
//
//  Copyright © 2017-2021 Doug Russell. All rights reserved.
//

import Cocoa

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
    private let _processIdentifier: () throws -> pid_t
    private let _windows: () throws -> [AnyElement]
    private let _mainWindow: () throws -> AnyElement
    private let _parent: () throws -> AnyElement
    private let _children: () throws -> [AnyElement]
    private let _childrenInNavigationOrder: () throws -> [AnyElement]
    private let _visibleChildren: () throws -> [AnyElement]
    private let _selectedChildren: () throws -> [AnyElement]

    public init<E: Element>(element: E) {
        if E.self == AnyElement.self {
            self = element as! AnyElement
        } else {
            _role = element.role
            _roleDescription = element.roleDescription
            _subrole = element.subrole
            _value = element.value
            _processIdentifier = { try element.processIdentifier }
            _windows = {
                try element
                    .windows()
                    .map(AnyElement.init)
            }
            _mainWindow = {
                AnyElement(element: try element.mainWindow())
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
}
