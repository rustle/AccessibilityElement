//
//  Observer.swift
//
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

import AppKit
import Asynchrone

public protocol Observer: Sendable {
    associatedtype ObserverElement: Element
    typealias ObserverAsyncSequence = SharedAsyncSequence<AsyncStream<ObserverNotification<ObserverElement>>>

    func start() async throws
    func stop() async throws

    // Hopefully we can eventually make the return type here
    // some AsyncSequence where Element == ObserverNotification<ObserverElement>>
    func stream(
        element: ObserverElement,
        notification: NSAccessibility.Notification
    ) async throws -> ObserverAsyncSequence
}
