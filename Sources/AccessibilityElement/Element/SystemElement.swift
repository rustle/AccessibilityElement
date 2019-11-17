//
//  SystemElement.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Cocoa

public struct SystemElement: Element {
    public typealias ObserverProvidingType = SystemObserverProviding
    public static func systemWide() throws -> SystemElement {
        SystemElement(element: AXUIElement.systemWide())
    }
    public static func application(processIdentifier: ProcessIdentifier) throws -> SystemElement {
        SystemElement(element: AXUIElement.application(processIdentifier: processIdentifier))
    }

    internal let element: AXUIElement
    public init(element: AXUIElement) {
        self.element = element
    }

    private func string(attribute: NSAccessibility.Attribute) throws -> String {
        let value = try element.value(attribute: attribute)
        guard let string = value as? String else {
            throw AccessibilityError.typeMismatch
        }
        return string
    }
    private func axValue(attribute: NSAccessibility.Attribute) throws -> AXValue {
        let value = try element.value(attribute: attribute)
        guard CFGetTypeID(value as CFTypeRef) == AXValueGetTypeID() else {
            throw AccessibilityError.typeMismatch
        }
        return value as! AXValue
    }
    private func frame(attribute: NSAccessibility.Attribute) throws -> Frame {
        Frame(rect: try axValue(attribute: attribute).rectValue())
    }
    private func number(attribute: NSAccessibility.Attribute) throws -> NSNumber {
        let value = try element.value(attribute: attribute)
        guard let number = value as? NSNumber else {
            throw AccessibilityError.typeMismatch
        }
        return number
    }
    private func set(attribute: NSAccessibility.Attribute, number: NSNumber) throws {
        try element.set(attribute: attribute, value: number)
    }
    private func bool(attribute: NSAccessibility.Attribute) throws -> Bool {
        try number(attribute: attribute).boolValue
    }
    private func set(attribute: NSAccessibility.Attribute, bool: Bool) throws {
        try set(attribute: attribute, number: NSNumber(value: bool))
    }
    private func int(attribute: NSAccessibility.Attribute) throws -> Int {
        try number(attribute: attribute).intValue
    }
    private func element(attribute: NSAccessibility.Attribute) throws -> SystemElement {
        let value = try element.value(attribute: attribute)
        guard CFGetTypeID(value as CFTypeRef) == AXUIElementGetTypeID() else {
            throw AccessibilityError.typeMismatch
        }
        return SystemElement(element: value as! AXUIElement)
    }
    private func elements(attribute: NSAccessibility.Attribute) throws -> [SystemElement] {
        let value = try element.value(attribute: attribute)
        guard let elements = value as? [AXUIElement]  else {
            throw AccessibilityError.typeMismatch
        }
        return elements.map() { element in
            return SystemElement(element: element)
        }
    }
    private func range(attribute: NSAccessibility.Attribute) throws -> Range<Int> {
        let value = try axValue(attribute: attribute)
        let cfRange = try value.rangeValue()
        return cfRange.location..<cfRange.location+cfRange.length
    }
    private func textMarkerRange(attribute: NSAccessibility.Attribute) throws -> Range<Position<AXTextMarker>> {
        let value = try element.value(attribute: attribute)
        guard CFGetTypeID(value as CFTypeRef) == accessibility_element_get_marker_range_type_id() else {
            throw AccessibilityError.typeMismatch
        }
        return Range(value as AXTextMarkerRange, element: self)
    }
    private func position(attribute: NSAccessibility.Attribute) throws -> Position<AXTextMarker> {
        let value = try element.value(attribute: attribute)
        guard CFGetTypeID(value as CFTypeRef) == accessibility_element_get_marker_type_id() else {
            throw AccessibilityError.typeMismatch
        }
        return Position(index: value as AXTextMarker, element: self)
    }

