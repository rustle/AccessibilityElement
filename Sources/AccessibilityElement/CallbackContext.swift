//
//  CallbackContext.swift
//
//  Copyright © 2020 Doug Russell. All rights reserved.
//

import Foundation

public class CallbackContext<T> {
    public let unsafeReference: UnsafeMutablePointer<T>
    public init(_ reference: T) {
        unsafeReference = UnsafeMutablePointer<T>.allocate(capacity: 1)
        unsafeReference.initialize(to: reference)
    }
    deinit {
        unsafeReference.deinitialize(count: 1)
        unsafeReference.deallocate()
    }
}
