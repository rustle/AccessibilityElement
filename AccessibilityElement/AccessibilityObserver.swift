//
//  AccessibilityObserver.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import Foundation

public typealias AccessibilityObserverHandler = (AccessibilityElement, NSAccessibilityNotificationName, Any?) -> Void

public enum AccessibilityObserverError : Error {
    case invalidApplication
}

public class AccessibilityObserverManager {
    public static let shared = AccessibilityObserverManager()
    private let queue = DispatchQueue(label: "AccessibilityObserverManager")
    private var map = [Int : AccessibilityApplicationObserver]()
    public func registerObserver(application: AccessibilityElement) throws -> AccessibilityApplicationObserver {
        let processIdentifier = application.processIdentifier
        guard processIdentifier > 0 else {
            throw AccessibilityObserverError.invalidApplication
        }
        // Fast path (just get an existing observer)
        if let observer = queue.sync(execute: { return map[processIdentifier] }) {
            return observer
        }
        // Slow path (barrier sync, and create observer if needed)
        return try queue.sync(flags: [.barrier]) {
            // Make sure the observer wasn't created while we were aquiring the barrier
            if let observer = map[processIdentifier] {
                return observer
            }
            let observer = try AccessibilityApplicationObserver(processIdentifier: processIdentifier)
            map[processIdentifier] = observer
            return observer
        }
    }
}

public class AccessibilityApplicationObserver {
    private let observer: AXObserver
    public struct Token {
        fileprivate let element: AccessibilityElement
        fileprivate let notification: NSAccessibilityNotificationName
        fileprivate let identifier: Int
    }
    private static func _repackage(element: AXUIElement) -> AccessibilityElement {
        return AccessibilityElement(element: element)
    }
    private static func _repackage(array: CFArray) -> [Any] {
        var newArray = [Any]()
        array.apply { value in
            do {
                newArray.append(try _repackage(value: value))
            } catch {
                
            }
        }
        return newArray
    }
    private static func _repackage(dictionary: CFDictionary) -> [String : Any] {
        var newDictionary = [String:Any]()
        dictionary.apply { key, value in
            guard CFGetTypeID(key) == CFString.typeID else {
                return
            }
            let cf = key as! CFString
            do {
                newDictionary[cf as String] = try _repackage(value: value)
            } catch {
                
            }
        }
        return newDictionary
    }
    private static func _repackage(axValue: AXValue) throws -> Any {
        switch axValue.type {
        case .cgPoint:
            return AccessibilityElement.Frame.Point(point: try axValue.pointValue())
        case .cgSize:
            let size = try axValue.sizeValue()
            return AccessibilityElement.Frame.Size(size: size)
        case .cgRect:
            let rect = try axValue.rectValue()
            return AccessibilityElement.Frame(rect: rect)
        case .cfRange:
            let range = try axValue.rangeValue()
            return range.location..<range.location+range.length
        case .axError:
            throw AccessibilityError.typeMismatch
        case .illegal:
            throw AccessibilityError.typeMismatch
        }
    }
    private static func _repackage(value: CFTypeRef) throws -> Any {
        switch value {
        case let element as AXUIElement:
            return _repackage(element: element)
        case let axValue as AXValue:
            return try _repackage(axValue: axValue)
        case let number as CFNumber:
            return try number.value()
        case let boolean as CFBoolean:
            switch boolean {
            case kCFBooleanTrue:
                return true
            case kCFBooleanFalse:
                return false
            default:
                throw AccessibilityError.typeMismatch
            }
        case let array as CFArray:
            return _repackage(array: array)
        case let dictionary as CFDictionary:
            return _repackage(dictionary: dictionary)
//        case let string as String:
//            return string
        default:
            return value
        }
    }
    private static func repackage(dictionary: CFDictionary?) -> [String : Any]? {
        guard let dictionary = dictionary else {
            return nil
        }
        return _repackage(dictionary: dictionary)
    }
    public init(processIdentifier: Int) throws {
        observer = try AXObserver.observer(processIdentifier: processIdentifier)
    }
    public func startObserving(element: AccessibilityElement, notification: NSAccessibilityNotificationName, handler: @escaping AccessibilityObserverHandler) throws -> Token {
        let identifier = try observer.add(element: element.element, notification: notification) { element, notification, info in
            handler(AccessibilityElement(element: element), notification, AccessibilityApplicationObserver.repackage(dictionary: info))
        }
        return Token(element: element, notification: notification, identifier: identifier)
    }
    public func stopObserving(token: Token) throws {
        try observer.remove(element: token.element.element, notification: token.notification, identifier: token.identifier)
    }
}
