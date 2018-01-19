//
//  AccessibilityObserver.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import Foundation

public typealias ObserverHandler = (Element, NSAccessibilityNotificationName, [String:Any]?) -> Void

public enum ObserverError : Error {
    case invalidApplication
    case invalidToken
}

public class ObserverManager {
    public static let shared = ObserverManager()
    private var map = [Int : ApplicationObserver]()
    public func registerObserver(application: Element) throws -> ApplicationObserver {
        let processIdentifier = application.processIdentifier
        guard processIdentifier > 0 else {
            throw ObserverError.invalidApplication
        }
        if let observer = map[processIdentifier] {
            return observer
        }
        let observer = try ApplicationObserver(processIdentifier: processIdentifier)
        map[processIdentifier] = observer
        return observer
    }
}

public class ApplicationObserver {
    private var _observer: AXObserver?
    private func observer() throws -> AXObserver {
        if let observer = _observer {
            return observer
        }
        let observer = try AXObserver.observer(processIdentifier: processIdentifier)
        _observer = observer
        CFRunLoop.main.add(source: observer.runLoopSource, mode: .defaultMode)
        return observer
    }
    private let processIdentifier: Int
    private var tokens = Set<Token>()
    public struct Token : Equatable, Hashable {
        public static func ==(lhs: Token, rhs: Token) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        public var hashValue: Int {
            return identifier
        }
        fileprivate let element: Element
        fileprivate let notification: NSAccessibilityNotificationName
        fileprivate let identifier: Int
    }
    public init(processIdentifier: Int) throws {
        self.processIdentifier = processIdentifier
    }
    public func startObserving(element: Element, notification: NSAccessibilityNotificationName, handler: @escaping ObserverHandler) throws -> Token {
        let identifier = try observer().add(element: element.element, notification: notification) { element, notification, info in
            handler(Element(element: element), notification, Helper.repackage(dictionary: info))
        }
        let token = Token(element: element, notification: notification, identifier: identifier)
        tokens.insert(token)
        return token
    }
    public func startObserving<Root, Value>(element: Element, notification: NSAccessibilityNotificationName, root: Root, keyPath: ReferenceWritableKeyPath<Root, Value>, handler: @escaping (Element, inout Value, [String:Any]?) -> Void) throws -> Token {
        return try startObserving(element: element, notification: notification) { element, name, info in
            handler(element, &root[keyPath: keyPath], info)
        }
    }
    public func stopObserving(token: Token) throws {
        if tokens.contains(token) {
            try observer().remove(element: token.element.element, notification: token.notification, identifier: token.identifier)
        } else {
            throw ObserverError.invalidToken
        }
        if tokens.count == 0 {
            guard let observer = _observer else {
                return
            }
            CFRunLoop.main.remove(source: observer.runLoopSource, mode: .defaultMode)
            _observer = nil
        }
    }
}

fileprivate struct Helper {
    private static func _repackage(element: AXUIElement) -> Element {
        return Element(element: element)
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
    private static func _repackage(value: CFTypeRef) throws -> Any {
        let typeID = CFGetTypeID(value)
        switch typeID {
        case AXUIElement.typeID:
            return _repackage(element: (value as! AXUIElement))
        case AXValue.typeID:
            return try _repackage(axValue: (value as! AXValue))
        case CFNumber.typeID:
            return (value as! NSNumber).intValue
        case CFBoolean.typeID:
            switch value as! CFBoolean {
            case kCFBooleanTrue:
                return true
            case kCFBooleanFalse:
                return false
            default:
                throw AccessibilityError.typeMismatch
            }
        case CFArray.typeID:
            return _repackage(array: value as! CFArray)
        case CFDictionary.typeID:
            return _repackage(dictionary: (value as! CFDictionary))
        default:
            return value
        }
    }
    fileprivate static func repackage(dictionary: CFDictionary?) -> [String : Any]? {
        guard let dictionary = dictionary else {
            return nil
        }
        return _repackage(dictionary: dictionary)
    }
}
