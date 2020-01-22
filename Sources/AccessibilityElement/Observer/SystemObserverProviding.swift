//
//  SystemObserverProviding.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Cocoa

extension AXObserverToken: ObserverToken {}

public struct SystemObserverProviding : ObserverProviding {
    public static func provider() -> ((ProcessIdentifier) throws -> SystemObserverProviding) {
        return {
            SystemObserverProviding(processIdentifier: $0)
        }
    }
    public typealias ElementType = SystemElement
    private var processIdentifier: ProcessIdentifier
    private var _observer: AXObserver?
    private mutating func observer() throws -> AXObserver {
        if let observer = _observer {
            return observer
        }
        let observer = try AXObserver.observer(processIdentifier: processIdentifier)
        _observer = observer
        CFRunLoopAddSource(CFRunLoopGetMain(),
                           observer.runLoopSource,
                           .defaultMode)
        return observer
    }
    public init(processIdentifier: ProcessIdentifier) {
        self.processIdentifier = processIdentifier
    }
    public mutating func add(element: AnyElement,
                             notification: NSAccessibility.Notification,
                             handler: @escaping (AnyElement, NSAccessibility.Notification, [String : Any]?) -> Void) throws -> ObserverToken {
        return try observer().add(element: (element as! SystemElement).element,
                                  notification: notification) { element, notification, info in
            let element = SystemElement(element: element)
            handler(element, notification, Helper.repackage(dictionary: info, element: element))
        }
    }
    public mutating func remove(element: AnyElement,
                                notification: NSAccessibility.Notification,
                                token: ObserverToken) throws {
        try observer().remove(element: (element as! SystemElement).element,
                              notification: notification,
                              token: token as! AXObserverToken)
    }
}

fileprivate struct Helper {
    private static func _repackage(element: AXUIElement) -> SystemElement {
        return SystemElement(element: element)
    }
    private static func _repackage(array: [Any], element: SystemElement) -> [Any] {
        do {
            return try array.map { value in
                return try _repackage(value: value, element: element)
            }
        } catch {
            return []
        }
    }
    private static func _repackage(dictionary: [String:Any], element: SystemElement) -> [String:Any] {
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
        @unknown default:
            throw AccessibilityError.typeMismatch
        }
    }
    private static func _repackage(value: Any, element: SystemElement) throws -> Any {
        let typeID = CFGetTypeID(value as CFTypeRef)
        switch typeID {
        case AXUIElement.typeID:
            return _repackage(element: (value as! AXUIElement))
        case AXValue.typeID:
            return try _repackage(axValue: (value as! AXValue))
        case CFNumberGetTypeID():
            return (value as! NSNumber).intValue
        case CFBooleanGetTypeID():
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
    fileprivate static func repackage(dictionary: CFDictionary?, element: SystemElement) -> [String : Any]? {
        guard let dictionary = dictionary as? [String:Any] else {
            return nil
        }
        return _repackage(dictionary: dictionary, element: element)
    }
}
