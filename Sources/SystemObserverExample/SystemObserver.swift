//
//  SystemObserver.swift
//
//  Copyright © 2017-2021 Doug Russell. All rights reserved.
//

import Asynchrone
import AccessibilityElement
import Cocoa

actor SystemObserverHost {
    var observer: SystemObserver?
    init() {}
    func start() async throws -> SharedAsyncSequence<AsyncStream<ObserverNotification<SystemElement>>> {
        guard let finder = NSWorkspace.shared.runningApplications.filter({ app in
            app.bundleIdentifier == "com.apple.finder"
        }).first else {
            print(NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier))
            exit(1)
        }
        let element = try SystemElement.application(processIdentifier: finder.processIdentifier)
        let observer = try SystemObserver(processIdentifier: finder.processIdentifier)
        try await observer.start()
        let stream = try await observer.stream(
            element: element,
            notification: .focusedUIElementChanged
        )
        self.observer = observer
        return stream
    }
}
