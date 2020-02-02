//
//  IOHID.swift
//
//  Copyright © 2018-2020 Doug Russell. All rights reserved.
//

import Foundation
import IOKit.hid

public extension Dictionary {
    func map<MappedKey, MappedValue>(_ transform: ((key: Key, value: Value)) throws -> (key: MappedKey, value: MappedValue)) rethrows -> [MappedKey:MappedValue] {
        return try reduce(into: [MappedKey:MappedValue](minimumCapacity: self.count)) { result, pair in
            let mappedPair = try transform(pair)
            result[mappedPair.key] = mappedPair.value
        }
    }
}

extension IOHIDManager {
    static func manager(options: IOOptionBits = IOOptionBits()) -> IOHIDManager {
        return IOHIDManagerCreate(kCFAllocatorDefault,
                                  options)
    }
    func setInputValue(matching: [String:Int]) {
        IOHIDManagerSetInputValueMatching(self,
                                          matching.map { ($0.key as NSString, $0.value as NSNumber) } as CFDictionary)
    }
    func setDevice(matchingCriteria: [String:Int]) {
        IOHIDManagerSetDeviceMatching(self,
                                      matchingCriteria.map { ($0.key as NSString, $0.value as NSNumber) } as CFDictionary)
    }
    func setDevice(matchingCriterias: [[String:Int]]) {
        let mapped: [[NSString:NSNumber]] = matchingCriterias.map {
            $0.map { ($0.key as NSString, $0.value as NSNumber) }
        }
        IOHIDManagerSetDeviceMatchingMultiple(self,
                                              mapped as CFArray)
    }
    func registerInputValue(callback: IOHIDValueCallback?,
                            context: UnsafeMutableRawPointer?) {
        IOHIDManagerRegisterInputValueCallback(self,
                                               callback,
                                               context)
    }
    func schedule(on runloop: CFRunLoop = CFRunLoopGetMain(),
                  in mode: CFRunLoopMode = .defaultMode) {
        IOHIDManagerScheduleWithRunLoop(self,
                                        runloop,
                                        mode.rawValue)
    }
    func unschedule(on runloop: CFRunLoop = CFRunLoopGetMain(),
                    in mode: CFRunLoopMode = .defaultMode) {
        IOHIDManagerUnscheduleFromRunLoop(self,
                                          runloop,
                                          mode.rawValue)
    }
    enum IOReturnError : Error {
        case unsuccessful(IOReturn)
    }
    func open(options: IOOptionBits = IOOptionBits()) throws {
        let result = IOHIDManagerOpen(self,
                                      options)
        guard result == kIOReturnSuccess else {
            throw IOReturnError.unsuccessful(result)
        }
    }
    func close(options: IOOptionBits = IOOptionBits()) throws {
        let result = IOHIDManagerClose(self,
                                       options)
        guard result == kIOReturnSuccess else {
            throw IOReturnError.unsuccessful(result)
        }
    }
    var devices: Set<IOHIDDevice> {
        guard let d = IOHIDManagerCopyDevices(self) else {
            return Set()
        }
        guard let devices = d as? Set<IOHIDDevice> else {
            return Set()
        }
        return devices
    }
}

extension IOHIDValue {
    var element: IOHIDElement {
        return IOHIDValueGetElement(self)
    }
    var integerValue: Int {
        return IOHIDValueGetIntegerValue(self)
    }
}

extension IOHIDElement {
    static var typeID: CFTypeID {
        return IOHIDElementGetTypeID()
    }
    var usage: Int {
        return Int(IOHIDElementGetUsage(self))
    }
    var usagePage: Int {
        return Int(IOHIDElementGetUsagePage(self))
    }
}

extension IOHIDDevice {
    static var typeID: CFTypeID {
        return IOHIDDeviceGetTypeID()
    }
}
