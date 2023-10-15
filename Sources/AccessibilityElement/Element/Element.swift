//
//  Element.swift
//
//  Copyright © 2017-2021 Doug Russell. All rights reserved.
//

import AppKit

public protocol Element: CustomStringConvertible, CustomDebugStringConvertible {
    /// String that defines the element’s role in the app.(not localized)
    func role() throws -> NSAccessibility.Role
    /// Localized string that describes the element’s role in the app
    func roleDescription() throws -> String
    ///
    func subrole() throws -> NSAccessibility.Subrole
    ///
    func value() throws -> Any
    ///
    var processIdentifier: pid_t { get throws }
    ///
    func windows() throws -> [Self]
    ///
    func mainWindow() throws -> Self
    ///
    func focusedWindow() throws -> Self
    ///
    func focusedUIElement() throws -> Self
    ///
    func parent() throws -> Self
    ///
    func children() throws -> [Self]
    ///
    func childrenInNavigationOrder() throws -> [Self]
    ///
    func visibleChildren() throws -> [Self]
    ///
    func selectedChildren() throws -> [Self]
    ///
    func rows() throws -> [Self]
    ///
    func columns() throws -> [Self]
    ///
    func selectedRows() throws -> [Self]
    ///
    func selectedColumns() throws -> [Self]
    ///
    func selectedCells() throws -> [Self]
}

extension Element {
    public var description: String {
        var description = [String]()
        description.reserveCapacity(3)
        description.append(String(describing: self)) // 1
        func append(_ prefix: String,
                    _ attribute: () throws -> Any) {
            guard let value = try? attribute() else {
                return
            }
            description.append(prefix)
            description.append(String(describing: value))
        }
        append("Role:", self.role) // 2
        append("Subrole:", self.subrole) // 3
        return "<Element \(description.joined(separator: " "))>"
    }

    public var debugDescription: String {
        var description = [String]()
        description.reserveCapacity(4)
        description.append(String(describing: self)) // 1
        func append(_ prefix: String,
                    _ attribute: () throws -> Any) {
            guard let value = try? attribute() else {
                return
            }
            description.append(prefix)
            description.append(String(describing: value))
        }
        append("Role:", self.role) // 2
        append("Subrole:", self.subrole) // 3
        append("Value:", self.value) // 4
        return "<Element \(description.joined(separator: " "))>"
    }
}
