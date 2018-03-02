//
//  AccessibilityHierarchy.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa
import os.log

public enum HierarchyRole {
    case skip
    case container
    case include
}

public enum HierarchyError : Error {
    case noValue
}

public protocol Hierarchy {
    associatedtype ElementType : _Element
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

public struct DefaultHierarchy<ElementType> : Hierarchy where ElementType : _Element {
    let containerRoles = Set([
        .application,
        .window,
        .menuBar,
        .toolbar,
        .scrollArea,
        .table,
        NSAccessibilityRole.webArea,
    ])
    public func classify(_ element: ElementType) -> HierarchyRole {
        guard let role = try? element.role() else {
            return .skip
        }
        if containerRoles.contains(role) {
            return .container
        }
        switch role {
        case .group:
            if let description = try? element.description(), description.count > 0 {
                return .include
            } else if let title = try? element.title(), title.count > 0 {
                return .include
            }
            return .skip
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
        if node._element == target?._element {
            target = node
        }
        return node
    }
    public init() {
        
    }
}
