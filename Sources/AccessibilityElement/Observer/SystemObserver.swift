//
//  SystemObserver.swift
//
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

import Asynchrone
import Atomics
import AX
import Cocoa

public final class SystemObserver: Observer, @unchecked Sendable {
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

    fileprivate struct ObserverCallbackPayload {
        let element: ObserverElement
        let notification: NSAccessibility.Notification
        let info: [String : Any]
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
        self.processIdentifier = processIdentifier
    }

    // MARK: State

    private let state: ManagedCriticalState<State> = .init(.init())

    // MARK: Schedule

    @ObserverRunLoopActor
    public func start() async throws {
        try state.withCriticalRegion { state in
            guard state.observer == nil else { return }
            let observer = try throwsAXObserverError {
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
                    self.handle(payload: payload)
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

    @ObserverRunLoopActor
    public func stop() throws {
        let oldState = state.withCriticalRegion { state in
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
        try state.withCriticalRegion { state in
            guard let observer = state.observer else {
                throw ObserverError.failure
            }
            let context = Self.next()
            let token = Token(
                context: context,
                element: element,
                notification: notification
            )
            try throwsAXObserverError {
                try observer.add(
                    element: element.element,
                    notification: notification,
                    context: UnsafeMutableRawPointer(bitPattern: context)
                )
            }
            state.contextTokenMap[context] = token
            token.callback.continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                do {
                    try self.remove(
                        context: context,
                        element: element.element,
                        notification: notification
                    )
                } catch {}
            }
            return token.callback.stream.shared()
        }
    }

    private func remove(
        context: Int,
        element: UIElement,
        notification: NSAccessibility.Notification
    ) throws {
        try state.withCriticalRegion { state in
            guard state.contextTokenMap.removeValue(forKey: context) != nil else { return }
            guard let observer = state.observer else { return }
            try throwsAXObserverError {
                try observer.remove(
                    element: element,
                    notification: notification
                )
            }
        }
    }

    fileprivate func handle(payload: ObserverCallbackPayload) {
        let token = state.withCriticalRegion { state in
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

    fileprivate func yield(
        element: SystemElement,
        notification: NSAccessibility.Notification,
        info: [String : Any],
        context: Int
    ) {
        guard let continuation = state.withCriticalRegion({ $0.callback?.continuation }) else { return }
        continuation.yield(
            .init(
                element: element,
                notification: notification,
                info: info,
                context: context
            )
        )
    }

    private func throwsAXObserverError<T>(_ work: () throws -> T) rethrows -> T {
        do {
            return try work()
        } catch let error as AX.AXError {
            throw ObserverError(axError: error.error)
        } catch {
            throw error
        }
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
