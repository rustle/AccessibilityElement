//
//  SimpleState.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import Atomics

public class SimpleState<StateType> {
    private var state = [Int : StateType]()
    private let queue = DispatchQueue(label: "SimpleState.sync")
    private var counter = AtomicInt64()
    public init() {
        counter.initialize(1234)
    }
    public func next() -> Int {
        return Int(counter.increment())
    }
    public func set(state: StateType, identifier: Int) {
        queue.sync(flags: [.barrier]) {
            self.state[identifier] = state
        }
    }
    public func remove(identifier: Int) {
        queue.sync(flags: [.barrier]) { () -> Void in
            self.state.removeValue(forKey: identifier)
        }
    }
    public func state(identifier: Int) -> StateType? {
        return queue.sync {
            return self.state[identifier]
        }
    }
}
