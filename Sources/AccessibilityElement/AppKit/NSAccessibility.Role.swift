//
//  NSAccessibility.Role.swift
//
//  Copyright © 2018-2021 Doug Russell. All rights reserved.
//

import Cocoa

public extension NSAccessibility.Role {}

extension NSAccessibility.Role: Codable {}

extension NSAccessibility.Role: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}
