//
//  SystemObserverProviding.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa

public struct SystemObserverProviding : ObserverProviding {
    public static func provider() -> ((Int) throws -> SystemObserverProviding) {
        return {
            SystemObserverProviding(processIdentifier: $0)
        }
    }
    public typealias ElementType = Element
    private var processIdentifier: Int
    private var _observer: AXObserver?
    private mutating func observer() throws -> AXObserver {
        if let observer = _observer {
            return observer
        }
        let observer = try AXObserver.observer(processIdentifier: processIdentifier)
        _observer = observer
        CFRunLoop.main.add(source: observer.runLoopSource, mode: .defaultMode)
        return observer
    }
    public init(processIdentifier: Int) {
        self.processIdentifier = processIdentifier
    }
    public mutating func add(element: Element, notification: NSAccessibilityNotificationName, handler: @escaping (Element, NSAccessibilityNotificationName, [String : Any]?) -> Void) throws -> Int {
        return try observer().add(element: element.element, notification: notification) { element, notification, info in
            let element = Element(element: element)
            handler(element, notification, Helper.repackage(dictionary: info, element: element))
        }
    }
    public mutating func remove(element: Element, notification: NSAccessibilityNotificationName, identifier: Int) throws {
        try observer().remove(element: element.element, notification: notification, identifier: identifier)
    }
}

fileprivate struct Helper {
    private static func _repackage(element: AXUIElement) -> Element {
        return Element(element: element)
    }
    private static func _repackage(array: [Any], element: Element) -> [Any] {
        do {
            return try array.map { value in
                return try _repackage(value: value, element: element)
            }
        } catch {
            return []
        }
    }
    private static func _repackage(dictionary: [String:Any], element: Element) -> [String:Any] {
        do {
            return try dictionary.reduce() { result, pair in
                result[pair.key] = try _repackage(value: pair.value as CFTypeRef, element: element)
            }
        } catch {
            return [:]
        }
    }
    private static func _repackage(axValue: AXValue) throws -> Any {
        switch axValue.type {
        case .cgPoint:
            return Frame.Point(point: try axValue.pointValue())
        case .cgSize:
            let size = try axValue.sizeValue()
            return Frame.Size(size: size)
        case .cgRect:
            let rect = try axValue.rectValue()
            return Frame(rect: rect)
        case .cfRange:
            let range = try axValue.rangeValue()
            return range.location..<range.location+range.length
        case .axError:
            throw AccessibilityError.typeMismatch
        case .illegal:
            throw AccessibilityError.typeMismatch
        }
    }
    private static func _repackage(value: Any, element: Element) throws -> Any {
        let typeID = CFGetTypeID(value as CFTypeRef)
        switch typeID {
        case AXUIElement.typeID:
            return _repackage(element: (value as! AXUIElement))
        case AXValue.typeID:
            return try _repackage(axValue: (value as! AXValue))
        case CFNumber.typeID:
            return (value as! NSNumber).intValue
        case CFBoolean.typeID:
            return (value as! NSNumber).boolValue
        case accessibility_element_get_marker_type_id():
            return Position(index: value as AXTextMarker, element: element)
        case accessibility_element_get_marker_range_type_id():
            return Range(value as AXTextMarkerRange, element: element)
        default:
            break
        }
        switch value {
        case let array as [String]:
            return _repackage(array: array, element: element)
        case let dictionary as [String:Any]:
            return _repackage(dictionary: dictionary, element: element)
        case let string as String:
            return string
        case let attributeString as NSAttributedString:
            return attributeString
        default:
            print(value)
            throw AccessibilityError.typeMismatch
        }
    }
    fileprivate static func repackage(dictionary: CFDictionary?, element: Element) -> [String : Any]? {
        guard let dictionary = dictionary as? [String:Any] else {
            return nil
        }
        return _repackage(dictionary: dictionary, element: element)
    }
}
