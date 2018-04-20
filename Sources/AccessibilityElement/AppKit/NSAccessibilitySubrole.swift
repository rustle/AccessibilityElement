//
//  NSAccessibilitySubrole.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa

extension NSAccessibilitySubrole : Codable {
    public enum NSAccessibilitySubroleCodingKeys : String, CodingKey {
        case rawValue
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NSAccessibilitySubroleCodingKeys.self)
        try container.encode(rawValue, forKey: .rawValue)
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: NSAccessibilitySubroleCodingKeys.self)
        self.init(rawValue: try values.decode(String.self, forKey: .rawValue))
    }
}
