//
//  CapsLock.swift
//
//  Copyright © 2018-2020 Doug Russell. All rights reserved.
//

import Foundation
import IOKit

public class CapsLockSystemState {
    public enum Error : Swift.Error {
        case ioError
    }
    public var capsLocked: Bool {
        get {
            var state = false
            IOHIDGetModifierLockState(connect, Int32(kIOHIDCapsLockState), &state);
            return state
        }
        set {
            IOHIDSetModifierLockState(connect, Int32(kIOHIDCapsLockState), newValue)
        }
    }
    public func toggle() {
        capsLocked.toggle()
    }
    private let connect: io_connect_t
    public init() throws {
        let matching = IOServiceMatching(kIOHIDSystemClass)
        let service = IOServiceGetMatchingService(kIOMasterPortDefault, matching)
        if service == 0 {
            throw CapsLockSystemState.Error.ioError
        }
        var connect: io_connect_t = 0
        let result = IOServiceOpen(service, mach_task_self_, UInt32(kIOHIDParamConnectType), &connect)
        IOObjectRelease(service)
        guard result == KERN_SUCCESS else {
            throw CapsLockSystemState.Error.ioError
        }
        self.connect = connect
    }
    deinit {
        IOServiceClose(connect)
    }
}
