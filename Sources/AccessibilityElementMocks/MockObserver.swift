//
//  MockObserver.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AccessibilityElement
import AppKit

public struct MockObserver: Observer {
    public typealias ObserverElement = MockElement
    public func start() async throws {}
    public func stop() async throws {}
    public func stream(
        element: MockElement,
        notification: NSAccessibility.Notification
    ) async throws -> any AsyncThrowingSendableSequence<ObserverNotification<MockElement>> {
        AsyncThrowingStream<ObserverNotification<MockElement>, any Error> { _ in }
    }

}
