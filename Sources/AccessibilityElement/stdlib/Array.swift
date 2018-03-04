//
//  Array.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

public extension Array {
    func index<T>(equatable: T) -> Index? where T : Equatable {
        return self.index(where: {
            if let value = $0 as? T {
                return equatable == value
            }
            return false
        })
    }
}

public extension Array where Element : AnyObject {
    func index(identity: Element) -> Index? {
        return self.index(where: {
            return $0 === identity
        })
    }
}
