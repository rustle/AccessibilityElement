//
//  JSONEncoder.swift
//
//  Copyright © 2019 Doug Russell. All rights reserved.
//

import Foundation

public extension JSONEncoder {
    func compressEncode<T>(_ value: T) throws -> Data where T : Encodable {
        try (encode(value) as NSData).compressed(using: .lzfse) as Data
    }
}

public extension JSONDecoder {
    func decompressDecode<T>(_ type: T.Type,
                                    from data: Data) throws -> T where T : Decodable {
        try decode(type,
                   from: (data as NSData).decompressed(using: .lzfse) as Data)
    }
}
