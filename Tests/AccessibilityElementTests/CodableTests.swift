//
//  CodableTests.swift
//  
//  Copyright © 2020 Doug Russell. All rights reserved.
//

import XCTest
import Cocoa
@testable import AccessibilityElement

class CodableTests: XCTestCase {
    func testAttributeCodable() throws {
        let data = try JSONEncoder().encode(NSAccessibility.Attribute.caretBrowsingEnabled)
        let caretBrowsingEnabled = try JSONDecoder().decode(NSAccessibility.Attribute.self,
                                                            from: data)
        XCTAssertEqual(NSAccessibility.Attribute.caretBrowsingEnabled,
                       caretBrowsingEnabled)
    }
    func testParameterizedAttributeCodable() throws {
        let data = try JSONEncoder().encode(NSAccessibility.ParameterizedAttribute.boundsForRange)
        let boundsForRange = try JSONDecoder().decode(NSAccessibility.ParameterizedAttribute.self,
                                                      from: data)
        XCTAssertEqual(NSAccessibility.ParameterizedAttribute.boundsForRange,
                       boundsForRange)
    }
    func testRoleCodable() throws {
        let data = try JSONEncoder().encode(NSAccessibility.Role.webArea)
        let webarea = try JSONDecoder().decode(NSAccessibility.Role.self,
                                               from: data)
        XCTAssertEqual(NSAccessibility.Role.webArea,
                       webarea)
    }
    func testSubroleCodable() throws {
        let data = try JSONEncoder().encode(NSAccessibility.Subrole.outlineRow)
        let outlineRow = try JSONDecoder().decode(NSAccessibility.Subrole.self,
                                                  from: data)
        XCTAssertEqual(NSAccessibility.Subrole.outlineRow,
                       outlineRow)
    }
}
