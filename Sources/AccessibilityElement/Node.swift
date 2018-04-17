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

#if swift(>=4.1)
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
#else
extension Node where ElementType : Hashable {
    public var hashValue: Int {
        return _element.hashValue
    }
}
extension Node where ElementType : Equatable {
    public static func ==(lhs: Node<ElementType>, rhs: Node<ElementType>) -> Bool {
        return lhs._element == rhs._element
    }
    public static func !=(lhs: Node<ElementType>, rhs: Node<ElementType>) -> Bool {
        return lhs._element == rhs._element
    }
}
public struct HashableNode<ElementType> : Hashable, TreeElement where ElementType : Element {
    public let node: Node<ElementType>
    public init(node: Node<ElementType>) {
        self.node = node
    }
    public var hashValue: Int {
        return node._element.hashValue
    }
    public static func ==(lhs: HashableNode<ElementType>, rhs: HashableNode<ElementType>) -> Bool {
        return lhs.node._element == rhs.node._element
    }
    public func up() throws -> HashableNode<ElementType> {
        return HashableNode(node: try node.up())
    }
    public func down() throws -> [HashableNode<ElementType>] {
        return try node.down().map {
            HashableNode(node: $0)
        }
    }
}
#endif

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
