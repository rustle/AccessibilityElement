//
//  ArrayObserver.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct ArrayObserver<Element> {
    private class ObserverTarget : NSObject {
        var change: ((Change) -> Void)?
        override func observeValue(forKeyPath keyPath: String?,
                                   of object: Any?,
                                   change: [NSKeyValueChangeKey : Any]?,
                                   context: UnsafeMutableRawPointer?) {
            guard let change = change else {
                return
            }
            guard let typeValue = change[.kindKey] as? NSNumber, let type = NSKeyValueChange.init(rawValue: typeValue.uintValue) else {
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
            }
        }
    }
    public enum Change {
        case set([Element])
        case insert([Element])
        case remove([Element])
        case replace([Element], [Element])
    }
    public var change: ((Change) -> Void)? {
        get {
            return observer.change
        }
        set {
            switch state {
            case .started:
                fatalError()
            case .stopped:
                if !isKnownUniquelyReferenced(&observer) {
                    observer = ObserverTarget()
                }
                observer.change = newValue
            }
        }
    }
    private var observer = ObserverTarget()
    private enum State {
        case stopped
        case started
    }
    private var state: State = .stopped
    public mutating func start() {
        switch state {
        case .stopped:
            self.target?.addObserver(observer, forKeyPath: keyPath, options: [.new, .old, .initial], context: nil)
            state = .started
        case .started:
            break
        }
    }
    public mutating func stop() {
        switch state {
        case .stopped:
            break
        case .started:
            self.target?.removeObserver(observer, forKeyPath: keyPath, context: nil)
            state = .stopped
        }
    }
    private weak var target: NSObject?
    private let keyPath: String
    public init(target: NSObject, keyPath: String) {
        self.target = target
        self.keyPath = keyPath
    }
}
