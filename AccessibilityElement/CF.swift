//
//  CF.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import Foundation

public extension CFString {
    public static var typeID: CFTypeID {
        return CFStringGetTypeID()
    }
}

public extension CFNumber {
    public static var typeID: CFTypeID {
        return CFNumberGetTypeID()
    }
    public var type: CFNumberType {
        return CFNumberGetType(self)
    }
    private func get<T>(_ defaultValue: T) throws -> T {
        var value = defaultValue
        guard CFNumberGetValue(self, type, &value) else {
            throw AccessibilityError.typeMismatch
        }
        return value
    }
    func int8Value() throws -> Int8 {
        return try get(Int8(0))
    }
    func int16Value() throws -> Int16 {
        return try get(Int16(0))
    }
    func int32Value() throws -> Int32 {
        return try get(Int32(0))
    }
    func int64Value() throws -> Int64 {
        return try get(Int64(0))
    }
    func intValue() throws -> Int {
        return try get(0)
    }
    func longValue() throws -> CLong {
        return try get(0)
    }
    func longLongValue() throws -> CLongLong {
        return try get(0)
    }
    func cfIndexValue() throws -> CFIndex {
        return try get(CFIndex(0))
    }
    func float32Value() throws -> Float32 {
        return try get(Float32(0.0))
    }
    func float64Value() throws -> Float64 {
        return try get(Float64(0.0))
    }
    func charValue() throws -> CChar {
        return try get(0)
    }
    func shortValue() throws -> CShort {
        return try get(0)
    }
    func floatValue() throws -> Float {
        return try get(0.0)
    }
    func doubleValue() throws -> Float {
        return try get(0.0)
    }
    func cgFloatValue() throws -> CGFloat {
        return try get(0.0)
    }
    func value() throws -> Any {
        switch type {
        case .sInt8Type:
            return try int8Value()
        case .sInt16Type:
            return try int16Value()
        case .sInt32Type:
            return try int32Value()
        case .sInt64Type:
            return try int64Value()
        case .intType:
            return try intValue()
        case .longType:
            return try longValue()
        case .longLongType:
            return try longLongValue()
        case .cfIndexType:
            return try cfIndexValue()
        case .nsIntegerType:
            return try intValue()
        case .float32Type:
            return try float32Value()
        case .float64Type:
            return try float64Value()
        case .charType:
            return try charValue()
        case .shortType:
            return try shortValue()
        case .floatType:
            return try floatValue()
        case .doubleType:
            return try doubleValue()
        case .cgFloatType:
            return try cgFloatValue()
        }
    }
}

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

public extension CFRunLoop {
    public static var typeID: CFTypeID {
        return CFRunLoopGetTypeID()
    }
    public static var main: CFRunLoop {
        return CFRunLoopGetMain()
    }
    public static var current: CFRunLoop {
        return CFRunLoopGetCurrent()
    }
    public static func run() {
        CFRunLoopRun()
    }
    public func add(source: CFRunLoopSource, mode: CFRunLoopMode) {
        CFRunLoopAddSource(self, source, mode)
    }
    public func remove(source: CFRunLoopSource, mode: CFRunLoopMode) {
        CFRunLoopRemoveSource(self, source, mode)
    }
    public func perform(mode: CFRunLoopMode = .defaultMode, block: @escaping () -> Void) {
        CFRunLoopPerformBlock(self, mode.rawValue, block)
    }
}