    public func role() throws -> NSAccessibility.Role {
        NSAccessibility.Role(rawValue: try string(attribute: .role))
    }
    public func roleDescription() throws -> String {
        try string(attribute: .roleDescription)
    }
    public func subrole() throws -> NSAccessibility.Subrole {
        NSAccessibility.Subrole(rawValue: try string(attribute: .subrole))
    }
    public func value() throws -> Any {
        try element.value(attribute: .value)
    }
    public func string<IndexType>(range: Range<Position<IndexType>>) throws -> String {
        if let range = range as? Range<Position<Int>> {
            let value = try element.parameterizedValue(attribute: .stringForRange,
                                                       parameter: AXValue.range(range.lowerBound.index..<range.upperBound.index))
            guard let string = value as? String else {
                throw AccessibilityError.typeMismatch
            }
            return string
        }
        guard let axTextMarkerRange = (range as! Range<Position<AXTextMarker>>).axTextMarkerRange else {
            throw AccessibilityError.invalidInput
        }
        let value = try element.parameterizedValue(attribute: NSAccessibility.ParameterizedAttribute.stringForTextMarkerRange,
                                                   parameter: axTextMarkerRange)
        guard let string = value as? String else {
            throw AccessibilityError.typeMismatch
        }
        return string
    }
    public func attributedString<IndexType>(range: Range<Position<IndexType>>) throws -> AttributedString {
        if let range = range as? Range<Position<Int>> {
            let value = try element.parameterizedValue(attribute: .attributedStringForRange,
                                                       parameter: AXValue.range(range.lowerBound.index..<range.upperBound.index))
            guard let string = value as? NSAttributedString else {
                throw AccessibilityError.typeMismatch
            }
            return AttributedString(attributedString: string)
        }
        guard let axTextMarkerRange = (range as! Range<Position<AXTextMarker>>).axTextMarkerRange else {
            throw AccessibilityError.invalidInput
        }
        let value = try element.parameterizedValue(attribute: NSAccessibility.ParameterizedAttribute.attributedStringForTextMarkerRange,
                                                   parameter: axTextMarkerRange)
        guard let string = value as? NSAttributedString else {
            throw AccessibilityError.typeMismatch
        }
        return AttributedString(attributedString: string)
    }
    public func description() throws -> String {
        try string(attribute: .description)
    }
    public func title() throws -> String {
        try string(attribute: .title)
    }
    public func titleElement() throws -> SystemElement {
        try element(attribute: .titleUIElement)
    }
    public func isKeyboardFocused() throws -> Bool {
        try bool(attribute: .focused)
    }
    public func parent() throws -> SystemElement {
        try element(attribute: .parent)
    }
    public func children() throws -> [SystemElement] {
        try elements(attribute: .children)
    }
    public func numberOfCharacters() throws -> Int {
        try int(attribute: .numberOfCharacters)
    }
    public func topLevelElement() throws -> SystemElement {
        try element(attribute: .topLevelUIElement)
    }
    public func applicationFocusedElement() throws -> SystemElement {
        try element(attribute: .focusedUIElement)
    }
    public func caretBrowsingEnabled() throws -> Bool {
        try bool(attribute: NSAccessibility.Attribute.caretBrowsingEnabled)
    }
    public func set(caretBrowsing: Bool) throws {
        try set(attribute: NSAccessibility.Attribute.caretBrowsingEnabled, bool: caretBrowsing)
    }
    public func range<IndexType>(unorderedPositions: (first: Position<IndexType>, second: Position<IndexType>)) throws -> Range<Position<IndexType>> {
        if IndexType.self == Int.self {
            if unorderedPositions.first < unorderedPositions.second {
                return Range(uncheckedBounds: (unorderedPositions.first, unorderedPositions.second))
            }
            if unorderedPositions.second < unorderedPositions.first {
                return Range(uncheckedBounds: (unorderedPositions.second, unorderedPositions.first))
            }
            return Range(uncheckedBounds: (unorderedPositions.first, unorderedPositions.second))
        }
        let attribute = NSAccessibility.ParameterizedAttribute.textMarkerRangeForUnorderedTextMarkers
        let value = try element.parameterizedValue(attribute: attribute, parameter: [unorderedPositions.first.index, unorderedPositions.second.index])
        guard CFGetTypeID(value as CFTypeRef) == accessibility_element_get_marker_range_type_id() else {
            throw AccessibilityError.typeMismatch
        }
        let range = value as AXTextMarkerRange
        return Range(range, element: self) as! Range<Position<IndexType>>
    }
    public func first<IndexType>() throws -> Position<IndexType> {
        if IndexType.self == Int.self {
            throw ElementError.notImplemented
        } else if IndexType.self == AXTextMarker.self {
            return try position(attribute: .startTextMarker) as! Position<IndexType>
        }
        throw ElementError.notImplemented
    }
    public func last<IndexType>() throws -> Position<IndexType> {
        if IndexType.self == Int.self {
            throw ElementError.notImplemented
        } else if IndexType.self == AXTextMarker.self {
            return try position(attribute: .endTextMarker) as! Position<IndexType>
        }
        throw ElementError.notImplemented
    }
    public func enhancedUserInterface() throws -> Bool {
        return try bool(attribute: NSAccessibility.Attribute.enhancedUserInterface)
    }
    public func set(enhancedUserInterface: Bool) throws {
        try set(attribute: NSAccessibility.Attribute.enhancedUserInterface, bool: enhancedUserInterface)
    }
    public func selectedTextMarkerRanges() throws -> [Range<Position<AXTextMarker>>] {
        return [try textMarkerRange(attribute: .selectedTextMarkerRange)]
    }
    public func set(selectedTextMarkerRanges: [Range<Position<AXTextMarker>>]) throws {
        throw ElementError.notImplemented
    }

