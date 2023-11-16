//
//  SystemObserverUserInfoRepackager.swift
//  
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

import AX
import Cocoa

struct SystemObserverUserInfoRepackager {
    private static func _repackage(element: UIElement) -> SystemElement {
        SystemElement(element: element)
    }
    private static func _repackage(array: [Sendable]) -> [Sendable] {
        do {
            return try array.map { value in
                return try _repackage(value: value)
            }
        } catch {
            return []
        }
    }
    private static func _repackage(dictionary: [String:Sendable]) -> [String:Sendable] {
        do {
            return try dictionary.reduce(into: [:]) { result, pair in
                result[pair.key] = try _repackage(value: pair.value)
            }
        } catch {
            return [:]
        }
    }
    private static func _repackage(value: Sendable) throws -> Sendable {
        let typeID = CFGetTypeID(value as CFTypeRef)
        switch typeID {
        case AXUIElementGetTypeID():
            return SystemElement(element: UIElement(element: value as! AXUIElement))
        case AXValueGetTypeID():
            return try AX.Value(value: (value as! AXValue))
        case CFNumberGetTypeID():
            return (value as! NSNumber).intValue
        case CFBooleanGetTypeID():
            return (value as! NSNumber).boolValue
        case AXTextMarkerGetTypeID():
            return TextMarker(textMarker: value as! AXTextMarker)
        case AXTextMarkerRangeGetTypeID():
            return TextMarkerRange(textMarkerRange: (value as! AXTextMarkerRange))
        default:
            break
        }
        switch value {
        case let array as [String]:
            return _repackage(array: array)
        case let dictionary as [String:Sendable]:
            return _repackage(dictionary: dictionary)
        case let string as String:
            return string
        case let attributeString as AttributedString:
            return attributeString
        default:
            throw AccessibilityError.typeMismatch
        }
    }
    static func repackage(dictionary: CFDictionary?) -> [String:Sendable] {
        guard let dictionary = dictionary as? [String:Sendable] else {
            return [:]
        }
        return _repackage(dictionary: dictionary)
    }
}
