//
//  Element.swift
//
//  Copyright © 2017-2021 Doug Russell. All rights reserved.
//

import Cocoa

public protocol AnyElement {
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
}

public protocol Element: AnyElement {
    ///
    static func systemWide() throws -> Self
    ///
    static func application(processIdentifier: pid_t) throws -> Self
    ///
    func windows() throws -> [Self]
    ///
    func mainWindow() throws -> Self
}
