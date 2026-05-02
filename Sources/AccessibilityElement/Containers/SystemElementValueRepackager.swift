//
//  SystemElementValueRepackager.swift
//  
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AX
import Cocoa

struct SystemElementValueRepackager {
    private static func _repackage(array: [Any]) -> [SystemElementValueContainer] {
        return array.compactMap { try? repackage(value: $0) }
    }

    private static func _repackage(dictionary: [String: Any]) -> [String: SystemElementValueContainer] {
        return dictionary.reduce(into: [:]) { result, pair in
            if let converted = try? repackage(value: pair.value) {
                result[pair.key] = converted
            }
        }
    }

    private static func _repackageByTypeID(value: Any) throws -> SystemElementValueContainer? {
        let typeID = CFGetTypeID(value as CFTypeRef)
        switch typeID {
        case AXUIElementGetTypeID():
            return .element(SystemElement(element: UIElement(element: value as! AXUIElement)))
        case AXValueGetTypeID():
            switch try AX.Value(value: (value as! AXValue)) {
            case let .point(value):
                return .point(value)
            case let .size(value):
                return .size(value)
            case let .rect(value):
                return .rect(value)
            case let .range(value):
                return .range(value)
            case let .error(value):
                return .error(value)
            }
        case CFNumberGetTypeID():
            let number = value as! CFNumber
            let container: SystemElementValueContainer =
            CFNumberIsFloatType(number) ?
                .double((number as NSNumber).doubleValue) :
                .int((number as NSNumber).intValue)
            return container
        case CFBooleanGetTypeID():
            return .bool((value as! NSNumber).boolValue)
        case AXTextMarkerGetTypeID():
            return .textMarker(TextMarker(textMarker: value as! AXTextMarker))
        case AXTextMarkerRangeGetTypeID():
            return .textMarkerRange(TextMarkerRange(textMarkerRange: (value as! AXTextMarkerRange)))
        default:
            return nil
        }
    }

    static func repackage(value: Any) throws -> SystemElementValueContainer {
        switch value {
        case let container as SystemElementValueContainer:
            return container
        case let array as [Any]:
            return .array(_repackage(array: array))
        case let dictionary as [String: Any]:
            return .dictionary(_repackage(dictionary: dictionary))
        case let string as String:
            return .string(string)
        case let attrString as NSAttributedString:
            return .attributedString(.init(attributedString: attrString))
        default:
            if let container = try _repackageByTypeID(value: value) {
                return container
            }
            throw AccessibilityError.typeMismatch
        }
    }

    static func repackage(dictionary: CFDictionary?) -> [String: SystemElementValueContainer] {
        guard let dictionary = dictionary as? [String:Any] else {
            return [:]
        }
        return _repackage(dictionary: dictionary)
    }
}
