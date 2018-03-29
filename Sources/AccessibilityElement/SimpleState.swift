//
//  SimpleState.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import Atomics

public class SimpleState<StateType> {
    private var state = ConcurrentDictionary<Int, StateType>()
    private var counter = AtomicInt64()
    public init() {
        counter.initialize(1234)
    }
    public func next() -> Int {
        return Int(counter.increment())
    }
    public func set(state: StateType, identifier: Int) {
        self.state.set(value: state, key: identifier)
    }
    public func remove(identifier: Int) {
        self.state.remove(key: identifier)
    }
    public func state(identifier: Int) -> StateType? {
        return self.state.value(key: identifier)
    }
}
