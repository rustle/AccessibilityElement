//
//  SystemObserver.swift
//
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

import AppKit
import Asynchrone
import Atomics
import AX
import Cocoa
import os

public actor SystemObserver: Observer, Sendable {
    // MARK: Types

    fileprivate final class Token: Hashable {
        static func == (
            lhs: Token,
            rhs: Token
        ) -> Bool {
            lhs.context == rhs.context
        }
        let context: Int
        let element: SystemElement
        let notification: NSAccessibility.Notification
        let callback: AsyncStreamer<ObserverNotification<ObserverElement>> = .init()
        func hash(into hasher: inout Hasher) {
            hasher.combine(context)
        }
        init(
            context: Int,
            element: SystemElement,
            notification: NSAccessibility.Notification
        ) {
            self.context = context
            self.element = element
            self.notification = notification
        }
        deinit {
            callback.continuation.finish()
        }
    }

    fileprivate struct ObserverCallbackPayload: Sendable {
        let element: ObserverElement
        let notification: NSAccessibility.Notification
        let info: [String: Sendable]
        let context: Int
    }

    public typealias ObserverElement = SystemElement

    // MARK: Contexts

    private static let contextGenerator = ManagedAtomic<Int32>(1)
    private static func next() -> Int {
        Int(contextGenerator.wrappingIncrementThenLoad(ordering: .relaxed))
    }

    // MARK: Init

    public let processIdentifier: pid_t
    public init(processIdentifier: pid_t) throws {
        let executor = RunLoopExecutor()
        self.executor = executor
        unownedExecutor = executor.asUnownedSerialExecutor()
        executor.start()
        self.processIdentifier = processIdentifier
    }

    // MARK: Executor

    private nonisolated let executor: any SerialExecutor
    public nonisolated let unownedExecutor: UnownedSerialExecutor

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
            ObserverLookup.shared
                .setObserver(
                    self,
                    for: observer.observer
                )
            let streamer = AsyncStreamer<ObserverCallbackPayload>()
            let task = Task(priority: .userInitiated) { [weak self] in
                for await payload in streamer.stream {
                    guard !Task.isCancelled else { break }
                    guard let self else { break }
                    await self.handle(payload: payload)
                }
            }
            state = .init(
                observer: observer,
                callback: streamer,
                callbackTask: task
            )
            observer.schedule()
        }
    }

    public func stop() throws {
        let oldState = state.withLockUnchecked { state in
            if let observer = state.observer {
                ObserverLookup.shared
                    .setObserver(
                        self,
                        for: observer.observer
                    )
            }
            let oldState = state
            state = .init()
            return oldState
        }
        oldState.observer?.unschedule()
        oldState.callback?.continuation.finish()
        oldState.callbackTask?.cancel()
    }

    public func stream(
        element: ObserverElement,
        notification: NSAccessibility.Notification
    ) async throws -> ObserverAsyncSequence {
        try state.withLockUnchecked { state in
            guard let observer = state.observer else {
                throw ObserverError.failure
            }
            let context = Self.next()
            let token = Token(
                context: context,
                element: element,
                notification: notification
            )
            try promoteAXObserverErrorToObserverErrorOnThrow {
                try observer.add(
                    element: element.element,
                    notification: notification,
                    context: UnsafeMutableRawPointer(bitPattern: context)
                )
            }
            state.contextTokenMap[context] = token
            token.callback.continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                Task {
                    do {
                        try await self.remove(
                            context: context,
                            element: element.element,
                            notification: notification
                        )
                    } catch {}
                }
            }
            return token.callback.stream.shared()
        }
    }

    private func remove(
        context: Int,
        element: UIElement,
        notification: NSAccessibility.Notification
    ) throws {
        try state.withLockUnchecked { state in
            guard state.contextTokenMap.removeValue(forKey: context) != nil else { return }
            guard let observer = state.observer else { return }
            try promoteAXObserverErrorToObserverErrorOnThrow {
                try observer.remove(
                    element: element,
                    notification: notification
                )
            }
        }
    }

    fileprivate func handle(payload: ObserverCallbackPayload) {
        let token = state.withLockUnchecked { state in
            state.contextTokenMap[payload.context]
        }
        guard let token else { return }
        token
            .callback
            .continuation
            .yield(
                .init(
                    observedElement: token.element,
                    element: payload.element,
                    name: token.notification,
                    info: payload.info
                )
            )
    }

    nonisolated fileprivate func yield(
        element: SystemElement,
        notification: NSAccessibility.Notification,
        info: [String: Sendable],
        context: Int
    ) {
        let continuation = state.withLock {
            $0.callback?.continuation
        }
        continuation?.yield(
            .init(
                element: element,
                notification: notification,
                info: info,
                context: context
            )
        )
    }
}

extension SystemObserver {
    fileprivate struct State {
        var observer: AX.Observer?
        var callback: AsyncStreamer<ObserverCallbackPayload>?
        var callbackTask: Task<(), Never>?
        var contextTokenMap: [Int:Token] = [:]
    }
}

fileprivate final class ObserverLookup {
    fileprivate static let shared = ObserverLookup()
    private let observers = NSMapTable<AXObserver, SystemObserver>.weakToWeakObjects()
    private init() {}
    func get(context: AXObserver) -> SystemObserver? {
        observers
            .object(forKey: context)
    }
    func setObserver(
        _ systemObserver: SystemObserver,
        for context: AXObserver
    ) {
        observers.setObject(
            systemObserver,
            forKey: context
        )
    }
    func removeObserver(for context: AXObserver) {
        observers.removeObject(forKey: context)
    }
}

func observer_callback(
    _ observer: AXObserver,
    _ uiElement: AXUIElement,
    _ name: CFString,
    _ info: CFDictionary?,
    _ refCon: UnsafeMutableRawPointer?
) {
    guard let refCon else { return }
    guard let systemObserver = ObserverLookup.shared.get(context: observer) else { return }
    systemObserver.yield(
        element: SystemElement(element: uiElement as UIElement),
        notification: name as NSAccessibility.Notification,
        info: SystemObserverUserInfoRepackager.repackage(dictionary: info),
        context: Int(bitPattern: refCon)
    )
}
