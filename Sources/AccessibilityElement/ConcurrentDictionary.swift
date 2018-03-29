//
//  ConcurrentDictionary.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct ConcurrentDictionary<KeyType, ElementType> where KeyType : Hashable {
    private var values: [KeyType : ElementType]
    private let queue: DispatchQueue
    public init(label: String = "ConcurrentDictionary.sync") {
        values = Dictionary()
        queue = DispatchQueue(label: label)
    }
    public init(label: String = "ConcurrentDictionary.sync",
                dictionary: [KeyType : ElementType]) {
        values = dictionary
        queue = DispatchQueue(label: label)
    }
    public mutating func set(value: ElementType,
                             key: KeyType) {
        queue.sync(flags: [.barrier]) {
            self.values[key] = value
        }
    }
    public mutating func remove(key: KeyType) {
        queue.sync(flags: [.barrier]) { () -> Void in
            self.values.removeValue(forKey: key)
        }
    }
    public func value(key: KeyType) -> ElementType? {
        return queue.sync {
            return self.values[key]
        }
    }
    public subscript(key: KeyType) -> ElementType? {
        get {
            return value(key: key)
        }
        set {
            if let value = newValue {
                set(value: value, key: key)
            } else {
                remove(key: key)
            }
        }
    }
}
