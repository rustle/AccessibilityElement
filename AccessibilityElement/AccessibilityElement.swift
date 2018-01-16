//
//  AccessibilityElement.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import Cocoa
import os.log

public protocol TreeElement {
    func up() throws -> Self
    func down() throws -> [Self]
}

extension TreeElement where Self : Hashable {
    public func walk(_ visitor: (Self) -> Void) {
        var elements = [Self]()
        var visited = Set<Self>()
        elements.append(self)
        while elements.count > 0 {
            let element: Self = elements[0]
            elements.remove(at: 0)
            if !visited.contains(element) {
                do {
                    visitor(element)
                    let children = try element.down()
                    elements.append(contentsOf: children)
                } catch let error {
                    os_log("%@", error.localizedDescription)
                }
                visited.insert(element)
            }
        }
    }
}

public protocol _AccessibilityElement : TreeElement, Hashable {
    func role() throws -> NSAccessibilityRole
    func roleDescription() throws -> String
    func subrole() throws -> NSAccessibilitySubrole
    func value() throws -> Any
    func attributedString(range: Range<Int>) throws -> NSAttributedString
    func numberOfCharacters() throws -> Int
    func description() throws -> String
    func title() throws -> String
    func titleElement() throws -> Self
    func isKeyboardFocused() throws -> Bool
    func parent() throws -> Self
    func children() throws -> [Self]
    func topLevelUIElement() throws -> Self
}

extension _AccessibilityElement {
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

public struct Element : _AccessibilityElement {
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
    private func bool(attribute: NSAccessibilityAttributeName) throws -> Bool {
        return try number(attribute: attribute).boolValue
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
    public func topLevelUIElement() throws -> Element {
        return try element(attribute: .topLevelUIElement)
    }

    public struct Frame {
        public struct Point {
            public var x: Double
            public var y: Double
            public init(point: CGPoint) {
                self.x = Double(point.x)
                self.y = Double(point.y)
            }
        }
        public struct Size {
            public var width: Double
            public var height: Double
            public init(size: CGSize) {
                self.width = Double(size.width)
                self.height = Double(size.height)
            }
        }
        public var origin: Point
        public var size: Size
        public init(rect: CGRect) {
            self.origin = Point(point: rect.origin)
            self.size = Size(size: rect.size)
        }
        public mutating func inset(x: Double, y: Double) {
            origin.x += x
            origin.y += y
            size.width -= x * 2.0
            size.height -= y * 2.0
        }
    }
    public func frame() throws -> Frame {
        return try frame(attribute: NSAccessibilityAttributeName(rawValue: "AXFrame"))
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

extension Dictionary {
    func reduce<T, U>(_ updateAccumulatingResult: (inout [T:U], (key: Key, value: Value)) throws -> ()) rethrows -> [T:U] {
        return try reduce(into: [T:U](), updateAccumulatingResult)
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
