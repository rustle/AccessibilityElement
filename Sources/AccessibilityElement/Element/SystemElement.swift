//
//  SystemElement.swift
//
//  Copyright © 2017-2021 Doug Russell. All rights reserved.
//

import AX
import Cocoa

public struct SystemElement: Element {
    public static func systemWide() throws -> SystemElement {
        .init(element: UIElement.systemWide())
    }

    public static func application(processIdentifier: pid_t) throws -> SystemElement {
        .init(element: UIElement.application(pid: processIdentifier))
    }

    public func role() throws -> NSAccessibility.Role {
        try element.value(attribute: .role)
    }

    public func roleDescription() throws -> String {
        let description: String = try element.value(attribute: .roleDescription)
        return description
    }

    public func subrole() throws -> NSAccessibility.Subrole {
        NSAccessibility.Subrole(rawValue: try element.value(attribute: .subrole))
    }

    public func value() throws -> Any {
        try element.value(attribute: .value)
    }

    public func windows() throws -> [SystemElement] {
        (try element.value(attribute: .windows) as [UIElement])
            .map(SystemElement.init(element:))
    }

    public func mainWindow() throws -> SystemElement {
        .init(element: try element.value(attribute: .mainWindow) as UIElement)
    }

    public func focusedWindow() throws -> SystemElement {
        .init(element: try element.value(attribute: .focusedWindow) as UIElement)
    }

    public func focusedUIElement() throws -> SystemElement {
        .init(element: try element.value(attribute: .focusedUIElement) as UIElement)
    }

    public func parent() throws -> SystemElement {
        .init(element: try element.value(attribute: .parent) as UIElement)
    }

    public func children() throws -> [SystemElement] {
        (try element.value(attribute: .children) as [UIElement])
            .map(SystemElement.init(element:))
    }

    public func childrenInNavigationOrder() throws -> [SystemElement] {
        (try element.value(attribute: .childrenInNavigationOrder) as [UIElement])
            .map(SystemElement.init(element:))
    }

    public func visibleChildren() throws -> [SystemElement] {
        (try element.value(attribute: .visibleChildren) as [UIElement])
            .map(SystemElement.init(element:))
    }

    public func selectedChildren() throws -> [SystemElement] {
        (try element.value(attribute: .selectedChildren) as [UIElement])
            .map(SystemElement.init(element:))
    }

    public func rows() throws -> [SystemElement] {
        (try element.value(attribute: .rows) as [UIElement])
            .map(SystemElement.init(element:))
    }

    public func columns() throws -> [SystemElement] {
        (try element.value(attribute: .columns) as [UIElement])
            .map(SystemElement.init(element:))
    }

    public func selectedRows() throws -> [SystemElement] {
        (try element.value(attribute: .selectedRows) as [UIElement])
            .map(SystemElement.init(element:))
    }

    public func selectedColumns() throws -> [SystemElement] {
        (try element.value(attribute: .selectedColumns) as [UIElement])
            .map(SystemElement.init(element:))
    }

    public func selectedCells() throws -> [SystemElement] {
        (try element.value(attribute: .selectedCells) as [UIElement])
            .map(SystemElement.init(element:))
    }

    public var processIdentifier: pid_t {
        get throws {
            try element.pid
        }
    }

    let element: UIElement
    init(element: UIElement) {
        self.element = element
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

extension SystemElement: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        element.description
    }

    public var debugDescription: String {
        element.debugDescription
    }

    public var debugInfo: [String:Any] {
        element.debugInfo
    }
}
