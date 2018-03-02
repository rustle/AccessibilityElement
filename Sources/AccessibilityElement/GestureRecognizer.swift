//
//  GestureRecognizer.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

// Stub for future work

open class GestureRecognizer {
    public enum State {
        case possible
        case began
        case changed
        case cancelled
        case failed
        case recognized
    }
    public init() {
        
    }
    open var state: State = .possible
    open func reset() {
        
    }
    open func touchesBegan(event: Any) {
        
    }
    open func touchesMoved(event: Any) {
        
    }
    open func touchesEnded(event: Any) {
        
    }
    open func touchesCancelled(event: Any) {
        
    }
}
