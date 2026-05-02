//
//  NSAttributedString.Key.swift
//
//  Copyright © 2018-2026 Doug Russell. All rights reserved.
//

import AppKit

public extension NSAttributedString.Key {}

extension NSAttributedString.Key: @retroactive Codable {}

extension NSAttributedString.Key: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}
