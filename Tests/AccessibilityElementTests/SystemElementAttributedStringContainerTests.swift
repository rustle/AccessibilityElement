//
//  SystemElementAttributedStringContainerTests.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import XCTest
import AppKit
import CoreGraphics
@testable import AccessibilityElement

final class SystemElementAttributedStringContainerTests: XCTestCase {

    // MARK: - init: string preservation

    func test_init_preservesString() {
        let container = SystemElementAttributedStringContainer(
            attributedString: NSAttributedString(string: "hello world")
        )
        XCTAssertEqual(container.string, "hello world")
    }

    func test_init_emptyString() {
        let container = SystemElementAttributedStringContainer(
            attributedString: NSAttributedString(string: "")
        )
        XCTAssertEqual(container.string, "")
        XCTAssertTrue(container.runs.isEmpty)
    }

    // MARK: - init: supported attribute values

    func test_init_supportedStringAttribute() {
        let key = NSAttributedString.Key("testKey")
        let attrStr = NSAttributedString(string: "hello", attributes: [key: "value"])
        let container = SystemElementAttributedStringContainer(attributedString: attrStr)
        XCTAssertEqual(container.string, "hello")
        XCTAssertEqual(container.runs.count, 1)
        XCTAssertEqual(container.runs[0].range, NSRange(location: 0, length: 5))
        guard case let .string(attrValue) = container.runs[0].attributes[key] else {
            return XCTFail("Expected .string attribute value")
        }
        XCTAssertEqual(attrValue, "value")
    }

    func test_init_supportedIntegerAttribute() {
        let key = NSAttributedString.Key("level")
        let attrStr = NSAttributedString(string: "hi", attributes: [key: NSNumber(value: 3)])
        let container = SystemElementAttributedStringContainer(attributedString: attrStr)
        XCTAssertEqual(container.runs.count, 1)
        guard case let .int(n) = container.runs[0].attributes[key] else {
            return XCTFail("Expected .int attribute value")
        }
        XCTAssertEqual(n, 3)
    }

    // MARK: - init: unsupported attribute values dropped

    func test_init_unsupportedAttribute_NSFont_dropped() {
        let fontKey = NSAttributedString.Key("font")
        let attrStr = NSAttributedString(
            string: "hello",
            attributes: [fontKey: NSFont.systemFont(ofSize: 12)]
        )
        let container = SystemElementAttributedStringContainer(attributedString: attrStr)
        XCTAssertEqual(container.string, "hello")
        XCTAssertEqual(container.runs.count, 1)
        XCTAssertTrue(container.runs[0].attributes.isEmpty)
    }

    func test_init_mixedAttributes_unsupportedDropped() {
        let supportedKey = NSAttributedString.Key("label")
        let unsupportedKey = NSAttributedString.Key("color")
        let attrStr = NSAttributedString(
            string: "hello",
            attributes: [
                supportedKey: "visible",
                unsupportedKey: NSColor.red,
            ]
        )
        let container = SystemElementAttributedStringContainer(attributedString: attrStr)
        XCTAssertEqual(container.runs.count, 1)
        XCTAssertNotNil(container.runs[0].attributes[supportedKey])
        XCTAssertNil(container.runs[0].attributes[unsupportedKey])
    }

    // MARK: - init: multiple runs

    func test_init_multipleRuns_rangesPreserved() {
        let key = NSAttributedString.Key("flag")
        let mutable = NSMutableAttributedString(string: "helloworld")
        mutable.setAttributes([key: "A"], range: NSRange(location: 0, length: 5))
        mutable.setAttributes([key: "B"], range: NSRange(location: 5, length: 5))
        let container = SystemElementAttributedStringContainer(attributedString: mutable)
        XCTAssertEqual(container.string, "helloworld")
        XCTAssertEqual(container.runs.count, 2)
        guard case let .string(first) = container.runs[0].attributes[key] else {
            return XCTFail("Expected .string for first run")
        }
        guard case let .string(second) = container.runs[1].attributes[key] else {
            return XCTFail("Expected .string for second run")
        }
        XCTAssertEqual(first, "A")
        XCTAssertEqual(second, "B")
        XCTAssertEqual(container.runs[0].range, NSRange(location: 0, length: 5))
        XCTAssertEqual(container.runs[1].range, NSRange(location: 5, length: 5))
    }

    // MARK: - attributedString: round-trip

    func test_roundTrip_string() {
        let attrStr = NSAttributedString(string: "hello")
        let container = SystemElementAttributedStringContainer(attributedString: attrStr)
        XCTAssertEqual(container.attributedString.string, "hello")
    }

    func test_roundTrip_supportedAttribute() {
        let key = NSAttributedString.Key("myKey")
        let original = NSAttributedString(string: "test", attributes: [key: "myValue"])
        let container = SystemElementAttributedStringContainer(attributedString: original)
        let reconstructed = container.attributedString
        XCTAssertEqual(reconstructed.string, "test")
        let attr = reconstructed.attribute(key, at: 0, effectiveRange: nil) as? String
        XCTAssertEqual(attr, "myValue")
    }

