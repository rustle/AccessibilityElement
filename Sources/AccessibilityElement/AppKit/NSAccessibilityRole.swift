//
//  NSAccessibilityRole.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa

public extension NSAccessibilityRole {
    /// Role value representing container for web content.
    public static let webArea = NSAccessibilityRole(rawValue: "AXWebArea")
}

extension NSAccessibilityRole : Codable {
    public enum NSAccessibilityRoleCodingKeys : String, CodingKey {
        case rawValue
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NSAccessibilityRoleCodingKeys.self)
        try container.encode(rawValue, forKey: .rawValue)
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: NSAccessibilityRoleCodingKeys.self)
        self.init(rawValue: try values.decode(String.self, forKey: .rawValue))
    }
}
