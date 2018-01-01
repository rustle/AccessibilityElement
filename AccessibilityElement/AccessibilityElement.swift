//
//  AccessibilityElement.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import Cocoa
import os.log

public struct Element {
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
        let value = try element.value(attribute: NSAccessibilityAttributeName.role)
        guard CFGetTypeID(value as CFTypeRef) == AXValueGetTypeID() else {
            throw AccessibilityError.typeMismatch
        }
        return value as! AXValue
    }
    private func frame(attribute: NSAccessibilityAttributeName) throws -> Frame {
        return Frame(rect: try axValue(attribute: attribute).rectValue())
    }
    private func bool(attribute: NSAccessibilityAttributeName) throws -> Bool {
        let value = try element.value(attribute: attribute)
        guard let number = value as? NSNumber else {
            throw AccessibilityError.typeMismatch
        }
        return number.boolValue
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
    public func isKeyboardFocused() throws -> Bool {
        return try bool(attribute: .focused)
    }
    public func parent() throws -> Element {
        return try element(attribute: .parent)
    }
    public func children() throws -> [Element] {
        return try elements(attribute: .children)
    }

    public func hasTextRole() -> Bool {
        do {
            switch try self.role() {
            case .staticText:
                fallthrough
            case .textField:
                fallthrough
            case .textArea:
                return true
            default:
                return false
            }
        } catch {
            return false
        }
    }

    public struct Frame {
        public struct Point {
            public let x: Double
            public let y: Double
            init(point: CGPoint) {
                self.x = Double(point.x)
                self.y = Double(point.y)
            }
        }
        public struct Size {
            public let width: Double
            public let height: Double
            init(size: CGSize) {
                self.width = Double(size.width)
                self.height = Double(size.height)
            }
        }
        public let origin: Point
        public let size: Size
        init(rect: CGRect) {
            self.origin = Point(point: rect.origin)
            self.size = Size(size: rect.size)
        }
    }
    public func frame() throws -> Frame {
        return try frame(attribute: NSAccessibilityAttributeName(rawValue: "AXFrame"))
    }

    public var processIdentifier: Int {
        return (try? self.element.processIdentifier()) ?? 0
    }

    public func walk(_ visitor: (Element) -> Void) {
        var elements = [Element]()
        var visited = Set<Element>()
        elements.append(self)
        while elements.count > 0 {
            let element: Element = elements[0]
            elements.remove(at: 0)
            if !visited.contains(element) {
                do {
                    visitor(element)
                    elements.append(contentsOf: try element.children())
                } catch let error {
                    os_log("####---- %@", error.localizedDescription)
                }
                visited.insert(element)
            }
        }
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
        if let role = try? self.role().rawValue, role.count > 0 {
            components.append(role)
        }
        if let subrole = try? self.subrole().rawValue, subrole.count > 0 {
            components.append(subrole)
        }
        if let description = try? self.description(), description.count > 0 {
            components.append(description)
        }
        if let title = try? self.title(), title.count > 0 {
            components.append(title)
        }
        if hasTextRole(), let value = try? self.value(), let string = value as? String, string.count > 0 {
            components.append(string)
        }
        return components.joined(separator: ", ")
    }
}
