//
//  ScancodeObserver.swift
//
//  Copyright © 2018-2020 Doug Russell. All rights reserved.
//

import Foundation
import IOKit.hid

public class ScancodeObserver {
    private var hidManager: IOHIDManager?
    private func inputValue(scancode: Int) -> [String:Int] {
        return [
            kIOHIDElementUsageMinKey: scancode,
            kIOHIDElementUsageMaxKey: scancode,
        ]
    }
    private func deviceMatching(usagePage: Int,
                                usage: Int) -> [String:Int] {
        return [
            kIOHIDDeviceUsagePageKey: usagePage,
            kIOHIDDeviceUsageKey: usage,
        ]
    }
    public func enable() throws {
        guard hidManager == nil else {
            return
        }
        let hidManager = IOHIDManager.manager()
        hidManager.setInputValue(matching: inputValue(scancode: scancode))
        hidManager.setDevice(matchingCriteria: deviceMatching(usagePage: kHIDPage_GenericDesktop,
                                                              usage: kHIDUsage_GD_Keyboard))
        hidManager.registerInputValue(callback: scancodeObserverIOValueCallback,
                                      context: Unmanaged<ScancodeObserver>.passUnretained(self).toOpaque())
        hidManager.schedule(on: runLoop,
                            in: mode)
        do {
            try hidManager.open()
        } catch {
            hidManager.unschedule()
            throw error
        }
        self.hidManager = hidManager
    }
    public func disable() throws {
        guard let hidManager = hidManager else {
            return
        }
        hidManager.unschedule()
        try hidManager.close()
        self.hidManager = nil
    }
    fileprivate func handle(value: IOHIDValue) {
        let element = value.element
        let scancode = element.usage
        guard self.scancode == scancode else {
            return
        }
        if let handle = handle {
            if value.integerValue > 0 {
                handle(.down)
            } else {
                handle(.up)
            }
        }
    }
    public enum Value {
        case up
        case down
    }
    public var handle: ((_ valueChanged: Value) -> Void)?
    private let scancode: Int
    private let runLoop: CFRunLoop
    private let mode: CFRunLoopMode
    public init(scancode: Int,
                runLoop: CFRunLoop = CFRunLoopGetMain(),
                mode: CFRunLoopMode = .defaultMode) {
        self.scancode = scancode
        self.runLoop = runLoop
        self.mode = mode
    }
}

private func scancodeObserverIOValueCallback(_ context: UnsafeMutableRawPointer?,
                                             _ returnValue: IOReturn,
                                             _ sender: UnsafeMutableRawPointer?,
                                             _ value: IOHIDValue) {
    guard let context = context else {
        return
    }
    Unmanaged<ScancodeObserver>
        .fromOpaque(context)
        .takeUnretainedValue()
        .handle(value: value)
}
