//
//  ObserverRunLoopActor.swift
//
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

import AppKit
import AX

public final class RunLoopExecutor: Thread, SerialExecutor, @unchecked Sendable {
    public override init() {
        super.init()
        name = "AccessibilityElement.RunLoopExecutor"
        qualityOfService = .userInitiated
    }
    public override func main() {
        autoreleasepool {
            // Toss something on the run loop so it doesn't return right away
            Timer.scheduledTimer(
                timeInterval: Date.distantFuture.timeIntervalSince1970,
                target: self,
                selector: #selector(nop),
                userInfo: nil,
                repeats: true
            )
            while true {
                autoreleasepool {
                    _ = RunLoop.current
                        .run(
                            mode: .default,
                            before: Date(timeIntervalSinceNow: 1.0)
                        )
                }
            }
        }
    }
    @objc private func nop() {}
    // Stick Job inside an ObjC type
    private class Job: NSObject {
        private let unownedJob: UnownedJob
        init(job: consuming ExecutorJob) {
            self.unownedJob = UnownedJob(job)
        }
        func runSynchronously(on unownedExecutor: UnownedSerialExecutor) {
            unownedJob.runSynchronously(on: unownedExecutor)
        }
    }
    public func enqueue(_ job: consuming ExecutorJob) {
        perform(#selector(enqueueOnRunLoop),
                on: self,
                with: Job(job: job),
                waitUntilDone: false,
                modes: [RunLoop.Mode.default.rawValue])
    }
    public func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
    @objc private func enqueueOnRunLoop(_ job: Job) {
        job.runSynchronously(on: asUnownedSerialExecutor())
    }
}
