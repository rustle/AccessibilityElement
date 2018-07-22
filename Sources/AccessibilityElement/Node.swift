//
//  Node.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public protocol AnyNode {
    var element: AnyElement { get }
}

public final class Node<ElementType> : AnyNode where ElementType : AnyElement {
    public weak var parent: Node<ElementType>?
    public var children = [Node<ElementType>]()
    public var element: AnyElement {
        return _element
    }
    public var _element: ElementType
    public var role: HierarchyRole
    public init(element: ElementType, role: HierarchyRole) {
        _element = element
        self.role = role
    }
}

extension Node : Equatable where ElementType : Equatable {
    public static func ==(lhs: Node<ElementType>, rhs: Node<ElementType>) -> Bool {
        return lhs._element == rhs._element
    }
}
extension Node : Hashable where ElementType : Hashable {
    public var hashValue: Int {
        return _element.hashValue
    }
}

extension Node : TreeElement {
    public func up() throws -> Node<ElementType> {
        guard let parent = parent else {
            throw HierarchyError.noValue
        }
        return parent
    }
    public func down() throws -> [Node<ElementType>] {
        return children
    }
}

extension Node : CustomDebugStringConvertible {
    public func debugDescription(depth: Int) -> String {
        var description = ""
        for _ in 0..<depth {
            description += "\t"
        }
        if let debug = element as? CustomDebugStringConvertible {
            description += debug.debugDescription
        }
        return description
    }
    public var debugDescription: String {
        return debugDescription(depth: 0)
    }
}
