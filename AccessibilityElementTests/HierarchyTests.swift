//
//  HierarchyTests.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import XCTest
@testable import AccessibilityElement

class AccessibilityElementTests: XCTestCase {
    func testDefaultHierarchy() {
        let expected = tree(MockElement(uniqueID: 1, role: .window, value: "Window")) {
            return [
                tree(MockElement(uniqueID: 2, role: .staticText, value: "1")),
                tree(MockElement(uniqueID: 3, role: .staticText, value: "2")),
            ]
        }
        let element = tree(MockElement(uniqueID: 1, role: .window, value: "Window")) {
            return [
                tree(MockElement(uniqueID: 4, role: .group)) {
                    return tree(MockElement(uniqueID: 2, role: .staticText, value: "1"))
                },
                tree(MockElement(uniqueID: 3, role: .staticText, value: "2")),
            ]
        }
        let node = DefaultHierarchy().buildHierarchy(from: element)
        XCTAssertTrue(compare(lhs: expected, rhs: node))
    }
}
