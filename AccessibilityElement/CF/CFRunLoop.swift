//
//  CFRunLoop.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public extension CFRunLoop {
    public static var typeID: CFTypeID {
        return CFRunLoopGetTypeID()
    }
    public static var main: CFRunLoop {
        return CFRunLoopGetMain()
    }
    public static var current: CFRunLoop {
        return CFRunLoopGetCurrent()
    }
    public static func run() {
        CFRunLoopRun()
    }
    public func add(source: CFRunLoopSource, mode: CFRunLoopMode = .defaultMode) {
        CFRunLoopAddSource(self, source, mode)
    }
    public func remove(source: CFRunLoopSource, mode: CFRunLoopMode = .defaultMode) {
        CFRunLoopRemoveSource(self, source, mode)
    }
    public func perform(mode: CFRunLoopMode = .defaultMode, block: @escaping () -> Void) {
        CFRunLoopPerformBlock(self, mode.rawValue, block)
    }
}
