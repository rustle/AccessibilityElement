//
//  AXValue.swift
//
//  Copyright © 2017-2019 Doug Russell. All rights reserved.
//

import Cocoa

public extension AXValue {
    static var typeID: CFTypeID {
        return AXValueGetTypeID()
    }
    var type: AXValueType {
        return AXValueGetType(self)
    }
    private func get<T>(_ defaultValue: T) throws -> T {
        var value = defaultValue
        guard AXValueGetValue(self,
                              type,
                              &value) else {
            throw AccessibilityError.typeMismatch
        }
        return value
    }
    func rectValue() throws -> CGRect {
        try get(CGRect.null)
    }
    func sizeValue() throws -> CGSize {
        try get(CGSize.zero)
    }
    func pointValue() throws -> CGPoint {
        try get(CGPoint.zero)
    }
    func rangeValue() throws -> CFRange {
        try get(CFRange(location: kCFNotFound,
                        length: 0))
    }
    func value() throws -> Any {
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
        @unknown default:
            throw AccessibilityError.typeMismatch
        }
    }
    static func range(_ range: Range<Int>) -> AXValue {
        var cfRange = CFRangeMake(range.lowerBound,
                                  range.count)
        return AXValueCreate(.cfRange,
                             &cfRange)!
    }
}
