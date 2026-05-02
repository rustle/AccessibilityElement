//
//  NSAccessibility.Action.swift
//
//  Copyright © 2018-2026 Doug Russell. All rights reserved.
//

import AppKit

public extension NSAccessibility.Action {}

extension NSAccessibility.Action: @retroactive Codable {}

extension NSAccessibility.Action: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}
