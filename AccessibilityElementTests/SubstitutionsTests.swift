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
                       "1[[char ltrl]]m[[char norm]]")
        XCTAssertEqual(subs.perform("123 456m 789"),
                       "123 456[[char ltrl]]m[[char norm]] 789")
        XCTAssertEqual(subs.perform("123 456m 789m"),
                       "123 456[[char ltrl]]m[[char norm]] 789[[char ltrl]]m[[char norm]]")
        // TODO: Need to implement lookback
//        XCTAssertEqual(subs.perform("123 m456m 789m"),
//                       "123 m456m 789[[char ltrl]]m[[char norm]]")
        XCTAssertEqual(subs.perform("1 m"),
                       "1 [[char ltrl]]m[[char norm]]")
        XCTAssertEqual(subs.perform("1 "),
                       "1 ")
        XCTAssertEqual(subs.perform("1 mx"),
                       "1 mx")
        XCTAssertEqual(subs.perform("1🍔"),
                       "1🍔")
        XCTAssertEqual(subs.perform("🍔1🍔"),
                       "🍔1🍔")
        XCTAssertEqual(subs.perform("1 ms"),
                       "1 [[char ltrl]]ms[[char norm]]")
        XCTAssertEqual(subs.perform("1 mm"),
                       "1 [[char ltrl]]mm[[char norm]]")
    }
}
