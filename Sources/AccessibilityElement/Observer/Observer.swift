//
//  Observer.swift
//
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

import Cocoa

public protocol Observer {
    associatedtype ObserverElement: Element
    associatedtype ObserverToken: Hashable
    typealias ObserverHandler = (ObserverElement, [String:Any]) async -> Void

    func start() async throws
    func stop() async throws

    func add(element: ObserverElement,
             notification: NSAccessibility.Notification,
             handler: @escaping ObserverHandler) async throws -> ObserverToken

    func remove(token: ObserverToken) async throws
}
