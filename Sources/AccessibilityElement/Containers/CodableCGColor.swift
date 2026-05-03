//
//  CodableCGColor.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import CoreGraphics

public struct CodableCGColor: Codable, Sendable {
    public let colorSpaceName: String
    public let components: [CGFloat]

    init(colorSpaceName: String, components: [CGFloat]) {
        self.colorSpaceName = colorSpaceName
        self.components = components
    }

    public init?(color: CGColor) {
        guard
            let colorSpace = color.colorSpace,
            let name = colorSpace.name,
            let components = color.components
        else {
            return nil
        }
        colorSpaceName = name as String
        self.components = components
    }

    public var color: CGColor? {
        guard let colorSpace = CGColorSpace(name: colorSpaceName as CFString) else {
            return nil
        }
        return CGColor(colorSpace: colorSpace, components: components)
    }
}
