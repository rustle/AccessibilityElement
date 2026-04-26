//
//  SystemObserver.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AppKit
import Atomics
import AX
import os
import RunLoopExecutor

// MARK: - SystemObserver

/// `SystemObserver` is a Swift actor implementing `Observer` for safe and efficient `AXObserver` use.
///
/// Each `SystemObserver` has an `AXObserver` scheduled on the `CFRunLoop` associated with it's executor (`RunLoopExecutor`), and all callback for that observer fires on the thread running that loop. Actor methods — most importantly the methods that add and remove subscriptions — execute on that same thread via the executor.
public actor SystemObserver: Observer, Sendable {
    // MARK: Types

    // Token represents a single active notification subscription.
    // subscriptionKey is encoded in the low 32 bits of the refcon and used as the
    // lookup key in the per-observer table. The key is removed from the table in
    // remove(token:) or stop(), making subsequent stale callback lookups return nil.
    fileprivate final class Token: @unchecked Sendable {
        let element: SystemElement
        let notification: NSAccessibility.Notification
        let stream: AsyncThrowingStream<ObserverNotification<ObserverElement>, any Error>
        let continuation: AsyncThrowingStream<ObserverNotification<ObserverElement>, any Error>.Continuation
        let subscriptionKey: UInt32

        init(
            element: SystemElement,
            notification: NSAccessibility.Notification,
            subscriptionKey: UInt32
        ) {
            self.element = element
            self.notification = notification
            let (stream, continuation) = AsyncThrowingStream<ObserverNotification<ObserverElement>, any Error>.makeStream()
            self.stream = stream
            self.continuation = continuation
            self.subscriptionKey = subscriptionKey
        }

        deinit {
            continuation.finish()
        }

        func yield(
            element: SystemElement,
            notification: NSAccessibility.Notification,
            info: [String: ObserverElementInfoValue]
        ) {
            continuation.yield(
                .init(
                    observedElement: self.element,
                    element: element,
                    name: notification,
                    info: info
                )
            )
        }
    }

    public typealias ObserverElement = SystemElement

    // MARK: Actor/Executor

    public nonisolated let unownedExecutor: UnownedSerialExecutor

    // MARK: Identity

    // Unique ID encoded in the high 32 bits of the refcon, used by observer_callback
    // to route to this observer's per-observer table via thread-local storage.
    private let observerId: UInt32

    // Subscription table for this observer. Accessed only on the actor's RunLoop
    // thread via actor isolation — no additional synchronization needed.
    private let perObserverTable = SystemObserverTokenTable()

    // MARK: Init

    public let processIdentifier: pid_t

    public init(
        processIdentifier: pid_t,
        executor: RunLoopExecutor
    ) throws {
        unownedExecutor = executor.asUnownedSerialExecutor()
        self.processIdentifier = processIdentifier
        self.observerId = systemObserverIdCounter.loadThenWrappingIncrement(ordering: .relaxed)
    }

    // MARK: State

    private var observer: AX.Observer?

    // MARK: Lifecycle

    public func start() async throws {
        guard observer == nil else { return }
        let obs = try promoteAXObserverErrorToObserverErrorOnThrow {
            try AX.Observer(
                pid: processIdentifier,
                callback: observer_callback
            )
        }
        observer = obs
        obs.schedule()
        systemObserverThreadStorage().observers[observerId] = perObserverTable
    }

    public func stop() throws {
        // Remove from thread-local routing before unscheduling so stale callbacks
        // that fire in the no-flush window safely miss at the observer lookup.
        currentSystemObserverThreadStorage()?.observers.removeValue(forKey: observerId)
        let obs = observer
        observer = nil
        obs?.unschedule()
        // Releasing all tokens causes their deinits to call continuation.finish(),
        // terminating any active streams.
        perObserverTable.subscriptions.removeAll()
    }

    public func stream(
        element: SystemElement,
        notification: NSAccessibility.Notification
    ) async throws -> any AsyncThrowingSendableSequence<ObserverNotification<SystemElement>> {
        guard let observer else {
            throw ObserverError.failure
        }
        let subscriptionKey = perObserverTable.nextKey
        perObserverTable.nextKey &+= 1
        let token = Token(
            element: element,
            notification: notification,
            subscriptionKey: subscriptionKey
        )
        perObserverTable.subscriptions[subscriptionKey] = token
        let refcon = (UInt(observerId) << 32) | UInt(subscriptionKey)
        do {
            try promoteAXObserverErrorToObserverErrorOnThrow {
                try observer.add(
                    element: element.element,
                    notification: notification,
                    context: UnsafeMutableRawPointer(bitPattern: refcon)
                )
            }
        } catch {
            perObserverTable.subscriptions.removeValue(forKey: subscriptionKey)
            throw error
        }
        token.continuation.onTermination = { @Sendable [weak self, weak token] _ in
            guard let self, let token else { return }
            Task {
                await self.remove(token: token)
            }
        }
        return token.stream
    }

    private func remove(token: Token) {
        guard perObserverTable.subscriptions[token.subscriptionKey] === token else { return }
        perObserverTable.subscriptions.removeValue(forKey: token.subscriptionKey)
        if let observer {
            try? promoteAXObserverErrorToObserverErrorOnThrow {
                try observer.remove(
                    element: token.element.element,
                    notification: token.notification
                )
            }
        }
    }
}

