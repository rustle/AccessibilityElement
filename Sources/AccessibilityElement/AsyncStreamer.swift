//
//  AsyncStreamer.swift
//  
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

struct AsyncStreamer<Element: Sendable>: Sendable {
    let stream: AsyncStream<Element>
    let continuation: AsyncStream<Element>.Continuation
    init(
        _ elementType: Element.Type = Element.self,
        bufferingPolicy limit: AsyncStream<Element>.Continuation.BufferingPolicy = .unbounded
    ) {
        var continuation: AsyncStream<Element>.Continuation!
        let stream = AsyncStream<Element> {
            continuation = $0
        }
        self.stream = stream
        self.continuation = continuation
    }
}
