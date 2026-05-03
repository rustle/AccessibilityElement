//
//  SystemElementValueRepackagerTests.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import XCTest
import AppKit
import ApplicationServices
import AX
@testable import AccessibilityElement

final class SystemElementValueRepackagerTests: XCTestCase {

    // MARK: - String

    func test_string() throws {
        let container = try SystemElementValueContainer.from(any: "hello")
        guard case let .string(value) = container else { return XCTFail("Expected .string") }
        XCTAssertEqual(value, "hello")
    }

    func test_emptyString() throws {
        let container = try SystemElementValueContainer.from(any: "")
        guard case let .string(value) = container else { return XCTFail("Expected .string") }
        XCTAssertEqual(value, "")
    }

    // MARK: - CFNumber / NSNumber

    func test_cfNumber_integer() throws {
        let container = try SystemElementValueContainer.from(any: NSNumber(value: 42))
        guard case let .int(value) = container else { return XCTFail("Expected .int") }
        XCTAssertEqual(value, 42)
    }

    func test_cfNumber_integerZero() throws {
        let container = try SystemElementValueContainer.from(any: NSNumber(value: 0))
        guard case let .int(value) = container else { return XCTFail("Expected .int") }
        XCTAssertEqual(value, 0)
    }

    func test_cfNumber_negativeInteger() throws {
        let container = try SystemElementValueContainer.from(any: NSNumber(value: -99))
        guard case let .int(value) = container else { return XCTFail("Expected .int") }
        XCTAssertEqual(value, -99)
    }

    func test_cfNumber_float() throws {
        let container = try SystemElementValueContainer.from(any: NSNumber(value: 3.14))
        guard case let .double(value) = container else { return XCTFail("Expected .double") }
        XCTAssertEqual(value, 3.14, accuracy: 1e-10)
    }

    func test_cfNumber_negativeFloat() throws {
        let container = try SystemElementValueContainer.from(any: NSNumber(value: -1.5))
        guard case let .double(value) = container else { return XCTFail("Expected .double") }
        XCTAssertEqual(value, -1.5, accuracy: 1e-10)
    }

    // MARK: - CFBoolean

    func test_cfBoolean_true() throws {
        let container = try SystemElementValueContainer.from(any: kCFBooleanTrue!)
        guard case let .bool(value) = container else { return XCTFail("Expected .bool") }
        XCTAssertTrue(value)
    }

    func test_cfBoolean_false() throws {
        let container = try SystemElementValueContainer.from(any: kCFBooleanFalse!)
        guard case let .bool(value) = container else { return XCTFail("Expected .bool") }
        XCTAssertFalse(value)
    }

    // MARK: - AXValue: geometry and range

    func test_axValue_point() throws {
        var point = CGPoint(x: 1.0, y: 2.0)
        let axValue = AXValueCreate(.cgPoint, &point)!
        let container = try SystemElementValueContainer.from(any: axValue)
        guard case let .point(value) = container else { return XCTFail("Expected .point") }
        XCTAssertEqual(value.x, 1.0)
        XCTAssertEqual(value.y, 2.0)
    }

    func test_axValue_size() throws {
        var size = CGSize(width: 100.0, height: 200.0)
        let axValue = AXValueCreate(.cgSize, &size)!
        let container = try SystemElementValueContainer.from(any: axValue)
        guard case let .size(value) = container else { return XCTFail("Expected .size") }
        XCTAssertEqual(value.width, 100.0)
        XCTAssertEqual(value.height, 200.0)
    }

    func test_axValue_rect() throws {
        var rect = CGRect(x: 10, y: 20, width: 100, height: 200)
        let axValue = AXValueCreate(.cgRect, &rect)!
        let container = try SystemElementValueContainer.from(any: axValue)
        guard case let .rect(value) = container else { return XCTFail("Expected .rect") }
        XCTAssertEqual(value.origin.x, 10)
        XCTAssertEqual(value.origin.y, 20)
        XCTAssertEqual(value.size.width, 100)
        XCTAssertEqual(value.size.height, 200)
    }