    func test_roundTrip_attributeRangePreserved() {
        let key = NSAttributedString.Key("bold")
        let mutable = NSMutableAttributedString(string: "helloworld")
        mutable.setAttributes([key: "yes"], range: NSRange(location: 0, length: 5))
        mutable.setAttributes([:], range: NSRange(location: 5, length: 5))
        let container = SystemElementAttributedStringContainer(attributedString: mutable)
        let reconstructed = container.attributedString
        var effectiveRange = NSRange()
        let attr = reconstructed.attribute(key, at: 0, effectiveRange: &effectiveRange) as? String
        XCTAssertEqual(attr, "yes")
        XCTAssertEqual(effectiveRange.location, 0)
        XCTAssertEqual(effectiveRange.length, 5)
        let noAttr = reconstructed.attribute(key, at: 5, effectiveRange: nil)
        XCTAssertNil(noAttr)
    }

    // MARK: - Misuse: nested NSAttributedString as attribute value

    func test_nestedNSAttributedString_asAttribute_becomesNestedContainer() {
        // An attribute whose value is NSAttributedString is repackaged into a nested
        // .attributedString(container), not dropped.
        let key = NSAttributedString.Key("tooltip")
        let inner = NSAttributedString(string: "inner text")
        let outer = NSAttributedString(string: "outer", attributes: [key: inner])
        let container = SystemElementAttributedStringContainer(attributedString: outer)
        XCTAssertEqual(container.runs.count, 1)
        guard case let .attributedString(nested) = container.runs[0].attributes[key] else {
            return XCTFail("Expected nested .attributedString attribute")
        }
        XCTAssertEqual(nested.string, "inner text")
    }

    func test_roundTrip_nestedAttributedString_attributeValueIsContainerStruct() {
        // After round-trip via container.attributedString, the attribute value is an
        // NSAttributedString (from .value()), not SystemElementAttributedStringContainer.
        let key = NSAttributedString.Key("tooltip")
        let inner = NSAttributedString(string: "inner")
        let outer = NSAttributedString(string: "outer", attributes: [key: inner])
        let container = SystemElementAttributedStringContainer(attributedString: outer)
        let reconstructed = container.attributedString
        let attrValue = reconstructed.attribute(key, at: 0, effectiveRange: nil)
        XCTAssertFalse(attrValue is SystemElementAttributedStringContainer)
        XCTAssertTrue(attrValue is NSAttributedString)
    }

    // MARK: - CGColor attribute values

    func test_cgColor_attributeValue_preserved() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let red = try XCTUnwrap(CGColor(colorSpace: colorSpace, components: [1.0, 0.0, 0.0, 1.0]))
        let key = NSAttributedString.Key(rawValue: AttributedTextAttributes.foregroundColor.rawValue)
        let attrStr = NSAttributedString(string: "hello", attributes: [key: red])
        let container = SystemElementAttributedStringContainer(attributedString: attrStr)
        XCTAssertEqual(container.runs.count, 1)
        guard case let .color(codable) = container.runs[0].attributes[key] else {
            return XCTFail("Expected .color attribute")
        }
        XCTAssertEqual(codable.colorSpaceName, CGColorSpace.sRGB as String)
        XCTAssertEqual(codable.components, [1.0, 0.0, 0.0, 1.0])
    }

    func test_cgColor_roundTrip_attributeValueIsCodableCGColor() throws {
        // After round-trip via container.attributedString, the attribute value is
        // CodableCGColor (from .color(c).value()), not CGColor.
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let blue = try XCTUnwrap(CGColor(colorSpace: colorSpace, components: [0.0, 0.0, 1.0, 1.0]))
        let key = NSAttributedString.Key(rawValue: AttributedTextAttributes.foregroundColor.rawValue)
        let attrStr = NSAttributedString(string: "hello", attributes: [key: blue])
        let container = SystemElementAttributedStringContainer(attributedString: attrStr)
        let reconstructed = container.attributedString
        var effectiveRange = NSRange()
        let attrValue = reconstructed.attribute(key, at: 0, effectiveRange: &effectiveRange)
        XCTAssertTrue(attrValue is CodableCGColor)
    }

    func test_secondPass_containerStructAttribute_isDropped() {
        // Taking the reconstructed NSAttributedString (whose attribute values are
        // SystemElementAttributedStringContainer structs) and wrapping it again causes those
        // struct values to be rejected by the repackager and silently dropped.
        let key = NSAttributedString.Key("tooltip")
        let inner = NSAttributedString(string: "inner")
        let outer = NSAttributedString(string: "outer", attributes: [key: inner])
        let firstPass = SystemElementAttributedStringContainer(attributedString: outer)
        // firstPass has a .attributedString(…) attribute for `key`
        let reconstructed = firstPass.attributedString
        // reconstructed has a SystemElementAttributedStringContainer struct as the attribute value
        let secondPass = SystemElementAttributedStringContainer(attributedString: reconstructed)
        XCTAssertEqual(secondPass.string, "outer")
        XCTAssertEqual(secondPass.runs.count, 1)
        // The struct is not repackageable, so the attribute is dropped on the second pass
        XCTAssertTrue(secondPass.runs[0].attributes.isEmpty)
    }
}
