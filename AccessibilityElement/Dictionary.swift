//
//  Dictionary.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

extension Dictionary {
    func map<T, U>(_ transform: ((key: Key, value: Value)) throws -> (T, U)) rethrows -> [T:U] {
        var mapped = [T:U]()
        for keyValue in self {
            let (mappedKey, mappedValue) = try transform(keyValue)
            mapped[mappedKey] = mappedValue
        }
        return mapped
    }
}
