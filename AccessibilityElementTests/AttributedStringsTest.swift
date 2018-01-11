//
//  AttributedStringsTest.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import XCTest
@testable import AccessibilityElement

class AttributedStringsTests: XCTestCase {
    func testSetGet() {
        var string = AttributedString(string: "test", attributes: [:])
        let expectedFont = AttributedString.Font([AttributedString.Font.Key.family:"testfamily"])
        string.set(attribute: .font, range: 0..<1, value: expectedFont)
        if let font = string.attribute(.font, index: 0) as? AttributedString.Font {
            XCTAssertEqual(expectedFont, font)
        } else {
            XCTFail()
        }
    }
}
