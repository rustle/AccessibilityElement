//
//  SystemObserver.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AppKit
import AX
import os

// MARK: - Global token lookup

// The refCon passed to AXObserverAddNotification is a UInt key bit-cast to
// UnsafeMutableRawPointer. It is NOT a pointer to heap memory — there is
// nothing to free. Stale callbacks (delivered after AXObserverRemoveNotification
// or after unschedule) simply miss in the table and return safely.
private struct TokenLookupState {
    var table: [UInt: SystemObserver.Token] = [:]
    var nextKey: UInt = 0
}

private let tokenLookup = OSAllocatedUnfairLock<TokenLookupState>(
    uncheckedState: .init()
)

private func lookupToken(key: UInt) -> SystemObserver.Token? {
    tokenLookup.withLockUnchecked { state in
        state.table[key]
    }
}

private func unregisterToken(key: UInt) {
    tokenLookup.withLockUnchecked { state in
        _ = state.table.removeValue(forKey: key)
    }
}

// MARK: - SystemObserver

public actor SystemObserver: Observer, Sendable {
    // MARK: Types

    // Token represents a single active notification subscription.
    // Its integer key is registered in the global tokenLookup table and passed
    // as the refCon to AXObserverAddNotification. The key is unregistered in
    // remove(token:) or stop() before the token is freed.
    fileprivate final class Token: Hashable, @unchecked Sendable {
        static func == (lhs: Token, rhs: Token) -> Bool {
            lhs === rhs
        }

        let element: SystemElement
        let notification: NSAccessibility.Notification
        let stream: AsyncThrowingStream<ObserverNotification<ObserverElement>, any Error>
        let continuation: AsyncThrowingStream<ObserverNotification<ObserverElement>, any Error>.Continuation
        // Integer key registered in the global lookup table.
        // Passed as refCon bit-pattern; never a heap pointer.
        let key: UInt

        init(
            element: SystemElement,
            notification: NSAccessibility.Notification,
            key: UInt
        ) {
            self.element = element
            self.notification = notification
            let (stream, continuation) = AsyncThrowingStream<ObserverNotification<ObserverElement>, any Error>.makeStream()
            self.stream = stream
            self.continuation = continuation
            self.key = key
        }

        deinit {
            continuation.finish()
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self))
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

    // MARK: Init

    public let processIdentifier: pid_t

    public init(processIdentifier: pid_t,
                executor: RunLoopExecutor) throws {
        unownedExecutor = executor.asUnownedSerialExecutor()
        self.processIdentifier = processIdentifier
    }

    // MARK: State

    private let state: OSAllocatedUnfairLock<State> = .init(uncheckedState: .init())

    // MARK: Schedule

    public func start() async throws {
        try state.withLockUnchecked { state in
            guard state.observer == nil else { return }
            let observer = try promoteAXObserverErrorToObserverErrorOnThrow {
                try AX.Observer(
                    pid: processIdentifier,
                    callback: observer_callback
                )
            }
            state = .init(observer: observer)
            observer.schedule()
        }
    }

    public func stop() throws {
        let oldState = state.withLockUnchecked { state in
            let old = state
            state = .init()
            return old
        }
        oldState.observer?.unschedule()
        for token in oldState.tokens {
            unregisterToken(key: token.key)
        }
    }

    public func stream(
        element: SystemElement,
        notification: NSAccessibility.Notification
    ) async throws -> any AsyncThrowingSendableSequence<ObserverNotification<SystemElement>> {
        try state.withLockUnchecked { state in
            guard let observer = state.observer else {
                throw ObserverError.failure
            }
            // Allocate a key first so Token.init can receive it as a let.
            let key = tokenLookup.withLockUnchecked { s -> UInt in
                let k = s.nextKey
                s.nextKey &+= 1
                return k
            }
            let token = Token(
                element: element,
                notification: notification,
                key: key
            )
            // Store the token in the lookup table. The key (a UInt bit-cast to
            // UnsafeMutableRawPointer) is passed as the refCon — not heap memory.
            tokenLookup.withLockUnchecked { s in
                s.table[key] = token
            }
            do {
                try promoteAXObserverErrorToObserverErrorOnThrow {
                    try observer.add(
                        element: element.element,
                        notification: notification,
                        context: UnsafeMutableRawPointer(bitPattern: key)
                    )
                }
            } catch {
                // Registration failed — remove the key we already inserted.
                unregisterToken(key: key)
                throw error
            }
            state.tokens.insert(token)
            token.continuation.onTermination = { @Sendable [weak self, weak token] _ in
                guard let self, let token else { return }
                Task {
                    await self.remove(token: token)
                }
            }
            return token.stream
        }
    }

    private func remove(token: Token) {
        state.withLockUnchecked { state in
            guard state.tokens.contains(token) else { return }
            unregisterToken(key: token.key)
            if let observer = state.observer {
                try? promoteAXObserverErrorToObserverErrorOnThrow {
                    try observer.remove(
                        element: token.element.element,
                        notification: token.notification
                    )
                }
            }
            state.tokens.remove(token)
        }
    }
}

extension SystemObserver {
    fileprivate struct State {
        var observer: AX.Observer?
        var tokens: Set<Token> = []
    }
}

// MARK: Callback

// observer_callback fires on the CFRunLoop the AXObserver was scheduled on.
// The refCon is a UInt key bit-cast to UnsafeMutableRawPointer — not a heap
// pointer. lookupToken(key:) returns nil for any key that has been unregistered,
// making stale callbacks (queued before unschedule/remove) safely no-ops.
func observer_callback(
    _ observer: AXObserver,
    _ uiElement: AXUIElement,
    _ name: CFString,
    _ info: CFDictionary?,
    _ refCon: UnsafeMutableRawPointer?
) {
    guard let refCon else { return }
    let key = UInt(bitPattern: refCon)
    guard let token = lookupToken(key: key) else { return }
    token.yield(
        element: SystemElement(element: uiElement as UIElement),
        notification: name as NSAccessibility.Notification,
        info: SystemObserverUserInfoRepackager.repackage(dictionary: info)
    )
}
