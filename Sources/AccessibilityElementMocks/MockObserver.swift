//
//  MockObserver.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AccessibilityElement
import AppKit
import os

// Controllable notification source for MockObserver. Continuations are created
// eagerly in makeStream(for:) so emit(_:element:info:) is always safe to call
// after the observer has been set up — no timing gap.
public final class MockNotificationSource: @unchecked Sendable {
    private let state = OSAllocatedUnfairLock<[NSAccessibility.Notification: AsyncThrowingStream<ObserverNotification<MockElement>, any Error>.Continuation]>(initialState: [:])

    public init() {}

    public func makeStream(for notification: NSAccessibility.Notification) -> AsyncThrowingStream<ObserverNotification<MockElement>, any Error> {
        let (stream, continuation) = AsyncThrowingStream<ObserverNotification<MockElement>, any Error>.makeStream()
        state.withLock { $0[notification] = continuation }
        return stream
    }

    public func emit(
        _ notification: NSAccessibility.Notification,
        element: MockElement,
        info: [String: ObserverElementInfoValue] = [:]
    ) {
        let continuation = state.withLock { $0[notification] }
        continuation?.yield(ObserverNotification(
            observedElement: element,
            element: element,
            name: notification,
            info: info
        ))
    }
}

public struct MockObserver: Observer {
    public typealias ObserverElement = MockElement
    public let source: MockNotificationSource?
    public init(source: MockNotificationSource? = nil) { self.source = source }
    public func start() async throws {}
    public func stop() async throws {}
    public func stream(
        element: MockElement,
        notification: NSAccessibility.Notification
    ) async throws -> any AsyncThrowingSendableSequence<ObserverNotification<MockElement>> {
        if let source { return source.makeStream(for: notification) }
        return AsyncThrowingStream { _ in }
    }
}
