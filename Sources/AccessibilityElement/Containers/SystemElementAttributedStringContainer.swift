//
//  SystemElementAttributedStringContainer.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import Foundation

public struct SystemElementAttributedStringContainer: Codable, Sendable {
    public struct AttributeRange: Codable, Sendable {
        public let range: NSRange
        public let attributes: [NSAttributedString.Key: SystemElementValueContainer]
    }

    public let string: String
    public let runs: [AttributeRange]

    public init(
        attributedString: NSAttributedString
    ) {
        self.string = attributedString.string
        var runs: [AttributeRange] = []

        let fullRange = NSRange(
            location: 0,
            length: attributedString.length
        )
        attributedString.enumerateAttributes(in: fullRange) { attributes, range, _ in
            var convertedAttributes: [NSAttributedString.Key: SystemElementValueContainer] = [:]
            convertedAttributes.reserveCapacity(attributes.count)

            for (key, value) in attributes {
                if let converted = try? SystemElementValueRepackager.repackage(value: value) {
                    convertedAttributes[key] = converted
                }
            }

            runs.append(
                AttributeRange(
                    range: range,
                    attributes: convertedAttributes
                )
            )
        }
        self.runs = runs
    }

    public var attributedString: NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        for run in runs {
            attributedString
                .setAttributes(
                    run.attributes.reduce(into: [NSAttributedString.Key:Any](), { $0[$1.key] = $1.value.value() }),
                    range: run.range
                )
        }
        return attributedString.copy() as! NSAttributedString
    }
}