    public func frame() throws -> Frame {
        try frame(attribute: NSAccessibility.Attribute.frame)
    }

    public var processIdentifier: ProcessIdentifier {
        do {
            return try self.element.processIdentifier()
        } catch {
            return 0
        }
    }
}

extension SystemElement: Equatable {
    public static func ==(lhs: SystemElement,
                          rhs: SystemElement) -> Bool {
        CFEqual(lhs.element, rhs.element)
    }
}

extension SystemElement: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(Int(CFHash(element)))
    }
}

fileprivate let IncludeAttributesInDebug = false
fileprivate let IncludeParameterizedAttributesInDebug = false

extension SystemElement: CustomDebugStringConvertible {
    public var debugDescription: String {
        var components = [String]()
#if IncludeAttributesInDebug
        if let attributes = try? element.attributes() {
            components.append(contentsOf: attributes.map({ $0.rawValue }))
        }
#endif
#if IncludeParameterizedAttributesInDebug
        if let parameterizedAttributes = try? element.parameterizedAttributes() {
            components.append(contentsOf: parameterizedAttributes.map({ $0.rawValue }))
        }
#endif
        let describer = Describer<SystemElement>()
        let requests: [DescriberRequest] = [
            Describer<SystemElement>.Single(required: true, attribute: .role),
            Describer<SystemElement>.Single(required: false, attribute: .subrole),
            Describer<SystemElement>.Fallthrough(required: false, attributes: [.title, .description, .stringValue(30), .titleElement(Describer<SystemElement>.Fallthrough(required: true, attributes: [.title, .description, .stringValue(30)]))])
        ]
        do {
            let values = try describer.describe(element: self, requests: requests)
            for value in values {
                if let value = value {
                    components.append(value)
                }
            }
            return components.joined(separator: ", ")
        } catch {
            return "<SystemElement>"
        }
    }
}

extension SystemElement: Codable {
    public enum SystemElementCodingKeys: String, CodingKey {
        case element
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SystemElementCodingKeys.self)
        try container.encode(element.transportRepresentation(), forKey: .element)
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: SystemElementCodingKeys.self)
        element = AXUIElement.element(transportRepresentation: try values.decode(Data.self, forKey: .element))
    }
}

extension SystemElement: CustomDebugDictionaryConvertible {
    public var debugInfo: [String:CustomDebugStringConvertible] {
        var info = [String:CustomDebugStringConvertible]()
#if IncludeAttributesInDebug
        if let attributes = try? element.attributes() {
            info["attributes"] = attributes
        }
#endif
#if IncludeParameterizedAttributesInDebug
        if let parameterizedAttributes = try? element.parameterizedAttributes() {
            info["parameterizedAttributes"] = parameterizedAttributes
        }
#endif
        if let role = try? self.role().rawValue, role.count > 0 {
            info[NSAccessibility.Attribute.role.rawValue] = role
        }
        if let subrole = try? self.subrole().rawValue, subrole.count > 0 {
            info[NSAccessibility.Attribute.subrole.rawValue] = subrole
        }
        if let description = try? self.description(), description.count > 0 {
            info[NSAccessibility.Attribute.description.rawValue] = description
        }
        if let title = try? self.title(), title.count > 0 {
            info[NSAccessibility.Attribute.title.rawValue] = title
        }
        if hasTextRole(), let value = try? self.value(), let string = value as? String, string.count > 0 {
            info[NSAccessibility.Attribute.value.rawValue] = string
        }
        return info
    }
}
