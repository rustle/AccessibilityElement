//
//  NSAccessibility.Subrole.swift
//
//  Copyright © 2018-2021 Doug Russell. All rights reserved.
//

import AppKit

public extension NSAccessibility.Subrole {}

extension NSAccessibility.Subrole: Codable {}

extension NSAccessibility.Subrole: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}
