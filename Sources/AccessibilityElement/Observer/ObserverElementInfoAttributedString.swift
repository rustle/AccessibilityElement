//
//  ObserverElementInfoAttributedString.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import Foundation

public struct ObserverElementInfoAttributedString: Sendable {
    public struct AttributeRange: Sendable {
        let range: NSRange
        let attributes: [NSAttributedString.Key:ObserverElementInfoValue]
    }

    public let string: String
    public let runs: [AttributeRange]

    init(
        attributedString: NSAttributedString,
        map: (Any) -> ObserverElementInfoValue?
    ) {
        self.string = attributedString.string
        var runs: [AttributeRange] = []

        let fullRange = NSRange(
            location: 0,
            length: attributedString.length
        )
        attributedString.enumerateAttributes(in: fullRange) { attributes, range, _ in
            var convertedAttributes: [NSAttributedString.Key: ObserverElementInfoValue] = [:]
            convertedAttributes.reserveCapacity(attributes.count)

            for (key, value) in attributes {
                if let converted = map(value) {
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
