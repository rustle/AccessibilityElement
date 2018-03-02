//
//  AXValue.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import Cocoa

public extension AXValue {
    public static var typeID: CFTypeID {
        return AXValueGetTypeID()
    }
    public var type: AXValueType {
        return AXValueGetType(self)
    }
    private func get<T>(_ defaultValue: T) throws -> T {
        var value = defaultValue
        guard AXValueGetValue(self, type, &value) else {
            throw AccessibilityError.typeMismatch
        }
        return value
    }
    public func rectValue() throws -> CGRect {
        return try get(CGRect.null)
    }
    public func sizeValue() throws -> CGSize {
        return try get(CGSize.zero)
    }
    public func pointValue() throws -> CGPoint {
        return try get(CGPoint.zero)
    }
    public func rangeValue() throws -> CFRange {
        return try get(CFRange.init(location: kCFNotFound, length: 0))
    }
    public func value() throws -> Any {
        switch type {
        case .cgPoint:
            return try pointValue()
        case .cgSize:
            return try sizeValue()
        case .cgRect:
            return try rectValue()
        case .cfRange:
            return try rangeValue()
        case .axError:
            throw AccessibilityError.typeMismatch
        case .illegal:
            throw AccessibilityError.typeMismatch
        }
    }
    public static func range(_ range: Range<Int>) -> AXValue {
        var cfRange = CFRangeMake(range.lowerBound, range.count)
        return AXValueCreate(.cfRange, &cfRange)!
    }
}
