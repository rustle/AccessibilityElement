//
//  RunLoopExecutor.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AX
import Cocoa
import Atomics

public final class RunLoopExecutor: Thread, SerialExecutor, @unchecked Sendable {
    public override init() {
        super.init()
        name = "AccessibilityElement.SystemObserver"
        qualityOfService = .userInitiated
    }
    public override func main() {
        autoreleasepool {
            let runLoop = CFRunLoopGetCurrent()
            var context = CFRunLoopSourceContext()
            guard let source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context) else {
                return
            }
            CFRunLoopAddSource(runLoop, source, .defaultMode)
            CFRunLoopRun()
            CFRunLoopRemoveSource(runLoop, source, .defaultMode)
        }
    }
    // Stick UnownedJob inside a reference type
    private class Job: NSObject {
        private let unownedJob: UnownedJob
        init(unownedJob: UnownedJob) {
            self.unownedJob = unownedJob
        }
        func runSynchronously(on unownedExecutor: UnownedSerialExecutor) {
            unownedJob.runSynchronously(on: unownedExecutor)
        }
    }
    public func enqueue(_ job: UnownedJob) {
        autoreleasepool {
            perform(#selector(enqueueOnRunLoop),
                    on: self,
                    with: Job(unownedJob: job),
                    waitUntilDone: false,
                    modes: [RunLoop.Mode.default.rawValue])
        }
    }
    public func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
    @objc private func enqueueOnRunLoop(_ job: Job) {
        autoreleasepool {
            job.runSynchronously(on: asUnownedSerialExecutor())
        }
    }
}
