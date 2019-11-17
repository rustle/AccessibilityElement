//
//  NSAccessibility.Subrole.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Cocoa

extension NSAccessibility.Subrole: Codable {
    public enum CodingKeys: String, CodingKey {
        case rawValue
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rawValue, forKey: .rawValue)
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(rawValue: try values.decode(String.self, forKey: .rawValue))
    }
}
