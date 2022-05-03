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
        let windows: [UIElement] = try element.value(attribute: .windows)
        return windows.map(SystemElement.init(element:))
    }

    public func mainWindow() throws -> Self {
        try element.value(attribute: .mainWindow)
    }

    public func parent() throws -> Self {
        try element.value(attribute: .parent)
    }

    public func children() throws -> [Self] {
        try element.value(attribute: .children)
    }

    public func childrenInNavigationOrder() throws -> [Self] {
        try element.value(attribute: "AXChildrenInNavigationOrder")
    }

    public func visibleChildren() throws -> [Self] {
        try element.value(attribute: .visibleChildren)
    }

    public func selectedChildren() throws -> [Self] {
        try element.value(attribute: .selectedChildren)
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
