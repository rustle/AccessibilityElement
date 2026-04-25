//
//  ArrayAttributeView.swift
//
//  Copyright © 2026 Doug Russell. All rights reserved.
//

import AppKit

/// A lazy view over an array-valued accessibility attribute.
///
/// Backed by `UIElement.count(attribute:)` and `UIElement.values(attribute:index:maxCount:)`,
/// allowing efficient subrange access for attributes with large numbers of values
/// (e.g. a table with thousands of rows).
public struct ArrayAttributeView<E: Element>: Sendable {
    private let _count: @Sendable () throws -> Int
    private let _elements: @Sendable (Int, Int) throws -> [E]

    public init(
        count: @escaping @Sendable () throws -> Int,
        elements: @escaping @Sendable (Int, Int) throws -> [E]
    ) {
        self._count = count
        self._elements = elements
    }

    /// The total number of values for this attribute.
    public func count() throws -> Int {
        try _count()
    }

    /// Returns up to `maxCount` elements starting at `index`.
    public func elements(
        index: Int,
        maxCount: Int
    ) throws -> [E] {
        try _elements(index, maxCount)
    }
}