    func test_axValue_range() throws {
        var cfRange = CFRange(location: 5, length: 10)
        let axValue = AXValueCreate(.cfRange, &cfRange)!
        let container = try SystemElementValueContainer.from(any: axValue)
        guard case let .range(value) = container else { return XCTFail("Expected .range") }
        XCTAssertEqual(value, 5..<15)
    }

    func test_axValue_error() throws {
        var axErrorValue = ApplicationServices.AXError.attributeUnsupported
        let axValue = AXValueCreate(.axError, &axErrorValue)!
        let container = try SystemElementValueContainer.from(any: axValue)
        guard case .error(_) = container else { return XCTFail("Expected .error") }
    }

    // MARK: - AXUIElement

    func test_axUIElement() throws {
        let axElement = AXUIElementCreateApplication(ProcessInfo.processInfo.processIdentifier)
        let container = try SystemElementValueContainer.from(any: axElement)
        guard case .element(_) = container else { return XCTFail("Expected .element") }
    }

    // MARK: - AXTextMarker / AXTextMarkerRange

    func test_textMarker() throws {
        let bytes: [UInt8] = [1, 2, 3, 4]
        let axMarker = bytes.withUnsafeBytes { buf in
            AXTextMarkerCreate(kCFAllocatorDefault, buf.bindMemory(to: UInt8.self).baseAddress!, buf.count)
        }
        let container = try SystemElementValueContainer.from(any: axMarker)
        guard case let .textMarker(marker) = container else { return XCTFail("Expected .textMarker") }
        let roundTripped = marker.withUnsafeBytes { ptr in Data(bytes: ptr.baseAddress!, count: ptr.count) }
        XCTAssertEqual(roundTripped, Data(bytes))
    }

    func test_textMarkerRange() throws {
        let lowerBytes: [UInt8] = [1, 2, 3, 4]
        let upperBytes: [UInt8] = [5, 6, 7, 8]
        let lower = lowerBytes.withUnsafeBytes { buf in
            AXTextMarkerCreate(kCFAllocatorDefault, buf.bindMemory(to: UInt8.self).baseAddress!, buf.count)
        }
        let upper = upperBytes.withUnsafeBytes { buf in
            AXTextMarkerCreate(kCFAllocatorDefault, buf.bindMemory(to: UInt8.self).baseAddress!, buf.count)
        }
        let axRange = AXTextMarkerRangeCreate(kCFAllocatorDefault, lower, upper)
        let container = try SystemElementValueContainer.from(any: axRange)
        guard case let .textMarkerRange(markerRange) = container else {
            return XCTFail("Expected .textMarkerRange")
        }
        let lowerData = markerRange.lowerBound.withUnsafeBytes { ptr in Data(bytes: ptr.baseAddress!, count: ptr.count) }
        let upperData = markerRange.upperBound.withUnsafeBytes { ptr in Data(bytes: ptr.baseAddress!, count: ptr.count) }
        XCTAssertEqual(lowerData, Data(lowerBytes))
        XCTAssertEqual(upperData, Data(upperBytes))
    }

    // MARK: - URL

    func test_url_fileURL() throws {
        let url = URL(fileURLWithPath: "/tmp/test")
        let container = try SystemElementValueContainer.from(any: url)
        guard case let .url(value) = container else { return XCTFail("Expected .url") }
        XCTAssertEqual(value, url)
    }

