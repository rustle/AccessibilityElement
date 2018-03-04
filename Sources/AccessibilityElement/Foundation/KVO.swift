//
//  KVO.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import Signals

fileprivate class KeyValueObservationTarget : NSObject {
    var isObserving = false
    var observers = [AnyKeyValueObserver]()
    override init() {
        super.init()
    }
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard let change = change else {
            return
        }
        let value = change[.newKey]
        for observer in observers {
            observer.receive(value: value)
        }
    }
}

public struct KeyValueObservable {
    public private(set) weak var object: NSObject?
    public let keyPath: String
    private let target = KeyValueObservationTarget()
    public init(object: NSObject,
                keyPath: String) {
        self.object = object
        self.keyPath = keyPath
    }
    public func add<T>(observer: T) where T : KeyValueObserver {
        target.observers.append(observer)
        if !target.isObserving {
            object?.addObserver(target,
                                forKeyPath: keyPath,
                                options: .new,
                                context: nil)
            target.isObserving = true
        }
    }
    public func remove<T>(observer: T) where T : KeyValueObserver {
        var i: Int?
        i = target.observers.index(equatable: observer)
        guard let index = i else {
            return
        }
        target.observers.remove(at: index)
        if target.observers.count == 0, target.isObserving {
            object?.removeObserver(target,
                                   forKeyPath: keyPath,
                                   context: nil)
            target.isObserving = false
        }
    }
    public func stopObserving() {
        target.observers.removeAll()
        object?.removeObserver(target,
                               forKeyPath: keyPath,
                               context: nil)
        target.isObserving = false
    }
}

public protocol AnyKeyValueObserver {
    func receive(value: Any?)
}

public protocol KeyValueObserver : AnyKeyValueObserver, Equatable {
    
}

public struct KeyValueObserverTargetKeyPath : KeyValueObserver {
    public private(set) weak var object: NSObject?
    public let keyPath: String
    public init(object: NSObject,
                keyPath: String) {
        self.object = object
        self.keyPath = keyPath
    }
    public func receive(value: Any?) {
        object?.setValue(value, forKeyPath: keyPath)
    }
    public static func ==(lhs: KeyValueObserverTargetKeyPath,
                          rhs: KeyValueObserverTargetKeyPath) -> Bool {
        return lhs.object == rhs.object && lhs.keyPath == rhs.keyPath
    }
}

public protocol AnyKeyValueObserverSignal : KeyValueObserver {
    
}

public struct KeyValueObserverSignal<T> : AnyKeyValueObserverSignal {
    public let signal = Signal<T?>()
    public init() {
        
    }
    public func receive(value: Any?) {
        if let value = value as? T {
            signal=>value
        } else {
            signal=>nil
        }
    }
    public static func ==(lhs: KeyValueObserverSignal<T>,
                          rhs: KeyValueObserverSignal<T>) -> Bool {
        return lhs.signal === rhs.signal
    }
}
