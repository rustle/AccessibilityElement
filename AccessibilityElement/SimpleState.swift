//
//  SimpleState.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public class SimpleState<StateType> {
    private var state = [Int : StateType]()
    private let queue = DispatchQueue(label: "SimpleState.sync")
    private var counter = 1234
    public init() {
        
    }
    public func next() -> Int {
        // TODO: this should use stdatomic, but it sucks in swift right now
        return queue.sync {
            counter += 1
            return counter
        }
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
