//
//  Runner.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa
import Signals

public enum Running {
    case stopped
    case started
}

public protocol Runner {
    var runningSignal: Signal<Running> { get }
    var running: Running { get }
}
