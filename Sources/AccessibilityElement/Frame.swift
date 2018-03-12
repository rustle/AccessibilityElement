//
//  Frame.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

/// Geometric region in screen coordinates with origin in bottom left corner of screen
public struct Frame {
    /// Geometric point in screen coordinates with origin in bottom left corner of screen
    public struct Point {
        /// Horizontal axis of point
        public var x: Double
        /// Vertical axis of point
        public var y: Double
        public init(point: CGPoint) {
            self.x = Double(point.x)
            self.y = Double(point.y)
        }
    }
    /// Geometric area in screen coordinates
    public struct Size {
        /// Width of region
        public var width: Double
        /// Height of region
        public var height: Double
        ///
        public init(size: CGSize) {
            self.width = Double(size.width)
            self.height = Double(size.height)
        }
    }
    /// Bottom left corner of region
    public var origin: Point
    /// Area of region
    public var size: Size
    /// 
    public init(rect: CGRect) {
        self.origin = Point(point: rect.origin)
        self.size = Size(size: rect.size)
    }
    ///
    public mutating func inset(x: Double, y: Double) {
        origin.x += x
        origin.y += y
        size.width -= x * 2.0
        size.height -= y * 2.0
    }
}