// MARK: - Callback

/// observer_callback fires on the `CFRunLoop` the `AXObserver` was scheduled on.
///
/// The refcon encodes two values packed into a single UInt:
///   high 32 bits — observer ID: routes to the correct per-observer table via TLS
///   low  32 bits — subscription key: identifies the token within that table
///
/// Both lookups return nil for stale callbacks — the observer is removed from
/// thread-local storage in stop() before unschedule(), and subscriptions are
/// removed from the per-observer table in remove(token:) — so post-unschedule
/// callbacks are safe no-ops without any locking or shared mutable state.
func observer_callback(
    _ observer: AXObserver,
    _ uiElement: AXUIElement,
    _ name: CFString,
    _ info: CFDictionary?,
    _ refCon: UnsafeMutableRawPointer?
) {
    guard let refCon else { return }
    let combined = UInt(bitPattern: refCon)
    let observerId = UInt32(combined >> 32)
    let subscriptionKey = UInt32(combined & 0xFFFF_FFFF)
    guard
        let storage = currentSystemObserverThreadStorage(),
        let table = storage.observers[observerId],
        let token = table.subscriptions[subscriptionKey]
    else { return }
    token.yield(
        element: SystemElement(element: uiElement as UIElement),
        notification: name as NSAccessibility.Notification,
        info: SystemObserverUserInfoRepackager.repackage(dictionary: info)
    )
}

// MARK: - Observer ID allocation

/// Monotonic counter that makes up half of a given Observer ID.
///
/// Called only at `SystemObserver` init time — never by observer_callback.
private let systemObserverIdCounter = ManagedAtomic<UInt32>(0)

// MARK: - Thread-local observer routing

/// `pthread_key_t` whose value on each `RunLoopExecutor` thread is an `SystemObserverThreadStorage`.
private let systemObserverStorageKey: pthread_key_t = {
    var key: pthread_key_t = 0
    pthread_key_create(&key) { ptr in
        Unmanaged<SystemObserverThreadStorage>.fromOpaque(ptr).release()
    }
    return key
}()

private func currentSystemObserverThreadStorage() -> SystemObserverThreadStorage? {
    guard let ptr = pthread_getspecific(systemObserverStorageKey) else { return nil }
    return Unmanaged<SystemObserverThreadStorage>.fromOpaque(ptr).takeUnretainedValue()
}

private func systemObserverThreadStorage() -> SystemObserverThreadStorage {
    if let storage = currentSystemObserverThreadStorage() {
        return storage
    }
    let storage = SystemObserverThreadStorage()
    pthread_setspecific(
        systemObserverStorageKey,
        Unmanaged.passRetained(storage).toOpaque()
    )
    return storage
}

// Holds the per-observer subscription tables for all `SystemObservers` running on
// a given `RunLoopExecutor`. Accessed only from its owning thread.
private final class SystemObserverThreadStorage {
    var observers: [UInt32: SystemObserverTokenTable] = [:]
}

// Subscription table for a single `SystemObserver`.
// Accessed only on the actor's `RunLoopExecutor`.
private final class SystemObserverTokenTable {
    var subscriptions: [UInt32: SystemObserver.Token] = [:]
    // Start at 1: observer ID 0 + subscription key 0 produces a zero bit-pattern
    // refcon, which UnsafeMutableRawPointer(bitPattern:) maps to nil.
    var nextKey: UInt32 = 1
}
