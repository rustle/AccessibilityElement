//
//  CapsLock.swift
//
//  Copyright © 2018-2020 Doug Russell. All rights reserved.
//

import Foundation
import IOKit

public class CapsLock {
    public enum KeyState {
        case up
        case down
    }
    public enum LockState {
        case on
        case off
    }
    public var doubleTapToEnableCapsLock: Bool = true
    public var doubleTapToEnableCapsLockThreshold: Double = 0.5
    public private(set) var keyState: KeyState = .up {
        didSet {
            switch keyState {
            case .up:
                let now = CFAbsoluteTimeGetCurrent()
                if doubleTapToEnableCapsLock {
                    if now - lastUp < doubleTapToEnableCapsLockThreshold {
                        _systemState.capsLocked = true
                    } else {
                        _systemState.capsLocked = false
                    }
                } else {
                    _systemState.capsLocked = false
                }
                lastUp = now
                break
            case .down:
                break
            }
        }
    }
    public var systemState: LockState {
        get {
            if _systemState.capsLocked {
                return .on
            } else {
                return .off
            }
        }
        set {
            switch newValue {
            case .on:
                _systemState.capsLocked = true
            case .off:
                _systemState.capsLocked = false
            }
        }
    }
    private var lastUp = CFAbsoluteTimeGetCurrent()
    private let scancodeObserver = ScancodeObserver(scancode: kHIDUsage_KeyboardCapsLock)
    private let _systemState: CapsLockSystemState
    public init() throws {
        _systemState = try CapsLockSystemState()
        scancodeObserver.handle = { [weak self] value in
            switch value {
            case .up:
                self?.keyState = .up
            case .down:
                self?.keyState = .down
            }
        }
        try scancodeObserver.enable()
    }
    deinit {
        do {
            try scancodeObserver.disable()
        } catch {}
    }
}
