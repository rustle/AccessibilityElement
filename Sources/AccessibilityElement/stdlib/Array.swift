//
//  Array.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

public extension Array {
    func index<T>(equatable: T) -> Index? where T : Equatable {
        firstIndex {
            if let value = $0 as? T {
                return equatable == value
            }
            return false
        }
    }
}

public extension Array where Element : AnyObject {
    func index(identity: Element) -> Index? {
        firstIndex {
            $0 === identity
        }
    }
}
