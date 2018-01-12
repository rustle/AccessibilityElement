//
//  Bundle.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public protocol AccessibilityBundle : class {
    func load() throws
    init()
}
