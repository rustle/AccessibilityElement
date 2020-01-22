//
//  CodableRangeContainer.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct CodableRangeContainer<Bound>: Codable where Bound: Codable, Bound: Comparable {
    public enum RangeCodingKeys : String, CodingKey {
        case lowerBound
        case upperBound
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RangeCodingKeys.self)
        try container.encode(range.lowerBound,
                             forKey: .lowerBound)
        try container.encode(range.upperBound,
                             forKey: .upperBound)
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: RangeCodingKeys.self)
        let lowerBound = try values.decode(Bound.self,
                                           forKey: .lowerBound)
        let upperBound = try values.decode(Bound.self,
                                           forKey: .upperBound)
        range = lowerBound..<upperBound
    }
    public let range: Range<Bound>
    public init(range: Range<Bound>) {
        self.range = range
    }
}
