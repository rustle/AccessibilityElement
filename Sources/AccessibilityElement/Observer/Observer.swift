//
//  Observer.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AppKit

public typealias AsyncThrowingSendableSequence<V: Sendable> = AsyncSequence<V, any Error> & Sendable

public protocol Observer: Sendable {
    associatedtype ObserverElement: Element

    func start() async throws
    func stop() async throws

    func stream(
        element: ObserverElement,
        notification: NSAccessibility.Notification
    ) async throws -> any AsyncThrowingSendableSequence<ObserverNotification<ObserverElement>>
}
