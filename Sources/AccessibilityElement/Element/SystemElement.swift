//
//  SystemElement.swift
//
//  Copyright © 2017-2021 Doug Russell. All rights reserved.
//

import AppKit
import AX

public struct SystemElement: Element {
    public static func systemWide() throws -> SystemElement {
        .init(element: UIElement.systemWide())
    }

    public static func application(processIdentifier: pid_t) throws -> SystemElement {
        .init(element: UIElement.application(pid: processIdentifier))
    }

    public func role() throws -> NSAccessibility.Role {
        try throwsAXError {
            try element.value(attribute: .role)
        }
    }

    public func roleDescription() throws -> String {
        try throwsAXError {
            try element.value(attribute: .roleDescription)
        }
    }

    public func subrole() throws -> NSAccessibility.Subrole {
        NSAccessibility.Subrole(rawValue:
            try throwsAXError({
                try element.value(attribute: .subrole)
            })
        )
    }

    public func value() throws -> Any {
        try throwsAXError {
            try element.value(attribute: .value)
        }
    }
    
    public func title() throws -> String {
        try throwsAXError {
            try element.value(attribute: .title)
        }
    }

    public func titleUIElement() throws -> SystemElement {
        try throwsAXError {
            try element.value(attribute: .titleUIElement)
        }
    }

    public func windows() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .windows) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }

    public func mainWindow() throws -> SystemElement {
        .init(element:
            try throwsAXError({
                try element.value(attribute: .mainWindow)
            })
        )
    }

    public func focusedWindow() throws -> SystemElement {
        .init(element:
            try throwsAXError({
                try element.value(attribute: .focusedWindow)
            })
        )
    }

    public func focusedUIElement() throws -> SystemElement {
        .init(element:
            try throwsAXError({
                try element.value(attribute: .focusedUIElement)
            })
        )
    }

    public func parent() throws -> SystemElement {
        .init(element:
            try throwsAXError({
                try element.value(attribute: .parent)
            })
        )
    }

    public func children() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .children) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }

    public func childrenInNavigationOrder() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .childrenInNavigationOrder) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }

    public func visibleChildren() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .visibleChildren) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }

    public func selectedChildren() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .selectedChildren) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }

    public func rows() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .rows) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }

    public func columns() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .columns) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }

    public func selectedRows() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .selectedRows) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }

    public func selectedColumns() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .selectedColumns) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }

    public func selectedCells() throws -> [SystemElement] {
        try throwsAXError {
            (try element.value(attribute: .selectedCells) as [UIElement])
                .map(SystemElement.init(element:))
        }
    }

    public var processIdentifier: pid_t {
        get throws {
            try element.pid
        }
    }

    public func enhancedUserInterface() throws -> Bool {
        try throwsAXError {
            (try element.value(attribute: .enhancedUserInterface) as Bool)
        }
    }

    public func setEnhancedUserInterface(_ enhancedUserInterface: Bool) throws {
        try throwsAXError {
            try element.set(attribute: .enhancedUserInterface,
                            value: enhancedUserInterface as CFBoolean)
        }
    }

    public func actions() throws -> [NSAccessibility.Action] {
        try throwsAXError {
            try element.actions()
        }
    }

    public func description(action: NSAccessibility.Action) throws -> String {
        try throwsAXError {
            try element.description(action: action)
        }
    }

    public func perform(action: NSAccessibility.Action) throws {
        try throwsAXError {
            try element.perform(action: action)
        }
    }

    public func line(for index: Int) throws -> Int {
        try throwsAXError {
            try element.value(
                attribute: .lineForIndex,
                parameter: index as NSNumber
            )
        }
    }

    public func range(forLine line: Int) throws -> Range<Int> {
        try throwsAXError {
            let value = try Value(value: element.value(
                attribute: .rangeForLine,
                parameter: line as NSNumber
            ))
            guard case let .range(range) = value else {
                throw ElementError.noValue
            }
            return range
        }
    }

    public func range(forPosition position: Int) throws -> Range<Int> {
        try throwsAXError {
            let value = try Value(value: element.value(
                attribute: .rangeForPosition,
                parameter: position as NSNumber
            ))
            guard case let .range(range) = value else {
                throw ElementError.noValue
            }
            return range
        }
    }

    public func string(for range: Range<Int>) throws -> String {
        try throwsAXError {
            try element.value(
                attribute: .stringForRange,
                parameter: Value.range(range).value
            )
        }
    }

    let element: UIElement
    init(element: UIElement) {
        self.element = element
    }

    private func throwsAXError<T>(_ work: () throws -> T) rethrows -> T {
        do {
            return try work()
        } catch let error as AX.AXError {
            throw ElementError(error: error)
        } catch {
            throw error
        }
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
