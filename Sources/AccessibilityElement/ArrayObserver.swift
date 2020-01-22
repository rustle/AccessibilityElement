//
//  ArrayObserver.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Foundation
import Combine

/// Typesafe KVO change tracking for Array
public struct ArrayObserver<Element>: Runner where Element : Equatable {
    private class ObserverTarget : NSObject {
        var change: ((Change) -> Void)?
        override func observeValue(forKeyPath keyPath: String?,
                                   of object: Any?,
                                   change: [NSKeyValueChangeKey : Any]?,
                                   context: UnsafeMutableRawPointer?) {
            guard let change = change else {
                return
            }
            guard let typeValue = change[.kindKey] as? NSNumber, let type = NSKeyValueChange(rawValue: typeValue.uintValue) else {
                return
            }
            switch type {
            case .setting:
                if let new = change[.newKey] as? [Element] {
                    self.change?(.set(new))
                }
            case .insertion:
                if let new = change[.newKey] as? [Element] {
                    self.change?(.insert(new))
                }
            case .removal:
                if let old = change[.oldKey] as? [Element] {
                    self.change?(.remove(old))
                }
            case .replacement:
                let old: [Element] = change[.oldKey] as? [Element] ?? []
                let new: [Element] = change[.newKey] as? [Element] ?? []
                self.change?(.replace(old, new))
            @unknown default:
                break
            }
        }
    }
    private var observer = ObserverTarget()
    /// Type and value of a single KVO notification
    public enum Change : Equatable {
        /// Indicates that the value of the observed key path was set to a new value. This change can occur when observing an attribute of an object, as well as properties that specify to-one and to-many relationships.
        case set([Element])
        /// Indicates that an object has been inserted into the to-many relationship that is being observed.
        case insert([Element])
        /// Indicates that an object has been removed from the to-many relationship that is being observed.
        case remove([Element])
        /// Indicates that an object has been replaced in the to-many relationship that is being observed.
        case replace([Element], [Element])
        public static func ==(lhs: Change, rhs: Change) -> Bool {
            switch lhs {
            case .set(let lValue):
                switch rhs {
                case .set(let rValue):
                    return lValue == rValue
                case .insert(_):
                    return false
                case .remove(_):
                    return false
                case .replace(_, _):
                    return false
                }
            case .insert(let lValue):
                switch rhs {
                case .set(_):
                    return false
                case .insert(let rValue):
                    return lValue == rValue
                case .remove(_):
                    return false
                case .replace(_, _):
                    return false
                }
            case .remove(let lValue):
                switch rhs {
                case .set(_):
                    return false
                case .insert(_):
                    return false
                case .remove(let rValue):
                    return lValue == rValue
                case .replace(_, _):
                    return false
                }
            case .replace(let lValue1, let lValue2):
                switch rhs {
                case .set(_):
                    return false
                case .insert(_):
                    return false
                case .remove(_):
                    return false
                case .replace(let rValue1, let rValue2):
                    return lValue1 == rValue1 && lValue2 == rValue2
                }
            }
        }
    }
    /// Handler called whenever a KVO notification is observed. Called on undefined queue.
    public var change: ((Change) -> Void)? {
        get {
            return observer.change
        }
        set {
            switch running {
            case .started:
                preconditionFailure("Mutating change() while running is not supported behavior.")
            case .stopped:
                if !isKnownUniquelyReferenced(&observer) {
                    observer = ObserverTarget()
                }
                observer.change = newValue
            }
        }
    }
    /// Subscribe for notifications when observer starts or stops
    public var runningSignal: AnyPublisher<Running, Never> {
        _runningSignal
            .eraseToAnyPublisher()
    }
    public let _runningSignal = PassthroughSubject<Running, Never>()
    ///
    public private(set) var running = Running.stopped {
        didSet {
            _runningSignal
                .send(running)
        }
    }
    /// Start observing for KVO notifications
    public mutating func start() {
        switch running {
        case .stopped:
            self.target?.addObserver(observer,
                                     forKeyPath: keyPath,
                                     options: [.new, .old, .initial],
                                     context: nil)
            running = .started
        case .started:
            break
        }
    }
    /// Stop observing KVO notifications
    public mutating func stop() {
        switch running {
        case .stopped:
            break
        case .started:
            self.target?.removeObserver(observer, forKeyPath: keyPath, context: nil)
            running = .stopped
        }
    }
    /// KVO target
    public private(set) weak var target: NSObject?
    /// KVO keypath
    public let keyPath: String
    /// Key Value Observe target for notifications on keyPath
    public init(target: NSObject,
                keyPath: String) {
        self.target = target
        self.keyPath = keyPath
    }
}
