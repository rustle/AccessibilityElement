//
//  CodableColorContainer.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import CoreGraphics

public struct CodableColorContainer: Codable {
    public enum ColorCodingKeys : String, CodingKey {
        case colorSpace
        case components
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ColorCodingKeys.self)
        guard let name = color.colorSpace?.name else {
            let context = EncodingError.Context(codingPath: [ColorCodingKeys.colorSpace],
                                                debugDescription: "Encoding colors without colorspace with explicit name not supported.")
            throw EncodingError.invalidValue(self,
                                             context)
        }
        guard let components = color.components else {
            let context = EncodingError.Context(codingPath: [ColorCodingKeys.components],
                                                debugDescription: "Encoding colors without components not supported.")
            throw EncodingError.invalidValue(self,
                                             context)
        }
        try container.encode(name as String,
                             forKey: .colorSpace)
        try container.encode(components,
                             forKey: .components)
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: ColorCodingKeys.self)
        guard let name = try values.decodeIfPresent(String.self,
                                                    forKey: .colorSpace) else {
            let context = EncodingError.Context(codingPath: [ColorCodingKeys.colorSpace],
                                                debugDescription: "Decoding colors without colorspace without explicit name not supported.")
            throw EncodingError.invalidValue(values,
                                             context)
        }
        guard let colorSpace = CGColorSpace(name: name as CFString) else {
            let context = EncodingError.Context(codingPath: [ColorCodingKeys.colorSpace],
                                                debugDescription: "Unsupported colorSpace name: \(name).")
            throw EncodingError.invalidValue(name,
                                             context)
        }
        guard let components = try values.decodeIfPresent([CGFloat].self,
                                                          forKey: .components) else {
            let context = EncodingError.Context(codingPath: [ColorCodingKeys.components],
                                                debugDescription: "Decoding colors without components not supported.")
            throw EncodingError.invalidValue(values,
                                             context)
        }
        color = components.withUnsafeBufferPointer {
            return CGColor(colorSpace: colorSpace,
                           components: $0.baseAddress!)!
        }
    }
    public let color: CGColor
    public init(color: CGColor) {
        self.color = color
    }
}
