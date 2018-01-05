//
//  CFDictionary.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public extension CFDictionary {
    public static var typeID: CFTypeID {
        return CFDictionaryGetTypeID()
    }
    public func apply(_ applier: (CFTypeRef, CFTypeRef) -> Void) {
        let count = Int(CFDictionaryGetCount(self))
        let keys = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: count)
        let values = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: count)
        CFDictionaryGetKeysAndValues(self, keys, values)
        for i in 0..<count {
            guard let key = keys[i] else {
                break
            }
            guard let value = values[i] else {
                break
            }
            applier(Unmanaged<CFTypeRef>.fromOpaque(key).takeUnretainedValue(), Unmanaged<CFTypeRef>.fromOpaque(value).takeUnretainedValue())
        }
        keys.deallocate(capacity: count)
        values.deallocate(capacity: count)
    }
}
