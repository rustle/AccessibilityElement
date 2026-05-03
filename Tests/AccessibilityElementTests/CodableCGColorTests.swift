//
//  CodableCGColorTests.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import XCTest
import CoreGraphics
@testable import AccessibilityElement

final class CodableCGColorTests: XCTestCase {

    // MARK: - init

    func test_init_sRGB() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let color = try XCTUnwrap(CGColor(colorSpace: colorSpace, components: [1.0, 0.0, 0.0, 1.0]))
        let codable = try XCTUnwrap(CodableCGColor(color: color))
        XCTAssertEqual(codable.colorSpaceName, CGColorSpace.sRGB as String)
        XCTAssertEqual(codable.components, [1.0, 0.0, 0.0, 1.0])
    }

    func test_init_displayP3() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.displayP3))
        let color = try XCTUnwrap(CGColor(colorSpace: colorSpace, components: [0.5, 0.5, 0.5, 1.0]))
        let codable = try XCTUnwrap(CodableCGColor(color: color))
        XCTAssertEqual(codable.colorSpaceName, CGColorSpace.displayP3 as String)
        XCTAssertEqual(codable.components, [0.5, 0.5, 0.5, 1.0])
    }

    func test_init_genericGray() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.genericGrayGamma2_2))
        let color = try XCTUnwrap(CGColor(colorSpace: colorSpace, components: [0.75, 1.0]))
        let codable = try XCTUnwrap(CodableCGColor(color: color))
        XCTAssertEqual(codable.colorSpaceName, CGColorSpace.genericGrayGamma2_2 as String)
        XCTAssertEqual(codable.components, [0.75, 1.0])
    }

    func test_init_transparent() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let color = try XCTUnwrap(CGColor(colorSpace: colorSpace, components: [0.0, 0.0, 0.0, 0.0]))
        let codable = try XCTUnwrap(CodableCGColor(color: color))
        XCTAssertEqual(codable.components.last, 0.0)
    }

    // MARK: - color round-trip

    func test_color_sRGB_roundTrip() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let original = try XCTUnwrap(CGColor(colorSpace: colorSpace, components: [0.2, 0.4, 0.6, 0.8]))
        let codable = try XCTUnwrap(CodableCGColor(color: original))
        let reconstructed = try XCTUnwrap(codable.color)
        XCTAssertEqual(reconstructed.components, original.components)
        XCTAssertEqual(reconstructed.colorSpace?.name, original.colorSpace?.name)
    }

    func test_color_unknownColorSpaceName_returnsNil() throws {
        let codable = CodableCGColor(colorSpaceName: "not-a-real-color-space", components: [1.0, 0.0, 0.0, 1.0])
        XCTAssertNil(codable.color)
    }

    // MARK: - Codable round-trip

    func test_codable_roundTrip() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let color = try XCTUnwrap(CGColor(colorSpace: colorSpace, components: [1.0, 0.5, 0.0, 1.0]))
        let original = try XCTUnwrap(CodableCGColor(color: color))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(CodableCGColor.self, from: data)
        XCTAssertEqual(decoded.colorSpaceName, original.colorSpaceName)
        XCTAssertEqual(decoded.components, original.components)
    }
}

