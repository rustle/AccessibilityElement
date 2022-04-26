//
//  SystemObserver.swift
//
//  Copyright © 2017-2021 Doug Russell. All rights reserved.
//

import AccessibilityElement
import Cocoa

func setupSystemObserver() async throws -> (SystemObserver, SystemObserver.ObserverToken) {
    guard let finder = NSWorkspace.shared.runningApplications.filter({ app in
        app.bundleIdentifier == "com.apple.finder"
    }).first else {
        print(NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier))
        exit(1)
    }
    let element = try SystemElement.application(processIdentifier: finder.processIdentifier)
    let observer = try await SystemObserver(pid: finder.processIdentifier)
    try await observer.start()
    let token = try await observer.add(element: element,
                           notification: .focusedUIElementChanged) { element, userInfo in
        print(element)
        print(userInfo)
    }
    return (observer, token)
}
