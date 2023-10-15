//
//  NSAccessibility.Role.swift
//
//  Copyright © 2018-2021 Doug Russell. All rights reserved.
//

import AppKit

public extension NSAccessibility.Role {
    /// Role value representing container for web content.
    static let webArea: NSAccessibility.Role = "AXWebArea"
}

extension NSAccessibility.Role: Codable {}

extension NSAccessibility.Role: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}
