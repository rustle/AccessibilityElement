//
//  SubstitutionsTests.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

import XCTest
@testable import AccessibilityElement

class SubstitutionsTests : XCTestCase {
    func testPunctuation() {
        let subs = PunctuationExpansion()
        XCTAssertEqual(subs.perform("func hello() { }"), "func hello[[char ltrl]]()[[char norm]] [[char ltrl]]{[[char norm]] [[char ltrl]]}[[char norm]]")
    }
    func testDecomposingSubstitutions() {
        let subs = DecomposingSubstitutions()
        XCTAssertEqual(subs.perform("ḓĩẲçrätīčś"), "diAcratics")
        XCTAssertEqual(subs.perform("Ⓚ"), "K")
        XCTAssertEqual(subs.perform("𝔞"), "a")
        XCTAssertEqual(subs.perform("U̵"), "U")
    }
}
