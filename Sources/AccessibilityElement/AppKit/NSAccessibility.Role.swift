//
//  NSAccessibility.Role.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Cocoa

public extension NSAccessibility.Role {
    /// Role value representing container for web content.
    static let webArea = NSAccessibility.Role(rawValue: "AXWebArea")
}

extension NSAccessibility.Role: Codable {}
