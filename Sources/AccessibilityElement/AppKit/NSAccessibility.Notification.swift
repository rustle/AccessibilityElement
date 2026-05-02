//
//  NSAccessibility.Notification.swift
//
//  Copyright © 2026 Doug Russell. All rights reserved.
//

import AppKit

public extension NSAccessibility.Notification {}

extension NSAccessibility.Notification: @retroactive Codable {}

extension NSAccessibility.Notification: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}
