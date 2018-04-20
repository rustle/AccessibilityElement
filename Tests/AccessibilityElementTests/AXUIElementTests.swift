//
//  AXUIElementTests.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import XCTest
import Cocoa
@testable import AccessibilityElement

class AXUIElementTests: XCTestCase {
    func testTransportData() {
        let systemWide = AXUIElement.systemWide()
        let data = systemWide.transportRepresentation()
        XCTAssertTrue(data.count > 0)
    }
    func testCreateWithTransportData() {
        let systemWide = AXUIElement.systemWide()
        let data = systemWide.transportRepresentation()
        XCTAssertTrue(data.count > 0)
        let element =  AXUIElement.element(transportRepresentation: data)
        XCTAssertEqual(systemWide, element)
    }
}
