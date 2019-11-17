//
//  SimpleState.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import SwiftAtomics

public class SimpleState<StateType> {
    private var state = ConcurrentDictionary<Int, StateType>()
    private var counter = AtomicInt(1234)
    public init() {
        
    }
    public func next() -> Int {
        counter.increment()
    }
    public func set(state: StateType, identifier: Int) {
        self.state.set(value: state, key: identifier)
    }
    public func remove(identifier: Int) {
        state.remove(key: identifier)
    }
    public func state(identifier: Int) -> StateType? {
        state.value(key: identifier)
    }
}
