//
//  Tap.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public typealias TapHandler = (inout Tap.Event) -> Void

public class Tap {
    public static func eventMask(eventTypes: [CGEventType]) ->CGEventMask {
        var mask = CGEventMask(0)
        for eventType in eventTypes {
            mask |= (1<<eventType.rawValue)
        }
        return mask
    }
    public struct Event {
        public var proxy: CGEventTapProxy
        public var eventType: CGEventType
        public var cgEvent: CGEvent?
        public var keyCode: CGKeyCode {
            return CGKeyCode(cgEvent?.getIntegerValueField(.keyboardEventKeycode) ?? 0)
        }
        public var characters: String? {
            guard let event = cgEvent else {
                return nil
            }
            var count = 0
            event.keyboardGetUnicodeString(maxStringLength: 0,
                                           actualStringLength: &count,
                                           unicodeString: nil)
            guard count > 0 else {
                return nil
            }
            let bufferCapacity = count * MemoryLayout<UniChar>.size
            let characters = UnsafeMutablePointer<UniChar>.allocate(capacity: bufferCapacity)
            event.keyboardGetUnicodeString(maxStringLength: count,
                                           actualStringLength: &count,
                                           unicodeString: characters)
            let value = String(utf16CodeUnits: characters,
                               count: count)
            characters.deallocate()
            return value
        }
    }
    public enum Placement {
        case head
        case tail
    }
    public enum Configuration : Int, Codable {
        case active
        case passive
    }
    private var tap: CFMachPort! = nil
    public enum Error : Swift.Error {
        case couldNotCreateTap
    }
    public var enabled: Bool {
        get {
            CGEvent.tapIsEnabled(tap: tap)
        }
        set {
            CGEvent.tapEnable(tap: tap,
                              enable: newValue)
        }
    }
    fileprivate let handler: TapHandler
    public init(placement: Placement = .head,
                configuration: Configuration = .passive,
                eventsOfInterest: CGEventMask,
                handler: @escaping TapHandler) throws {
        let cgPlacement: CGEventTapPlacement
        switch placement {
        case .head:
            cgPlacement = .headInsertEventTap
        case .tail:
            cgPlacement = .tailAppendEventTap
        }
        let options: CGEventTapOptions
        switch configuration {
        case .active:
            options = .defaultTap
        case .passive:
            options = .listenOnly
        }
        self.handler = handler
        guard let tap = CGEvent.tapCreate(tap: .cghidEventTap,
                                          place: cgPlacement,
                                          options: options,
                                          eventsOfInterest: eventsOfInterest,
                                          callback: callback,
                                          userInfo: Unmanaged.passUnretained(self).toOpaque()) else {
            throw Tap.Error.couldNotCreateTap
        }
        self.tap = tap
    }
    public func runLoopSource(order: Int) -> CFRunLoopSource {
        CFMachPortCreateRunLoopSource(kCFAllocatorDefault,
                                      tap,
                                      0)
    }
}

private func callback(_ proxy: CGEventTapProxy,
                      _ eventType: CGEventType,
                      _ event: CGEvent,
                      _ info: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    guard let info = info else {
        return Unmanaged.passUnretained(event)
    }
    let tap = Unmanaged<Tap>.fromOpaque(info).takeUnretainedValue()
    var tapEvent = Tap.Event(proxy: proxy,
                             eventType: eventType,
                             cgEvent: event)
    tap.handler(&tapEvent)
    guard let outEvent = tapEvent.cgEvent else {
        return nil
    }
    return Unmanaged.passUnretained(outEvent)
}
