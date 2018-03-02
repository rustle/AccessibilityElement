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
    }
    public enum Placement {
        case head
        case tail
    }
    public enum Configuration : Int, Codable {
        case active
        case passive
    }
    private let tap: CFMachPort
    private let identifier: Int
    public enum Error : Swift.Error {
        case couldNotCreateTap
    }
    public var enabled: Bool {
        get {
            return CGEvent.tapIsEnabled(tap: tap)
        }
        set {
            CGEvent.tapEnable(tap: tap, enable: newValue)
        }
    }
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
        identifier = tapState.next()
        guard let tap = CGEvent.tapCreate(tap: .cghidEventTap,
                                          place: cgPlacement,
                                          options: options,
                                          eventsOfInterest: eventsOfInterest,
                                          callback: callback,
                                          userInfo: UnsafeMutableRawPointer(bitPattern: identifier)) else {
            throw Tap.Error.couldNotCreateTap
        }
        self.tap = tap
        tapState.set(state: handler,
                     identifier: identifier)
    }
    deinit {
        tapState.remove(identifier: identifier)
    }
    public func runLoopSource(order: Int) -> CFRunLoopSource {
        return CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
    }
}

fileprivate let tapState = SimpleState<TapHandler>()

fileprivate func callback(_ proxy: CGEventTapProxy,
                          _ eventType: CGEventType,
                          _ event: CGEvent,
                          _ info: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    let identifier = unsafeBitCast(info, to: Int.self)
    guard let handler = tapState.state(identifier: identifier) else {
        return Unmanaged.passUnretained(event)
    }
    var tapEvent = Tap.Event(proxy: proxy, eventType: eventType, cgEvent: event)
    handler(&tapEvent)
    guard let outEvent = tapEvent.cgEvent else {
        return nil
    }
    return Unmanaged.passUnretained(outEvent)
}
