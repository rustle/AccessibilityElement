//
//  ApplicationObserver.swift
//
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

import Cocoa

public actor ApplicationObserver<ObserverType: Observer>: Observer where ObserverType.ObserverElement: Hashable {
    public typealias ObserverElement = ObserverType.ObserverElement
    public typealias ObserverToken = ApplicationObserverToken

    private let observer: ObserverType
    public init(observer: ObserverType) {
        self.observer = observer
    }

    public func start() async throws {
        try await observer.start()
    }

    public func stop() async throws {
        try await observer.stop()
    }

    private var observerTokens: [ApplicationObserverKey:ObserverType.ObserverToken] = [:]
    private var tokensForToken: [ObserverType.ObserverToken:[UUID:ObserverToken]] = [:]

    public func add(
        element: ObserverElement,
        notification: NSAccessibility.Notification,
        handler: @escaping ObserverHandler
    ) async throws -> ObserverToken {
        let key = ApplicationObserverKey(
            element: element,
            notification: notification
        )
        let token = ApplicationObserverToken(
            observer: self,
            key: key,
            handler: handler
        )
        let observerToken: ObserverType.ObserverToken
        if let t = observerTokens[key]  {
            observerToken = t
        } else {
            observerToken = try await observer.add(
                element: element,
                notification: notification
            ) { [weak self] element, userInfo in
                await self?.handle(
                    key: key,
                    element: element,
                    userInfo: userInfo
                )
            }
            observerTokens[key] = observerToken
        }
        tokensForToken[observerToken, default: [:]][token.uuid] = token
        return token
    }

    public func remove(token: ObserverToken) async throws {
        try await remove(
            key: token.key,
            uuid: token.uuid
        )
    }

    fileprivate func remove(
        key: ApplicationObserverKey,
        uuid: UUID
    ) async throws {
        guard let observerToken = observerTokens[key] else { return }
        tokensForToken[observerToken]?.removeValue(forKey: uuid)
        if tokensForToken[observerToken]?.isEmpty ?? true {
            observerTokens.removeValue(forKey: key)
            try await observer.remove(token: observerToken)
        }
    }

    private func handle(
        key: ApplicationObserverKey,
        element: ObserverElement,
        userInfo: [String:Any]
    ) async {
        guard let token = observerTokens[key] else { return }
        guard let tokens = tokensForToken[token]?.values else { return }
        for token in tokens {
            await token.handler(element, userInfo)
        }
    }
}

extension ApplicationObserver {
    fileprivate struct ApplicationObserverKey: Hashable {
        let element: ObserverElement
        let notification: NSAccessibility.Notification
    }
}

extension ApplicationObserver {
    public final class ApplicationObserverToken: Hashable {
        public static func ==(
            lhs: ApplicationObserverToken,
            rhs: ApplicationObserverToken
        ) -> Bool {
            lhs.uuid == rhs.uuid
        }
        private weak var observer: ApplicationObserver?
        fileprivate let uuid = UUID()
        fileprivate let key: ApplicationObserver.ApplicationObserverKey
        fileprivate let handler: ObserverHandler
        public nonisolated func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
        }
        fileprivate init(
            observer: ApplicationObserver,
            key: ApplicationObserver.ApplicationObserverKey,
            handler: @escaping ObserverHandler
        ) {
            self.observer = observer
            self.key = key
            self.handler = handler
        }
    }
}
