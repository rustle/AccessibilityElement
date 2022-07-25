//
//  MockObserver.swift
//
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

import AccessibilityElement
import Cocoa

public struct MockObserver: Observer {
    public typealias ObserverElement = MockElement
    public struct ObserverToken: Hashable {
        public static func ==(
            lhs: ObserverToken,
            rhs: ObserverToken
        ) -> Bool {
            lhs.uuid == rhs.uuid
        }
        private let uuid = UUID()
        private let element: MockElement
        private let notification: NSAccessibility.Notification
        private let handler: ObserverHandler
        fileprivate init(
            element: MockElement,
            notification: NSAccessibility.Notification,
            handler: @escaping ObserverHandler
        ) {
            self.element = element
            self.notification = notification
            self.handler = handler
        }
        public func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
        }
    }
    public func start() async throws {}
    public func stop() async throws {}
    public func add(
        element: MockElement,
        notification: NSAccessibility.Notification,
        handler: @escaping ObserverHandler
    ) async throws -> ObserverToken {
        ObserverToken(
            element: element,
            notification: notification,
            handler: handler
        )
    }
    public func remove(token: ObserverToken) async throws {
        
    }
}
