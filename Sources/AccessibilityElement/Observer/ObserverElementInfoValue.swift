//
//  ObserverElementInfoValue.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AX

public enum ObserverElementInfoValue: Sendable {
    case int(Int)
    case double(Double)
    case bool(Bool)
    case string(String)
    case attributedString(ObserverElementInfoAttributedString)
    case element(SystemElement)
    case axValue(AX.Value)
    case textMarker(TextMarker)
    case textMarkerRange(TextMarkerRange)
    case array([ObserverElementInfoValue])
    case dictionary([String:ObserverElementInfoValue])
    func value() -> Any {
        switch self {
        case let .int(value):
            value
        case let .double(value):
            value
        case let .bool(value):
            value
        case let .string(value):
            value
        case let .attributedString(value):
            value
        case let .element(value):
            value
        case let .axValue(value):
            value
        case let .textMarker(value):
            value
        case let .textMarkerRange(value):
            value
        case let .array(value):
            value
        case let .dictionary(value):
            value
        }
    }
}
