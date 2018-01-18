//
//  MockElement.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
@testable import AccessibilityElement

func compare<T>(lhs: T, rhs: Node<T>) -> Bool {
    var flattenedLHS = [T]()
    lhs.walk { element in
        flattenedLHS.append(element)
    }
    var flattenedRHS = [T]()
    rhs.walk { node in
        flattenedRHS.append(node.element)
    }
    return flattenedLHS == flattenedRHS
}

func tree(_ element: MockElement) -> MockElement {
    return tree(element, childrenProvider: nil)
}
func tree(_ element: MockElement, childProvider: (() -> MockElement)?) -> MockElement {
    if let childProvider = childProvider {
        return tree(element) {
            return [childProvider()]
        }
    } else {
        return tree(element, childrenProvider: nil)
    }
}
func tree(_ element: MockElement, childrenProvider: (() -> [MockElement])?) -> MockElement {
    if let childrenProvider = childrenProvider {
        let children = childrenProvider()
        for child in children {
            child._parent = element
        }
        element._children = children
    }
    return element
}

final class MockElement : _Element {
    private let uniqueID: Int
    private var _role: NSAccessibilityRole?
    private var _subrole: NSAccessibilitySubrole?
    private var _value: Any?
    private var _description: String?
    private var _title: String?
    private var _isKeyboardFocused: Bool?
    fileprivate weak var _parent: MockElement?
    fileprivate var _children: [MockElement]?
    private var _hash = 0
    enum Error : Swift.Error {
        case noValue
    }
    private func unwrap<T>(_ optional: T?) throws -> T {
        guard let value = optional else {
            throw MockElement.Error.noValue
        }
        return value
    }
    func role() throws -> NSAccessibilityRole {
        return try unwrap(_role)
    }
    func subrole() throws -> NSAccessibilitySubrole {
        return try unwrap(_subrole)
    }
    func value() throws -> Any {
        return try unwrap(_value)
    }
    func description() throws -> String {
        return try unwrap(_description)
    }
    func title() throws -> String {
        return try unwrap(_title)
    }
    func isKeyboardFocused() throws -> Bool {
        return try unwrap(_isKeyboardFocused)
    }
    func parent() throws -> MockElement {
        return try unwrap(_parent)
    }
    func children() throws -> [MockElement] {
        return try unwrap(_children)
    }
    func roleDescription() throws -> String {
        throw AXUIElement.AXError.noValue
    }
    func attributedString(range: Range<Int>) throws -> NSAttributedString {
        throw AXUIElement.AXError.noValue
    }
    func numberOfCharacters() throws -> Int {
        throw AXUIElement.AXError.noValue
    }
    func titleElement() throws -> MockElement {
        throw AXUIElement.AXError.noValue
    }
    init(uniqueID: Int,
         role: NSAccessibilityRole? = nil,
         subrole: NSAccessibilitySubrole? = nil,
         value: Any? = nil,
         description: String? = nil,
         title: String? = nil,
         isKeyboardFocused: Bool? = nil) {
        self.uniqueID = uniqueID
        _role = role
        _subrole = subrole
        _value = value
        _description = description
        _title = title
        _isKeyboardFocused = isKeyboardFocused
    }
    static func ==(lhs: MockElement, rhs: MockElement) -> Bool {
        // TODO: Check parent and children as well
        return lhs.uniqueID == rhs.uniqueID
    }
}

extension MockElement : Hashable {
    var hashValue: Int {
        return _hash
    }
}
