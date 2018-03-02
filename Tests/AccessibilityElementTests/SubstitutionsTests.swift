//
//  SubstitutionsTests.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

import XCTest
@testable import AccessibilityElement

class SubstitutionsTests : XCTestCase {
    func testAbbreviation() {
        let subs = AbbreviationExpansion()
        XCTAssertEqual(subs.perform("1m"),              "1[[char ltrl]]m[[char norm]]")
        XCTAssertEqual(subs.perform("123 456m 789"),    "123 456[[char ltrl]]m[[char norm]] 789")
        XCTAssertEqual(subs.perform("123 456m 789m"),   "123 456[[char ltrl]]m[[char norm]] 789[[char ltrl]]m[[char norm]]")
        XCTAssertEqual(subs.perform("123 m456m 789m"),  "123 m456[[char ltrl]]m[[char norm]] 789[[char ltrl]]m[[char norm]]")
        XCTAssertEqual(subs.perform("1 m"),             "1 [[char ltrl]]m[[char norm]]")
        XCTAssertEqual(subs.perform("1 "),              "1 ")
        XCTAssertEqual(subs.perform("1 mx"),            "1 mx")
        XCTAssertEqual(subs.perform("1mx"),             "1mx")
        XCTAssertEqual(subs.perform("🍔1m"),            "🍔1[[char ltrl]]m[[char norm]]")
        XCTAssertEqual(subs.perform("1🍔"),             "1🍔")
        XCTAssertEqual(subs.perform("🍔1🍔"),           "🍔1🍔")
        XCTAssertEqual(subs.perform("🍔1🍔m"),          "🍔1🍔m")
        XCTAssertEqual(subs.perform("1 ms"),            "1 [[char ltrl]]ms[[char norm]]")
        XCTAssertEqual(subs.perform("1 mm"),            "1 [[char ltrl]]mm[[char norm]]")
        XCTAssertEqual(subs.perform("1ms"),             "1[[char ltrl]]ms[[char norm]]")
        XCTAssertEqual(subs.perform("1mm"),             "1[[char ltrl]]mm[[char norm]]")
        XCTAssertEqual(subs.perform("1mss"),            "1mss")
        XCTAssertEqual(subs.perform("1mmm"),            "1mmm")
        XCTAssertEqual(subs.perform("1s"),              "1s")
        XCTAssertEqual(subs.perform("1 s"),             "1 [[char ltrl]]s[[char norm]]")
        // TODO:
//        XCTAssertEqual(subs.perform("1 cm"),             "1 [[char ltrl]]cm[[char norm]]")
//        XCTAssertEqual(subs.perform("1 nm"),             "1 [[char ltrl]]nm[[char norm]]")
//        XCTAssertEqual(subs.perform("1 ft"),             "1 [[char ltrl]]ft[[char norm]]")
//        XCTAssertEqual(subs.perform("1 in"),             "1 [[char ltrl]]in[[char norm]]")
//        XCTAssertEqual(subs.perform("1'"),               "1 [[char ltrl]]'[[char norm]]")
//        XCTAssertEqual(subs.perform("1\""),              "1 [[char ltrl]]\"[[char norm]]")
//        XCTAssertEqual(subs.perform("1''"),              "1 [[char ltrl]]''[[char norm]]")
    }
    func testPunctuation() {
        let subs = PunctuationExpansion()
        XCTAssertEqual(subs.perform("func hello() { }"), "func hello[[char ltrl]]()[[char norm]] [[char ltrl]]{[[char norm]] [[char ltrl]]}[[char norm]]")
    }
}
