//
//  Debug.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public protocol CustomDebugDictionaryConvertible {
    var debugInfo: [String:CustomDebugStringConvertible] { get }
}
