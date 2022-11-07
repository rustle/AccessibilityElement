//
//  MockObserver.swift
//
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

import AccessibilityElement
import Cocoa

public struct MockObserver: Observer {
    public typealias ObserverElement = MockElement
    public func start() async throws {}
    public func stop() async throws {}
    public func stream(
        element: MockElement,
        notification: NSAccessibility.Notification
    ) async throws -> ObserverAsyncSequence {
        let stream = AsyncStream<ObserverNotification<ObserverElement>> { _ in
            
        }
        return stream.shared()
    }

}
