//
//  AccessibilityObserver.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import Foundation
import Signals

public typealias ObserverSignalData = (element: Element, info: ObserverInfo?)
public typealias ObserverInfo = [String:Any]
public typealias ObserverHandler = (Element, ObserverInfo?) -> Void

public final class ObserverSignal : SignalSubscriptionProviding {
    public typealias SignalData = ObserverSignalData
    private weak var observer: ApplicationObserver?
    private let element: Element
    private let notification: NSAccessibilityNotificationName
    private let signal = Signal<ObserverSignalData>()
    private var token: ApplicationObserver.Token?
    private var count = 0
    fileprivate func increment() throws {
        count += 1
        if count == 1 {
            token = try observer?.startObserving(element: element, notification: notification) { element, info in
                self.signal=>(element, info)
            }
        }
    }
    fileprivate func decrement() throws {
        count -= 1
        if count == 0 {
            if let token = token {
                try observer?.stopObserving(token: token)
                self.token = nil
            }
        }
    }
    fileprivate init(element: Element,
                     notification: NSAccessibilityNotificationName,
                     observer: ApplicationObserver) {
        self.element = element
        self.notification = notification
        self.observer = observer
    }
    @discardableResult
    public func subscribe(callback: @escaping (ObserverSignalData) -> Void) -> SignalSubscription<ObserverSignalData> {
        try? increment()
        return signal.subscribe(callback: callback)
    }
    @discardableResult
    public func subscribe(with observer: AnyObject, callback: @escaping (ObserverSignalData) -> Void) -> SignalSubscription<ObserverSignalData> {
        try? increment()
        return signal.subscribe(with: observer, callback: callback)
    }
    @discardableResult
    public func subscribeOnce(with observer: AnyObject, callback: @escaping (ObserverSignalData) -> Void) -> SignalSubscription<ObserverSignalData> {
        try? increment()
        return signal.subscribeOnce(with: observer, callback: callback)
    }
    public func cancelSubscription(for observer: AnyObject) {
        
    }
    public func cancelAllSubscriptions() {
        
    }
}

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
    deinit {
        stop()
    }
    private lazy var signalMap = [Element:[NSAccessibilityNotificationName:ObserverSignal]]()
    public func signal(element: Element, notification: NSAccessibilityNotificationName) throws -> ObserverSignal {
        if let signal = signalMap[element]?[notification] {
            return signal
        }
        if signalMap[element] == nil {
            signalMap[element] = [NSAccessibilityNotificationName:ObserverSignal]()
        }
        let observerSignal = ObserverSignal(element: element, notification: notification, observer: self)
        signalMap[element]?[notification] = observerSignal
        return observerSignal
    }
    public func startObserving(element: Element, notification: NSAccessibilityNotificationName, handler: @escaping ObserverHandler) throws -> Token {
        let identifier = try observer().add(element: element.element, notification: notification) { element, notification, info in
            let element = Element(element: element)
            handler(element, Helper.repackage(dictionary: info, element: element))
        }
        let token = Token(element: element, notification: notification, identifier: identifier)
        tokens.insert(token)
        return token
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
    public func stop() {
        for token in tokens {
            try? stopObserving(token: token)
        }
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
