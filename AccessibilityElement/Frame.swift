//
//  Frame.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct Frame {
    public struct Point {
        public var x: Double
        public var y: Double
        public init(point: CGPoint) {
            self.x = Double(point.x)
            self.y = Double(point.y)
        }
    }
    public struct Size {
        public var width: Double
        public var height: Double
        public init(size: CGSize) {
            self.width = Double(size.width)
            self.height = Double(size.height)
        }
    }
    public var origin: Point
    public var size: Size
    public init(rect: CGRect) {
        self.origin = Point(point: rect.origin)
        self.size = Size(size: rect.size)
    }
    public mutating func inset(x: Double, y: Double) {
        origin.x += x
        origin.y += y
        size.width -= x * 2.0
        size.height -= y * 2.0
    }
}
