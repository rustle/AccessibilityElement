//
//  NSAccessibility.Attribute.swift
//
//  Copyright © 2018-2021 Doug Russell. All rights reserved.
//

import Cocoa

public extension NSAccessibility.Attribute {}

extension NSAccessibility.Attribute: Codable {}

extension NSAccessibility.Attribute: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}
