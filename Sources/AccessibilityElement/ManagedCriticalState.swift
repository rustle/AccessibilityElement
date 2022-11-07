//===----------------------------------------------------------------------===//
//
// This file is extracted from the Swift Async Algorithms open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/Locking.swift

import os.lock

struct Lock {
    typealias Primitive = os_unfair_lock

    typealias PlatformLock = UnsafeMutablePointer<Primitive>
    let platformLock: PlatformLock
    
    private init(_ platformLock: PlatformLock) {
        self.platformLock = platformLock
    }

    fileprivate static func initialize(_ platformLock: PlatformLock) {
        platformLock.initialize(to: os_unfair_lock())
    }

    fileprivate static func deinitialize(_ platformLock: PlatformLock) {
        platformLock.deinitialize(count: 1)
    }

    fileprivate static func lock(_ platformLock: PlatformLock) {
        os_unfair_lock_lock(platformLock)
    }

    fileprivate static func unlock(_ platformLock: PlatformLock) {
        os_unfair_lock_unlock(platformLock)
    }

    static func allocate() -> Lock {
        let platformLock = PlatformLock.allocate(capacity: 1)
        initialize(platformLock)
        return Lock(platformLock)
    }

    func deinitialize() {
        Lock.deinitialize(platformLock)
    }

    func lock() {
        Lock.lock(platformLock)
    }

    func unlock() {
        Lock.unlock(platformLock)
    }
}

struct ManagedCriticalState<State> {
    private final class LockedBuffer: ManagedBuffer<State, Lock.Primitive> {
        deinit {
            withUnsafeMutablePointerToElements { Lock.deinitialize($0) }
        }
    }

    private let buffer: ManagedBuffer<State, Lock.Primitive>

    init(_ initial: State) {
        buffer = LockedBuffer.create(minimumCapacity: 1) { buffer in
            buffer.withUnsafeMutablePointerToElements { Lock.initialize($0) }
            return initial
        }
    }

    func withCriticalRegion<R>(_ critical: (inout State) throws -> R) rethrows -> R {
        try buffer.withUnsafeMutablePointers { header, lock in
            Lock.lock(lock)
            defer { Lock.unlock(lock) }
            return try critical(&header.pointee)
        }
    }
}

extension ManagedCriticalState: @unchecked Sendable where State: Sendable { }
