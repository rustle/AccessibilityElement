//
//  AttributedStringsTest.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import XCTest
@testable import AccessibilityElement

class AttributedStringsTests: XCTestCase {
    func testSetGetFont() {
        var string = AttributedString(attributedString: NSAttributedString(string: "test", attributes: [:]))
        let expectedFont = AttributedString.Font([
            AttributedString.Font.Key.name:"testfont",
            AttributedString.Font.Key.size:18,
        ])!
        string.set(font: expectedFont, range: 0..<1)
        if let font = string.font(at: 0) {
            XCTAssertEqual(expectedFont, font)
        } else {
            XCTFail()
        }
    }
    func testMakeFont() {
        let expectedFont1 = AttributedString.Font([
            AttributedString.Font.Key.name:"testfont",
            AttributedString.Font.Key.size:18,
        ])
        XCTAssertNotNil(expectedFont1)
        let expectedFont2 = AttributedString.Font([
            AttributedString.Font.Key.name:"testfont",
            AttributedString.Font.Key.size:18.0,
        ])
        XCTAssertNotNil(expectedFont2)
        let expectedFont3 = AttributedString.Font([
            AttributedString.Font.Key.name:"testfont",
            AttributedString.Font.Key.size:Float(18.0),
        ])
        XCTAssertNotNil(expectedFont3)
    }
}
