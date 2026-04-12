//
//  SystemObserverUserInfoRepackager.swift
//  
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AX
import Cocoa

struct SystemObserverUserInfoRepackager {
    private static func _repackage(array: [Any]) -> [ObserverElementInfoValue] {
        return array.compactMap { try? _repackage(value: $0) }
    }

    private static func _repackage(dictionary: [String: Any]) -> [String: ObserverElementInfoValue] {
        return dictionary.reduce(into: [:]) { result, pair in
            if let converted = try? _repackage(value: pair.value) {
                result[pair.key] = converted
            }
        }
    }

    private static func _repackage(value: Any) throws -> ObserverElementInfoValue {
        let typeID = CFGetTypeID(value as CFTypeRef)

        switch typeID {
        case AXUIElementGetTypeID():
            return .element(SystemElement(element: UIElement(element: value as! AXUIElement)))
        case AXValueGetTypeID():
            return .axValue(try AX.Value(value: (value as! AXValue)))
        case CFNumberGetTypeID():
            return .int((value as! NSNumber).intValue)
        case CFBooleanGetTypeID():
            return .bool((value as! NSNumber).boolValue)
        case AXTextMarkerGetTypeID():
            return .textMarker(TextMarker(textMarker: value as! AXTextMarker))
        case AXTextMarkerRangeGetTypeID():
            return .textMarkerRange(TextMarkerRange(textMarkerRange: (value as! AXTextMarkerRange)))
        default:
            break
        }

        switch value {
        case let array as [Any]:
            return .array(_repackage(array: array))
        case let dictionary as [String: Any]:
            return .dictionary(_repackage(dictionary: dictionary))
        case let string as String:
            return .string(string)
        case let attrString as NSAttributedString:
            return .attributedString(
                ObserverElementInfoAttributedString(attributedString: attrString) { val in
                    try? _repackage(value: val)
                }
            )
        default:
            throw AccessibilityError.typeMismatch
        }
    }

    static func repackage(dictionary: CFDictionary?) -> [String: ObserverElementInfoValue] {
        guard let dictionary = dictionary as? [String:Any] else {
            return [:]
        }
        return _repackage(dictionary: dictionary)
    }
}
