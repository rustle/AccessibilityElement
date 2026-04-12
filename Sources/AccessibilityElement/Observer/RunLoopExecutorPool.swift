//
//  RunLoopExecutorPool.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import Atomics
import Foundation

public final class RunLoopExecutorPool: Sendable {
    private let executors: [RunLoopExecutor]
    private let index = ManagedAtomic<Int>(0)

    public init(count: Int = ProcessInfo.processInfo.activeProcessorCount) {
        self.executors = (0..<count).map { _ in
            let executor = RunLoopExecutor()
            executor.start()
            return executor
        }
    }

    public func next() -> RunLoopExecutor {
        let i = index.wrappingIncrementThenLoad(ordering: .relaxed)
        return executors[i % executors.count]
    }
}
