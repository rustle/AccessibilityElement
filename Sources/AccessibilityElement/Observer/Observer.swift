//
//  AccessibilityObserver.swift
//
//  Copyright © 2017-2019 Doug Russell. All rights reserved.
//

import Cocoa
import Combine

public protocol AnyObserverManager {}

public protocol AnyApplicationObserver {}

public class ObserverManager<ElementType> : AnyObserverManager where ElementType : Element {
    private var map = [Int : ApplicationObserver<ElementType>]()
    private let provider: (ProcessIdentifier) throws -> ElementType.ObserverProvidingType
    public init(provider: @escaping (Int) throws -> ElementType.ObserverProvidingType) {
        self.provider = provider
    }
    public func registerObserver(application: ElementType) throws -> ApplicationObserver<ElementType> {
        let processIdentifier = application.processIdentifier
        guard processIdentifier > 0 else {
            throw ObserverManager.Error.invalidApplication
        }
        if let observer = map[processIdentifier] {
            return observer
        }
        let observer = try ApplicationObserver<ElementType>(processIdentifier: processIdentifier,
                                                            provider: provider)
        map[processIdentifier] = observer
        return observer
    }
}

public class ApplicationObserver<ElementType> : AnyApplicationObserver where ElementType : Element {
    private var _observer: ElementType.ObserverProvidingType?
    private var observer: ElementType.ObserverProvidingType {
        get {
            if _observer == nil {
                _observer = try? provider(processIdentifier)
            }
            return _observer!
        }
        set {
            _observer = newValue
        }
    }
    private let provider: (ProcessIdentifier) throws -> ElementType.ObserverProvidingType
    private let processIdentifier: ProcessIdentifier
    private var tokens = Set<Token>()
    public struct Token : Equatable, Hashable {
        public static func ==(lhs: Token, rhs: Token) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        public func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        fileprivate let element: ElementType
        fileprivate let notification: NSAccessibility.Notification
        fileprivate let identifier: Int
    }
    public init(processIdentifier: ProcessIdentifier,
                provider: @escaping (ProcessIdentifier) throws -> ElementType.ObserverProvidingType) throws {
        self.processIdentifier = processIdentifier
        self.provider = provider
    }
    deinit {
        stop()
    }
    public func publisher(element: ElementType,
                          notification: NSAccessibility.Notification) throws -> AnyPublisher<(element: ElementType, info: ElementNotificationInfo?), ObserverError> {
        ElementNotificationPublisher(element: element,
                                     notification: notification,
                                     observer: self)
            .eraseToAnyPublisher()
    }
    public func startObserving(element: ElementType,
                               notification: NSAccessibility.Notification,
                               handler: @escaping (ElementType, ElementNotificationInfo?) -> Void) throws -> Token {
        let identifier = try observer.add(element: element,
                                          notification: notification) { element, _, info in
            handler(element as! ElementType, info)
        }
        let token = Token(element: element, notification: notification, identifier: identifier)
        tokens.insert(token)
        return token
    }
    public func stopObserving(token: Token) throws {
        if tokens.contains(token) {
            try observer.remove(element: token.element, notification: token.notification, identifier: token.identifier)
        } else {
            throw ObserverManager<ElementType>.Error.invalidToken
        }
    }
    public func stop() {
        for token in tokens {
            try? stopObserving(token: token)
        }
    }
}