    func test_url_httpsURL() throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/path?q=1"))
        let container = try SystemElementValueContainer.from(any: url)
        guard case let .url(value) = container else { return XCTFail("Expected .url") }
        XCTAssertEqual(value, url)
    }

    func test_url_nsURL_bridged() throws {
        let nsURL = NSURL(string: "https://example.com")!
        let container = try SystemElementValueContainer.from(any: nsURL)
        guard case .url(_) = container else { return XCTFail("Expected .url") }
    }

    func test_url_roundTripsViaValue() throws {
        let original = URL(fileURLWithPath: "/tmp/roundtrip")
        let container = try SystemElementValueContainer.from(any: original)
        let recycled = try SystemElementValueContainer.from(any: container.value())
        guard case let .url(value) = recycled else { return XCTFail("Expected .url") }
        XCTAssertEqual(value, original)
    }

    // MARK: - CGColor

    func test_cgColor_sRGB() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let color = try XCTUnwrap(CGColor(colorSpace: colorSpace, components: [1.0, 0.0, 0.0, 1.0]))
        let container = try SystemElementValueContainer.from(any: color)
        guard case let .color(codable) = container else { return XCTFail("Expected .color") }
        XCTAssertEqual(codable.colorSpaceName, CGColorSpace.sRGB as String)
        XCTAssertEqual(codable.components, [1.0, 0.0, 0.0, 1.0])
    }

    func test_cgColor_displayP3() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.displayP3))
        let color = try XCTUnwrap(CGColor(colorSpace: colorSpace, components: [0.0, 1.0, 0.0, 1.0]))
        let container = try SystemElementValueContainer.from(any: color)
        guard case .color(_) = container else { return XCTFail("Expected .color") }
    }

    func test_cgColor_gray() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.genericGrayGamma2_2))
        let color = try XCTUnwrap(CGColor(colorSpace: colorSpace, components: [0.5, 1.0]))
        let container = try SystemElementValueContainer.from(any: color)
        guard case let .color(codable) = container else { return XCTFail("Expected .color") }
        XCTAssertEqual(codable.components, [0.5, 1.0])
    }

    func test_cgColor_roundTripViaValue() throws {
        // .color(c).value() returns CodableCGColor struct, not CGColor;
        // feeding it back in throws typeMismatch (same pattern as .attributedString)
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let color = try XCTUnwrap(CGColor(colorSpace: colorSpace, components: [1.0, 1.0, 0.0, 1.0]))
        let container = try SystemElementValueContainer.from(any: color)
        let rawValue = container.value()
        XCTAssertTrue(rawValue is CodableCGColor)
        XCTAssertFalse(rawValue is CGColor)
        XCTAssertThrowsError(try SystemElementValueContainer.from(any: rawValue)) { error in
            XCTAssertEqual(error as? AccessibilityError, .typeMismatch)
        }
    }

    // MARK: - NSAttributedString

    func test_nsAttributedString() throws {
        let attrStr = NSAttributedString(string: "hello")
        let container = try SystemElementValueContainer.from(any: attrStr)
        guard case let .attributedString(value) = container else {
            return XCTFail("Expected .attributedString")
        }
        XCTAssertEqual(value.string, "hello")
    }

    // MARK: - Array

    func test_array_empty() throws {
        let container = try SystemElementValueContainer.from(any: [] as [Any])
        guard case let .array(values) = container else { return XCTFail("Expected .array") }
        XCTAssertTrue(values.isEmpty)
    }

    func test_array_strings() throws {
        let container = try SystemElementValueContainer.from(any: ["a", "b", "c"] as [Any])
        guard case let .array(values) = container else { return XCTFail("Expected .array") }
        XCTAssertEqual(values.count, 3)
        guard case let .string(first) = values[0] else { return XCTFail("Expected .string at [0]") }
        guard case let .string(second) = values[1] else { return XCTFail("Expected .string at [1]") }
        guard case let .string(third) = values[2] else { return XCTFail("Expected .string at [2]") }
        XCTAssertEqual(first, "a")
        XCTAssertEqual(second, "b")
        XCTAssertEqual(third, "c")
    }

    func test_array_mixed() throws {
        let input: [Any] = ["hello", NSNumber(value: 42), kCFBooleanTrue!]
        let container = try SystemElementValueContainer.from(any: input)
        guard case let .array(values) = container else { return XCTFail("Expected .array") }
        XCTAssertEqual(values.count, 3)
        guard case .string(_) = values[0] else { return XCTFail("Expected .string at [0]") }
        guard case .int(_) = values[1] else { return XCTFail("Expected .int at [1]") }
        guard case .bool(_) = values[2] else { return XCTFail("Expected .bool at [2]") }
    }

    func test_array_nested() throws {
        let container = try SystemElementValueContainer.from(any: [["inner"] as [Any]] as [Any])
        guard case let .array(outer) = container else { return XCTFail("Expected .array") }
        XCTAssertEqual(outer.count, 1)
        guard case let .array(inner) = outer[0] else { return XCTFail("Expected nested .array") }
        XCTAssertEqual(inner.count, 1)
        guard case let .string(s) = inner[0] else { return XCTFail("Expected .string") }
        XCTAssertEqual(s, "inner")
    }

    func test_array_dropsUnsupported() throws {
        let input: [Any] = ["valid", NSObject(), "also valid"]
        let container = try SystemElementValueContainer.from(any: input)
        guard case let .array(values) = container else { return XCTFail("Expected .array") }
        XCTAssertEqual(values.count, 2)
        guard case let .string(first) = values[0] else { return XCTFail() }
        guard case let .string(second) = values[1] else { return XCTFail() }
        XCTAssertEqual(first, "valid")
        XCTAssertEqual(second, "also valid")
    }

    func test_array_allUnsupported_isEmpty() throws {
        let container = try SystemElementValueContainer.from(any: [NSObject(), NSObject()] as [Any])
        guard case let .array(values) = container else { return XCTFail("Expected .array") }
        XCTAssertTrue(values.isEmpty)
    }

    // MARK: - Dictionary

    func test_dictionary_empty() throws {
        let container = try SystemElementValueContainer.from(any: [:] as [String: Any])
        guard case let .dictionary(values) = container else { return XCTFail("Expected .dictionary") }
        XCTAssertTrue(values.isEmpty)
    }

    func test_dictionary_strings() throws {
        let container = try SystemElementValueContainer.from(any: ["key": "value"] as [String: Any])
        guard case let .dictionary(values) = container else { return XCTFail("Expected .dictionary") }
        XCTAssertEqual(values.count, 1)
        guard case let .string(s) = values["key"] else { return XCTFail("Expected .string for 'key'") }
        XCTAssertEqual(s, "value")
    }

    func test_dictionary_mixed() throws {
        let input: [String: Any] = ["name": "hello", "count": NSNumber(value: 5), "flag": kCFBooleanTrue!]
        let container = try SystemElementValueContainer.from(any: input)
        guard case let .dictionary(values) = container else { return XCTFail("Expected .dictionary") }
        XCTAssertEqual(values.count, 3)
        guard case .string(_) = values["name"] else { return XCTFail("Expected .string for 'name'") }
        guard case .int(_) = values["count"] else { return XCTFail("Expected .int for 'count'") }
        guard case .bool(_) = values["flag"] else { return XCTFail("Expected .bool for 'flag'") }
    }

    func test_dictionary_dropsUnsupported() throws {
        let input: [String: Any] = ["valid": "hello", "unsupported": NSObject(), "alsoValid": "world"]
        let container = try SystemElementValueContainer.from(any: input)
        guard case let .dictionary(values) = container else { return XCTFail("Expected .dictionary") }
        XCTAssertEqual(values.count, 2)
        XCTAssertNotNil(values["valid"])
        XCTAssertNil(values["unsupported"])
        XCTAssertNotNil(values["alsoValid"])
    }

    func test_dictionary_allUnsupported_isEmpty() throws {
        let input: [String: Any] = ["k1": NSObject(), "k2": NSObject()]
        let container = try SystemElementValueContainer.from(any: input)
        guard case let .dictionary(values) = container else { return XCTFail("Expected .dictionary") }
        XCTAssertTrue(values.isEmpty)
    }

    // MARK: - Unsupported types throw

    func test_unsupported_NSObject_throws() {
        XCTAssertThrowsError(try SystemElementValueContainer.from(any: NSObject())) { error in
            XCTAssertEqual(error as? AccessibilityError, .typeMismatch)
        }
    }

    func test_unsupported_Data_throws() {
        XCTAssertThrowsError(try SystemElementValueContainer.from(any: Data())) { error in
            XCTAssertEqual(error as? AccessibilityError, .typeMismatch)
        }
    }

    func test_url_isSupported() throws {
        let url = URL(fileURLWithPath: "/")
        let container = try SystemElementValueContainer.from(any: url)
        guard case let .url(value) = container else { return XCTFail("Expected .url") }
        XCTAssertEqual(value, url)
    }

    // MARK: - CFDictionary overload

    func test_cfDictionary_nil() {
        let result = SystemElementValueRepackager.repackage(dictionary: nil)
        XCTAssertTrue(result.isEmpty)
    }

    func test_cfDictionary_valid() {
        let input: [String: Any] = ["key": "value"]
        let result = SystemElementValueRepackager.repackage(dictionary: input as CFDictionary)
        XCTAssertEqual(result.count, 1)
        guard case let .string(s) = result["key"] else { return XCTFail("Expected .string for 'key'") }
        XCTAssertEqual(s, "value")
    }

    func test_cfDictionary_dropsUnsupported() {
        let input: [String: Any] = ["valid": "hello", "invalid": NSObject()]
        let result = SystemElementValueRepackager.repackage(dictionary: input as CFDictionary)
        XCTAssertEqual(result.count, 1)
        XCTAssertNotNil(result["valid"])
        XCTAssertNil(result["invalid"])
    }

    // MARK: - Container pass-through

    func test_container_passthrough_string() throws {
        let original = SystemElementValueContainer.string("hello")
        let recycled = try SystemElementValueContainer.from(any: original)
        guard case let .string(value) = recycled else { return XCTFail("Expected .string") }
        XCTAssertEqual(value, "hello")
    }

    func test_container_passthrough_int() throws {
        let original = SystemElementValueContainer.int(99)
        let recycled = try SystemElementValueContainer.from(any: original)
        guard case let .int(value) = recycled else { return XCTFail("Expected .int") }
        XCTAssertEqual(value, 99)
    }

    func test_container_passthrough_nestedArray() throws {
        let original = SystemElementValueContainer.array([.string("x"), .int(1)])
        let recycled = try SystemElementValueContainer.from(any: original)
        guard case let .array(values) = recycled else { return XCTFail("Expected .array") }
        XCTAssertEqual(values.count, 2)
        guard case let .string(s) = values[0] else { return XCTFail() }
        guard case let .int(n) = values[1] else { return XCTFail() }
        XCTAssertEqual(s, "x")
        XCTAssertEqual(n, 1)
    }

    func test_array_containingContainer_passesThrough() throws {
        let inner = SystemElementValueContainer.string("hello")
        let container = try SystemElementValueContainer.from(any: [inner] as [Any])
        guard case let .array(values) = container else { return XCTFail("Expected .array") }
        XCTAssertEqual(values.count, 1)
        guard case let .string(s) = values[0] else { return XCTFail() }
        XCTAssertEqual(s, "hello")
    }

    func test_dictionary_containingContainer_passesThrough() throws {
        let inner = SystemElementValueContainer.int(42)
        let container = try SystemElementValueContainer.from(any: ["key": inner] as [String: Any])
        guard case let .dictionary(values) = container else { return XCTFail("Expected .dictionary") }
        guard case let .int(n) = values["key"] else { return XCTFail() }
        XCTAssertEqual(n, 42)
    }

    // MARK: - value() round-trip behaviour

    func test_value_string_roundTrips() throws {
        // String bridges to String so it re-enters via the String branch
        let original = SystemElementValueContainer.string("round trip")
        let recycled = try SystemElementValueContainer.from(any: original.value())
        guard case let .string(s) = recycled else { return XCTFail("Expected .string") }
        XCTAssertEqual(s, "round trip")
    }

    func test_value_int_roundTrips() throws {
        // Swift Int bridges to NSNumber (CFNumber integer) on re-entry
        let original = SystemElementValueContainer.int(7)
        let recycled = try SystemElementValueContainer.from(any: original.value())
        guard case let .int(n) = recycled else { return XCTFail("Expected .int") }
        XCTAssertEqual(n, 7)
    }

    func test_value_double_roundTrips() throws {
        // Swift Double bridges to NSNumber (CFNumber float) on re-entry
        let original = SystemElementValueContainer.double(2.5)
        let recycled = try SystemElementValueContainer.from(any: original.value())
        guard case let .double(d) = recycled else { return XCTFail("Expected .double") }
        XCTAssertEqual(d, 2.5, accuracy: 1e-10)
    }

    func test_value_bool_roundTrips() throws {
        // Swift Bool bridges to kCFBooleanTrue/False on re-entry
        let original = SystemElementValueContainer.bool(true)
        let recycled = try SystemElementValueContainer.from(any: original.value())
        guard case let .bool(b) = recycled else { return XCTFail("Expected .bool") }
        XCTAssertTrue(b)
    }

    func test_value_array_roundTrips() throws {
        // [SystemElementValueContainer] casts to [Any]; each element is a container and passes through
        let original = SystemElementValueContainer.array([.string("a"), .int(1)])
        let recycled = try SystemElementValueContainer.from(any: original.value())
        guard case let .array(values) = recycled else { return XCTFail("Expected .array") }
        XCTAssertEqual(values.count, 2)
        guard case let .string(s) = values[0] else { return XCTFail() }
        guard case let .int(n) = values[1] else { return XCTFail() }
        XCTAssertEqual(s, "a")
        XCTAssertEqual(n, 1)
    }

    func test_value_dictionary_roundTrips() throws {
        // [String: SystemElementValueContainer] casts to [String: Any]; each value passes through
        let original = SystemElementValueContainer.dictionary(["k": .string("v")])
        let recycled = try SystemElementValueContainer.from(any: original.value())
        guard case let .dictionary(dict) = recycled else { return XCTFail("Expected .dictionary") }
        guard case let .string(s) = dict["k"] else { return XCTFail() }
        XCTAssertEqual(s, "v")
    }

    func test_value_point_roundTrips() throws {
        let original = SystemElementValueContainer.point(CGPoint(x: 1, y: 2))
        let recycled = try SystemElementValueContainer.from(any: original.value())
        guard case let .point(p) = recycled else { return XCTFail("Expected .point") }
        XCTAssertEqual(p, CGPoint(x: 1, y: 2))
    }

    func test_value_size_roundTrips() throws {
        let original = SystemElementValueContainer.size(CGSize(width: 10, height: 20))
        let recycled = try SystemElementValueContainer.from(any: original.value())
        guard case let .size(s) = recycled else { return XCTFail("Expected .size") }
        XCTAssertEqual(s, CGSize(width: 10, height: 20))
    }

    func test_value_rect_roundTrips() throws {
        let original = SystemElementValueContainer.rect(CGRect(x: 0, y: 0, width: 10, height: 10))
        let recycled = try SystemElementValueContainer.from(any: original.value())
        guard case let .rect(r) = recycled else { return XCTFail("Expected .rect") }
        XCTAssertEqual(r, CGRect(x: 0, y: 0, width: 10, height: 10))
    }

    func test_value_range_roundTrips() throws {
        let original = SystemElementValueContainer.range(0..<5)
        let recycled = try SystemElementValueContainer.from(any: original.value())
        guard case let .range(r) = recycled else { return XCTFail("Expected .range") }
        XCTAssertEqual(r, 0..<5)
    }

    func test_value_attributedString_returnsNSAttributedString_notContainerStruct() throws {
        // .attributedString(c).value() returns a reconstructed NSSAtributedString,
        // not a SystemElementAttributedStringContainer struct.
        let attrStr = NSAttributedString(string: "hello")
        let container = try SystemElementValueContainer.from(any: attrStr)
        let rawValue = container.value()
        XCTAssertFalse(rawValue is SystemElementAttributedStringContainer)
        XCTAssertTrue(rawValue is NSAttributedString)
        XCTAssertEqual(attrStr, rawValue as! NSAttributedString)
    }
}
