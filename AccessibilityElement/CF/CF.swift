//
//  CF.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import Foundation

fileprivate func _apply(collection: CFTypeRef,
                        getCount: () -> CFIndex,
                        getValues: (UnsafeMutablePointer<UnsafeRawPointer?>, Int) -> Void,
                        applier: (CFTypeRef) throws -> Void) rethrows {
    let count = Int(getCount())
    let values = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: count)
    getValues(values, count)
    for i in 0..<count {
        guard let pointer = values[i] else {
            continue
        }
        let value = Unmanaged<CFTypeRef>.fromOpaque(pointer).takeUnretainedValue()
        try applier(value)
    }
    values.deallocate(capacity: count)
}

public extension CFArray {
    public static var typeID: CFTypeID {
        return CFArrayGetTypeID()
    }
    public func apply(_ applier: (CFTypeRef) throws -> Void) rethrows {
        try _apply(collection: self, getCount: {
            return CFArrayGetCount(self)
        }, getValues: { values, count in
            CFArrayGetValues(self, CFRangeMake(0, count), values)
        }, applier: applier)
    }
}

public extension CFSet {
    public static var typeID: CFTypeID {
        return CFSetGetTypeID()
    }
    public func apply(_ applier: (CFTypeRef) throws -> Void) rethrows {
        try _apply(collection: self, getCount: {
            return CFSetGetCount(self)
        }, getValues: { values, count in
            CFSetGetValues(self, values)
        }, applier: applier)
    }
}
