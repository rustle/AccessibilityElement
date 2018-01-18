//
//  Dictionary.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

extension Dictionary {
    func reduce<T, U>(_ updateAccumulatingResult: (inout [T:U], (key: Key, value: Value)) throws -> ()) rethrows -> [T:U] {
        return try reduce(into: [T:U](), updateAccumulatingResult)
    }
}
