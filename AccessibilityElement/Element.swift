//
//  AccessibilityElement.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import Cocoa
import os.log

public extension NSAccessibilityRole {
    public static let webArea = NSAccessibilityRole(rawValue: "AXWebArea")
}

public extension NSAccessibilityAttributeName {
    public static let caretBrowsingEnabled = NSAccessibilityAttributeName(rawValue: "AXCaretBrowsingEnabled")
    public static let frame = NSAccessibilityAttributeName(rawValue: "AXFrame")
    public static let selectedTextMarkerRange = NSAccessibilityAttributeName(rawValue: "AXSelectedTextMarkerRange")
    public static let enhancedUserInterface = NSAccessibilityAttributeName(rawValue: "AXEnhancedUserInterface")
}

public protocol AnyElement {
    func role() throws -> NSAccessibilityRole
    func roleDescription() throws -> String
    func subrole() throws -> NSAccessibilitySubrole
    func value() throws -> Any
    func attributedString(range: Range<Int>) throws -> NSAttributedString
    func numberOfCharacters() throws -> Int
    func description() throws -> String
    func title() throws -> String
    func isKeyboardFocused() throws -> Bool
    func frame() throws -> Frame
    func caretBrowsingEnabled() throws -> Bool
    func set(caretBrowsing: Bool) throws
    func range<IndexType>(unorderedPositions: (first: Position<IndexType>, second: Position<IndexType>)) throws -> Range<Position<IndexType>>
    func attributedString<IndexType>(range: Range<Position<IndexType>>) throws -> AttributedString
    func enhancedUserInterface() throws -> Bool
    func set(enhancedUserInterface: Bool) throws
}

public protocol _Element : AnyElement, TreeElement, Hashable {
    func titleElement() throws -> Self
    func parent() throws -> Self
    func children() throws -> [Self]
    func topLevelElement() throws -> Self
    func applicationFocusedElement() throws -> Self
}

extension _Element {
    public func up() throws -> Self {
        return try parent()
    }
    public func down() throws -> [Self] {
        return try children()
    }
    private func `is`(_ r: NSAccessibilityRole) -> Bool {
        if let role = try? self.role() {
            return role == r
        }
        return false
    }
    public var isGroup: Bool {
        return `is`(.group)
    }
    public var isWindow: Bool {
        return `is`(.window)
    }
    public var isToolbar: Bool {
        return `is`(.toolbar)
    }
    public func hasTextRole() -> Bool {
        guard let role = try? self.role() else {
            return false
        }
        switch role {
        case .staticText:
            fallthrough
        case .textField:
            fallthrough
        case .textArea:
            return true
        default:
            return false
        }
    }
}

public struct Element : _Element {
    static var systemWide: Element = {
        Element(element: AXUIElement.systemWide())
    }()
    let element: AXUIElement
    public init(element: AXUIElement) {
        self.element = element
    }

    private func string(attribute: NSAccessibilityAttributeName) throws -> String {
        let value = try element.value(attribute: attribute)
        guard let string = value as? String else {
            throw AccessibilityError.typeMismatch
        }
        return string
    }
    private func axValue(attribute: NSAccessibilityAttributeName) throws -> AXValue {
        let value = try element.value(attribute: attribute)
        guard CFGetTypeID(value as CFTypeRef) == AXValueGetTypeID() else {
            throw AccessibilityError.typeMismatch
        }
        return value as! AXValue
    }
    private func frame(attribute: NSAccessibilityAttributeName) throws -> Frame {
        return Frame(rect: try axValue(attribute: attribute).rectValue())
    }
    private func number(attribute: NSAccessibilityAttributeName) throws -> NSNumber {
        let value = try element.value(attribute: attribute)
        guard let number = value as? NSNumber else {
            throw AccessibilityError.typeMismatch
        }
        return number
    }
    private func set(attribute: NSAccessibilityAttributeName, number: NSNumber) throws {
        try element.set(attribute: attribute, value: number)
    }
    private func bool(attribute: NSAccessibilityAttributeName) throws -> Bool {
        return try number(attribute: attribute).boolValue
    }
    private func set(attribute: NSAccessibilityAttributeName, bool: Bool) throws {
        try set(attribute: attribute, number: NSNumber(value: bool))
    }
    private func int(attribute: NSAccessibilityAttributeName) throws -> Int {
        return try number(attribute: attribute).intValue
    }
    private func element(attribute: NSAccessibilityAttributeName) throws -> Element {
        let value = try element.value(attribute: attribute)
        guard CFGetTypeID(value as CFTypeRef) == AXUIElementGetTypeID() else {
            throw AccessibilityError.typeMismatch
        }
        return Element(element: value as! AXUIElement)
    }
    private func elements(attribute: NSAccessibilityAttributeName) throws -> [Element] {
        let value = try element.value(attribute: attribute)
        guard let elements = value as? [AXUIElement]  else {
            throw AccessibilityError.typeMismatch
        }
        return elements.map() { element in
            return Element(element: element)
        }
    }
    private func range(attribute: NSAccessibilityAttributeName) throws -> Range<Int> {
        let value = try axValue(attribute: attribute)
        let cfRange = try value.rangeValue()
        return cfRange.location..<cfRange.location+cfRange.length
    }

