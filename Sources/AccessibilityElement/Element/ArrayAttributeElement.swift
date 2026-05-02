//
//  ArrayAttributeElement.swift
//
//  Copyright © 2026 Doug Russell. All rights reserved.
//

import AppKit

public protocol ArrayAttributeElement: Element {
    func count(attribute: NSAccessibility.Attribute) throws -> Int
    func elements(
        attribute: NSAccessibility.Attribute,
        index: Int,
        maxCount: Int
    ) throws -> [Self]
}
