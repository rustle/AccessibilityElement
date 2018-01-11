//
//  CFNumber.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public extension CFBoolean {
    public static var typeID: CFTypeID {
        return CFBooleanGetTypeID()
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
    public func int8Value() throws -> Int8 {
        return try get(Int8(0))
    }
    public func int16Value() throws -> Int16 {
        return try get(Int16(0))
    }
    public func int32Value() throws -> Int32 {
        return try get(Int32(0))
    }
    public func int64Value() throws -> Int64 {
        return try get(Int64(0))
    }
    public func intValue() throws -> Int {
        return try get(0)
    }
    public func longValue() throws -> CLong {
        return try get(0)
    }
    public func longLongValue() throws -> CLongLong {
        return try get(0)
    }
    public func cfIndexValue() throws -> CFIndex {
        return try get(CFIndex(0))
    }
    public func float32Value() throws -> Float32 {
        return try get(Float32(0.0))
    }
    public func float64Value() throws -> Float64 {
        return try get(Float64(0.0))
    }
    public func charValue() throws -> CChar {
        return try get(0)
    }
    public func shortValue() throws -> CShort {
        return try get(0)
    }
    public func floatValue() throws -> Float {
        return try get(0.0)
    }
    public func doubleValue() throws -> Float {
        return try get(0.0)
    }
    public func cgFloatValue() throws -> CGFloat {
        return try get(0.0)
    }
    public func value() throws -> Any {
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
