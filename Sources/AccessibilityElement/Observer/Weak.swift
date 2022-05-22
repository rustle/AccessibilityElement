//
//  Weak.swift
//
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

import Foundation
import ObjectiveC

public extension UnsafeMutablePointer where Pointee == AnyObject? {
    func unsafe_loadWeak<T: AnyObject>(_ type: T.Type) -> T? {
        objc_loadWeak(AutoreleasingUnsafeMutablePointer(self)) as? T
    }
    func unsafe_storeWeak<T: AnyObject>(object: T?) {
        objc_storeWeak(
            AutoreleasingUnsafeMutablePointer(self),
            object
        )
    }
}

public extension UnsafeMutableRawPointer {
    func unsafe_loadWeak<T: AnyObject>(_ type: T.Type) -> T? {
        assumingMemoryBound(to: AnyObject?.self)
            .unsafe_loadWeak(type)
    }
    func unsafe_storeWeak<T: AnyObject>(object: T?) {
        assumingMemoryBound(to: AnyObject?.self)
            .unsafe_storeWeak(object: object)
    }
}
