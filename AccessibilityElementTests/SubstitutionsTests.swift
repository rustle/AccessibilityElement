//
//  SubstitutionsTests.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

import XCTest
@testable import AccessibilityElement

class SubstitutionsTests : XCTestCase {
    func testEm() {
        let subs = EmSubstitutions()
        XCTAssertEqual(subs.perform("1m"),
                       "1[[inpt phon]]_1EHm.[[inpt text]]")
        XCTAssertEqual(subs.perform("123 456m 789"),
                       "123 456[[inpt phon]]_1EHm.[[inpt text]] 789")
        XCTAssertEqual(subs.perform("123 456m 789m"),
                       "123 456[[inpt phon]]_1EHm.[[inpt text]] 789[[inpt phon]]_1EHm.[[inpt text]]")
        XCTAssertEqual(subs.perform("1 m"),
                       "1 [[inpt phon]]_1EHm.[[inpt text]]")
        XCTAssertEqual(subs.perform("1 "),
                       "1 ")
        XCTAssertEqual(subs.perform("1 mx"),
                       "1 mx")
        XCTAssertEqual(subs.perform("1🍔"),
                       "1🍔")
        XCTAssertEqual(subs.perform("🍔1🍔"),
                       "🍔1🍔")
        XCTAssertEqual(subs.perform("1 ms"),
                       "1 [[inpt phon]]_1EHm _1EHs.[[inpt text]]")
        XCTAssertEqual(subs.perform("1 mm"),
                       "1 [[inpt phon]]_1EHm ~2EHm.[[inpt text]]")
    }
}
