//
//  ObserverRunLoopActor.swift
//
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

import AX
import Cocoa

@globalActor
actor ObserverRunLoopActor: GlobalActor {
    typealias ActorType = ObserverRunLoopActor
    static let shared: ActorType = ObserverRunLoopActor()
    init() {
        let executor = RunLoopExecutor()
        self.executor = executor
        unownedExecutor = executor.asUnownedSerialExecutor()
        executor.start()
    }
    nonisolated let executor: SerialExecutor
    nonisolated let unownedExecutor: UnownedSerialExecutor
}

private final class RunLoopExecutor: Thread, SerialExecutor, @unchecked Sendable {
    override init() {
        super.init()
        name = "AccessibilityElement.SystemObserver"
        qualityOfService = .userInitiated
    }
    override func main() {
        autoreleasepool {
            // Toss something on the run loop so it doesn't return right away
            Timer.scheduledTimer(timeInterval: Date.distantFuture.timeIntervalSince1970,
                                 target: self,
                                 selector: #selector(nop),
                                 userInfo: nil,
                                 repeats: true)
            while true {
                autoreleasepool {
                    _ = RunLoop.current
                        .run(mode: .default,
                             before: Date(timeIntervalSinceNow: 1.0))
                }
            }
        }
    }
    @objc func nop() {}
    // Stick UnownedJob inside a reference type
    private class Job: NSObject {
        private let unownedJob: UnownedJob
        init(unownedJob: UnownedJob) {
            self.unownedJob = unownedJob
        }
        func runSynchronously(on unownedExecutor: UnownedSerialExecutor) {
            unownedJob._runSynchronously(on: unownedExecutor)
        }
    }
    func enqueue(_ job: UnownedJob) {
        perform(#selector(enqueueOnRunLoop),
                on: self,
                with: Job(unownedJob: job),
                waitUntilDone: false,
                modes: [RunLoop.Mode.default.rawValue])
    }
    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
    @objc private func enqueueOnRunLoop(_ job: Job ) {
        job.runSynchronously(on: asUnownedSerialExecutor())
    }
}