    public func role() throws -> NSAccessibilityRole {
        return NSAccessibilityRole(rawValue: try string(attribute: .role))
    }
    public func roleDescription() throws -> String {
        return try string(attribute: .roleDescription)
    }
    public func subrole() throws -> NSAccessibilitySubrole {
        return NSAccessibilitySubrole(rawValue: try string(attribute: .subrole))
    }
    public func value() throws -> Any {
        return try element.value(attribute: .value)
    }
    public func description() throws -> String {
        return try string(attribute: .description)
    }
    public func title() throws -> String {
        return try string(attribute: .title)
    }
    public func titleElement() throws -> Element {
        return try element(attribute: .titleUIElement)
    }
    public func isKeyboardFocused() throws -> Bool {
        return try bool(attribute: .focused)
    }
    public func parent() throws -> Element {
        return try element(attribute: .parent)
    }
    public func children() throws -> [Element] {
        return try elements(attribute: .children)
    }
    public func attributedString(range: Range<Int>) throws -> NSAttributedString {
        let value = try element.parameterizedValue(attribute: .attributedStringForRange, parameter: AXValue.range(range))
        guard let string = value as? NSAttributedString else {
            throw AccessibilityError.typeMismatch
        }
        return string
    }
    public func numberOfCharacters() throws -> Int {
        return try int(attribute: .numberOfCharacters)
    }
    public func topLevelElement() throws -> Element {
        return try element(attribute: .topLevelUIElement)
    }
    public func applicationFocusedElement() throws -> Element {
        return try element(attribute: .focusedUIElement)
    }
    public func caretBrowsingEnabled() throws -> Bool {
        return try bool(attribute: NSAccessibilityAttributeName.caretBrowsingEnabled)
    }
    public func set(caretBrowsing: Bool) throws {
        try set(attribute: NSAccessibilityAttributeName.caretBrowsingEnabled, bool: caretBrowsing)
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
        let attribute = NSAccessibilityParameterizedAttributeName(rawValue: "AXTextMarkerRangeForUnorderedTextMarkers")
        let value = try element.parameterizedValue(attribute: attribute, parameter: [unorderedPositions.first.index, unorderedPositions.second.index])
        guard CFGetTypeID(value as CFTypeRef) == accessibility_element_get_marker_range_type_id() else {
            throw AccessibilityError.typeMismatch
        }
        let range = value as AXTextMarkerRange
        return Range(range, element: self) as! Range<Position<IndexType>>
    }
    public func attributedString<IndexType>(range: Range<Position<IndexType>>) throws -> AttributedString {
        if IndexType.self == Int.self {
            throw AccessibilityError.typeMismatch
        }
        guard let axTextMarkerRange = (range as! Range<Position<AXTextMarker>>).axTextMarkerRange else {
            throw AccessibilityError.invalidInput
        }
        let value = try element.parameterizedValue(attribute: NSAccessibilityParameterizedAttributeName(rawValue: "AXAttributedStringForTextMarkerRange"),
                                                   parameter: axTextMarkerRange)
        guard let attributedString = value as? NSAttributedString else {
            throw AccessibilityError.typeMismatch
        }
        return AttributedString(attributedString: attributedString)
    }
    public func enhancedUserInterface() throws -> Bool {
        return try bool(attribute: NSAccessibilityAttributeName.enhancedUserInterface)
    }
    public func set(enhancedUserInterface: Bool) throws {
        try set(attribute: NSAccessibilityAttributeName.enhancedUserInterface, bool: enhancedUserInterface)
    }

    public func frame() throws -> Frame {
        return try frame(attribute: NSAccessibilityAttributeName.frame)
    }

    public var processIdentifier: Int {
        return (try? self.element.processIdentifier()) ?? 0
    }
}

extension Element : Equatable {
    public static func ==(lhs: Element, rhs: Element) -> Bool {
        return CFEqual(lhs.element, rhs.element)
    }
}

extension Element : Hashable {
    public var hashValue: Int {
        return Int(CFHash(element))
    }
}

extension Element : CustomDebugStringConvertible {
    public var debugDescription: String {
        var components = [String]()
//        if let attributes = try? element.attributes() {
//            components.append(contentsOf: attributes.map({ $0.rawValue }))
//        }
        let describer = Describer<Element>()
        let requests: [DescriberRequest] = [
            Describer<Element>.Single(required: true, attribute: .role),
            Describer<Element>.Single(required: false, attribute: .subrole),
            Describer<Element>.Fallthrough(required: false, attributes: [.title, .description, .stringValue, .titleElement(Describer<Element>.Fallthrough(required: true, attributes: [.title, .description, .stringValue]))])
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
            return "<Element>"
        }
    }
}

extension Element : CustomDebugDictionaryConvertible {
    public var debugInfo: [String:CustomDebugStringConvertible] {
        var info = [NSAccessibilityAttributeName:String]()
        if let role = try? self.role().rawValue, role.count > 0 {
            info[.role] = role
        }
        if let subrole = try? self.subrole().rawValue, subrole.count > 0 {
            info[.subrole] = subrole
        }
        if let description = try? self.description(), description.count > 0 {
            info[.description] = description
        }
        if let title = try? self.title(), title.count > 0 {
            info[.title] = title
        }
        if hasTextRole(), let value = try? self.value(), let string = value as? String, string.count > 0 {
            info[.value] = string
        }
        return info.reduce() { result, pair in
            result[pair.key.rawValue] = pair.value
        }
    }
}
