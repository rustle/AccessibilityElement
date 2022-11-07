//
//  SystemObserverExample.swift
//
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

import AccessibilityElement
import AX
import Cocoa

guard isTrusted(promptIfNeeded: true) else {
    // If you already added ObserverExample
    // to trusted apps, it's likely that changing the
    // binary has invalidated it's AX API access.
    // You can usually reauthorize it by unchecking and
    // rechecking it's entry in the list of apps
    // with AX API access in System Preferences.
    print("Not Trusted")
    exit(1)
}

fileprivate func run() -> Never {
    autoreleasepool {
        Timer.scheduledTimer(withTimeInterval: Date.distantFuture.timeIntervalSince1970,
                             repeats: true) { _ in }
        while true {
            autoreleasepool {
                _ = CFRunLoopRunInMode(CFRunLoopMode.defaultMode,
                                       1.0,
                                       true)
            }
        }
    }
}

Task(priority: .userInitiated) {
    let host = SystemObserverHost()
    let stream = try await host.start()
    for try await notification in stream {
        debugPrint(notification)
    }
}

run()
