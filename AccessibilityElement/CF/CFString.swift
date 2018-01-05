//
//  CFString.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public extension CFString {
    public static var typeID: CFTypeID {
        return CFStringGetTypeID()
    }
}
