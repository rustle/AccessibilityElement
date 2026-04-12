//
//  ApplicationObserver.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AppKit
import Asynchrone

public actor ApplicationObserver<ObserverType: Observer>: Observer where ObserverType.ObserverElement: Hashable {
    public typealias ObserverElement = ObserverType.ObserverElement

    private let observer: ObserverType
    private var streams: [Key:any AsyncThrowingSendableSequence<ObserverNotification<ObserverElement>>] = [:]

    public init(observer: ObserverType) {
        self.observer = observer
    }

    public func start() async throws {
        try await observer.start()
    }

    public func stop() async throws {
        try await observer.stop()
    }

    public func stream(
        element: ObserverType.ObserverElement,
        notification: NSAccessibility.Notification
    ) async throws -> any AsyncThrowingSendableSequence<ObserverNotification<ObserverElement>> {
        let key = Key(
            element: element,
            notification: notification
        )
        if let stream = streams[key] {
            return stream
        } else {
            let stream = try await observer.stream(
                element: element,
                notification: notification
            )
            streams[key] = stream
            return stream
        }
    }
}

extension ApplicationObserver {
    fileprivate struct Key: Hashable {
        let element: ObserverElement
        let notification: NSAccessibility.Notification
    }
}
