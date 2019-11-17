//
//  Runner.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa
import Combine

public enum Running {
    case stopped
    case started
}

public protocol Runner {
    var running: Running { get }
}
