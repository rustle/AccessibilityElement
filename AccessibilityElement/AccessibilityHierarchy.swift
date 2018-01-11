//
//  AccessibilityHierarchy.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import os.log

public enum HierarchyRole {
    case skip
    case container
    case include
}

public enum HierarchyError : Error {
    case noValue
}

public final class Node<ElementType> : TreeElement, Hashable where ElementType : _AccessibilityElement {
    public weak var parent: Node<ElementType>?
    public var children = [Node<ElementType>]()
    public func up() throws -> Node<ElementType> {
        guard let parent = parent else {
            throw HierarchyError.noValue
        }
        return parent
    }
    public func down() throws -> [Node<ElementType>] {
        return children
    }
    public var hashValue: Int {
        return element.hashValue
    }
    public var element: ElementType
    public var role: HierarchyRole
    public init(element: ElementType, role: HierarchyRole) {
        self.element = element
        self.role = role
    }
    public static func ==(lhs: Node<ElementType>, rhs: Node<ElementType>) -> Bool {
        return lhs.element == rhs.element
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

public protocol Hierarchy {
    associatedtype ElementType : _AccessibilityElement
    func classify(_ element: ElementType) -> HierarchyRole
    func buildHierarchy(from element: ElementType) -> Node<ElementType>
}

public extension Hierarchy {
    public func classify(_ element: ElementType) -> HierarchyRole {
        return .include
    }
    public func buildHierarchy(from element: ElementType) -> Node<ElementType> {
        let children = (try? element.down()) ?? []
        let childNodes = children.map { child in
            return buildHierarchy(from: child)
        }
        let node = Node(element: element, role: classify(element))
        childNodes.forEach { childNode in
            childNode.parent = childNode
        }
        node.children = childNodes
        return node
    }
}

public struct DefaultHierarchy<ElementType> : Hierarchy where ElementType : _AccessibilityElement {
    public func classify(_ element: ElementType) -> HierarchyRole {
        guard let role = try? element.role() else {
            return .skip
        }
        switch role {
        case .group:
            if let description = try? element.description(), description.count > 0 {
                return .include
            } else if let title = try? element.title(), title.count > 0 {
                return .include
            }
            return .skip
        case .application:
            return .container
        case .window:
            return .container
        case .menuBar:
            return .container
        case .toolbar:
            return .container
        default:
            return .include
        }
    }
    private func children(element: ElementType) -> [ElementType] {
        guard let children = try? element.down() else {
            return []
        }
        var c = [ElementType]()
        for child in children {
            switch classify(child) {
            case .container:
                c.append(child)
            case .include:
                c.append(child)
            case .skip:
                c.append(contentsOf: self.children(element: child))
            }
        }
        return c
    }
    private func childNodes(element: ElementType,
                            targeting target: inout Node<ElementType>?) -> [Node<ElementType>] {
        var childNodes = [Node<ElementType>]()
        for child in children(element: element) {
            childNodes.append(buildHierarchy(from: child, targeting: &target))
        }
        return childNodes
    }
    public func buildHierarchy(from element: ElementType,
                               targeting target: inout Node<ElementType>?) -> Node<ElementType> {
        let node = Node(element: element, role: classify(element))
        let childNodes = self.childNodes(element: element, targeting: &target)
        childNodes.forEach { childNode in
            childNode.parent = node
        }
        node.children = childNodes
        if node.element == target?.element {
            target = node
        }
        return node
    }
    public init() {
        
    }
}
