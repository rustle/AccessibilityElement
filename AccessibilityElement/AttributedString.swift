//
//  AttributedString.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import os.log

extension NSRange {
    func range() -> Range<Int> {
        return location ..< (location + length)
    }
}

extension Range where Bound == Int {
    func nsRange() -> NSRange {
        return NSMakeRange(lowerBound, count)
    }
}

public struct AttributedString : Equatable, CustomDebugStringConvertible {
    public enum Attribute {
        case textAlignment
        case font
        case foregroundColor
        case backgroundColor
        case underlineColor
        case strikethroughColor
        case underlineStyle
        case superscript
        case strikethrough
        case shadow
        case attachment
        case link
        case naturalLanguage
        case replacement
        case misspelled
        case markedMisspelled
        case autocorrected
        case listItemPrefix
        case listItemIndex
        case listItemLevel
    }
    fileprivate static func attributes(keys: [NSAttributedStringKey]) -> [Attribute] {
        var attributes = [Attribute]()
        for key in keys {
            switch key {
            case Key.textAlignment:
                attributes.append(.textAlignment)
            case Key.font:
                attributes.append(.font)
            case Key.foregroundColor:
                attributes.append(.foregroundColor)
            case Key.backgroundColor:
                attributes.append(.backgroundColor)
            case Key.underlineColor:
                attributes.append(.underlineColor)
            case Key.strikethroughColor:
                attributes.append(.strikethroughColor)
            case Key.underlineStyle:
                attributes.append(.underlineStyle)
            case Key.superscript:
                attributes.append(.superscript)
            case Key.strikethrough:
                attributes.append(.strikethrough)
            case Key.shadow:
                attributes.append(.shadow)
            case Key.attachment:
                attributes.append(.attachment)
            case Key.link:
                attributes.append(.link)
            case Key.naturalLanguage:
                attributes.append(.naturalLanguage)
            case Key.replacement:
                attributes.append(.replacement)
            case Key.misspelled:
                attributes.append(.misspelled)
            case Key.markedMisspelled:
                attributes.append(.markedMisspelled)
            case Key.autocorrected:
                attributes.append(.autocorrected)
            case Key.listItemPrefix:
                attributes.append(.listItemPrefix)
            case Key.listItemIndex:
                attributes.append(.listItemIndex)
            case Key.listItemLevel:
                attributes.append(.listItemLevel)
            default:
                continue
            }
        }
        return attributes
    }
    private struct Key {
        static let textAlignment = NSAttributedStringKey(rawValue: "AXTextAlignmentValue")
        static let font = NSAttributedStringKey(rawValue: kAXFontTextAttribute.takeUnretainedValue() as String) // [String:Any]
        static let foregroundColor = NSAttributedStringKey(rawValue: kAXForegroundColorTextAttribute.takeUnretainedValue() as String) // CGColor
        static let backgroundColor = NSAttributedStringKey(rawValue: kAXBackgroundColorTextAttribute.takeUnretainedValue() as String) // CGColor
        static let underlineColor = NSAttributedStringKey(rawValue: kAXUnderlineColorTextAttribute.takeUnretainedValue() as String) // CGColor
        static let strikethroughColor = NSAttributedStringKey(rawValue: kAXStrikethroughColorTextAttribute.takeUnretainedValue() as String) // CGColor
        static let underlineStyle = NSAttributedStringKey(rawValue: kAXUnderlineTextAttribute.takeUnretainedValue() as String) // CFNumber - AXUnderlineStyle
        static let superscript = NSAttributedStringKey(rawValue: kAXSuperscriptTextAttribute.takeUnretainedValue() as String) // CFNumber = + number for superscript - for subscript
        static let strikethrough = NSAttributedStringKey(rawValue: kAXStrikethroughTextAttribute.takeUnretainedValue() as String) // CFBoolean
        static let shadow = NSAttributedStringKey(rawValue: kAXShadowTextAttribute.takeUnretainedValue() as String) // CFBoolean
        static let attachment = NSAttributedStringKey(rawValue: kAXAttachmentTextAttribute.takeUnretainedValue() as String) // AXUIElement
        static let link = NSAttributedStringKey(rawValue: kAXLinkTextAttribute.takeUnretainedValue() as String) // AXUIElement
        static let naturalLanguage = NSAttributedStringKey(rawValue: kAXNaturalLanguageTextAttribute.takeUnretainedValue() as String) // String
        static let replacement = NSAttributedStringKey(rawValue: kAXReplacementStringTextAttribute.takeUnretainedValue() as String) // String
        static let misspelled = NSAttributedStringKey(rawValue: kAXMisspelledTextAttribute.takeUnretainedValue() as String) // CFBoolean
        static let markedMisspelled = NSAttributedStringKey(rawValue: kAXMarkedMisspelledTextAttribute.takeUnretainedValue() as String) // CFBoolean
        static let autocorrected = NSAttributedStringKey(rawValue: kAXAutocorrectedTextAttribute.takeUnretainedValue() as String) // CFBoolean
        static let listItemPrefix = NSAttributedStringKey(rawValue: kAXListItemPrefixTextAttribute.takeUnretainedValue() as String) // CFAttributedString
        static let listItemIndex = NSAttributedStringKey(rawValue: kAXListItemIndexTextAttribute.takeUnretainedValue() as String) // CFNumber
        static let listItemLevel = NSAttributedStringKey(rawValue: kAXListItemLevelTextAttribute.takeUnretainedValue() as String) // CFNumber
    }
    public struct Font : Equatable, CustomDebugStringConvertible {
        fileprivate struct Key {
            static let name = kAXFontNameKey.takeUnretainedValue() as String // String
            static let family = kAXFontFamilyKey.takeUnretainedValue() as String // String
            static let visibleName = kAXVisibleNameKey.takeUnretainedValue() as String // String
            static let size = kAXFontSizeKey.takeUnretainedValue() as String // CFNumber
        }
        public var name: String
        public var size: Int
        public var family: String?
        public var visibleName: String?
        fileprivate init?(_ values: [String:Any]) {
            var n: String?
            var s: Int?
            for (key, value) in values {
                switch key {
                case Key.name:
                    if let string = value as? String {
                        n = string
                    }
                case Key.size:
                    if let int = value as? Int {
                        s = int
                    }
                case Key.family:
                    family = value as? String
                case Key.visibleName:
                    visibleName = value as? String
                default:
                    continue
                }
            }
            guard let name = n, let size = s else {
                return nil
            }
            self.name = name
            self.size = size
        }
        public var debugDescription: String {
            var components = [String]()
            components.append("Name; \(name)")
            components.append("Size: \(size)")
            if let family = family {
                components.append("Family: \(family)")
            }
            if let visibleName = visibleName {
                components.append("VisibleName: \(visibleName)")
            }
            return "Font \(components.joined(separator: ", "))"
        }
        public static func ==(lhs: AttributedString.Font, rhs: AttributedString.Font) -> Bool {
            return
                lhs.name == rhs.name &&
                lhs.family == rhs.family &&
                lhs.size == rhs.size &&
                lhs.visibleName == rhs.visibleName
        }
    }
    fileprivate class Impl {
        fileprivate var readOnly: NSMutableAttributedString
        var writeOnly: NSMutableAttributedString {
            if !isKnownUniquelyReferenced(&readOnly) {
                readOnly = readOnly.mutableCopy() as! NSMutableAttributedString
            }
            return readOnly
        }
        init(_ value: NSAttributedString) {
            readOnly = value.mutableCopy() as! NSMutableAttributedString
        }
    }
    fileprivate var impl: Impl
    public var count: Int {
        return impl.readOnly.length
    }
    public var string: String {
        return impl.readOnly.string
    }
    // TODO: These are just guesses
    public enum TextAlignment : Int {
        case left
        case center
        case right
        case justified
    }
    public typealias UnderlineStyle = AXUnderlineStyle
    public func textAlignment(at: Int) -> TextAlignment? {
        guard let value = impl.writeOnly.attribute(Key.textAlignment, at: at, effectiveRange: nil) else {
            return nil
        }
        guard let int = value as? Int else {
            return nil
        }
        return TextAlignment(rawValue: int)
    }
    public mutating func set(textAlignment: TextAlignment, range: Range<Int>) {
        impl.writeOnly.setAttributes([Key.textAlignment:NSNumber(value: textAlignment.rawValue)], range: range.nsRange())
    }
    public func font(at: Int) -> Font? {
        guard let value = impl.readOnly.attribute(Key.font, at: at, effectiveRange: nil) else {
            return nil
        }
        guard let fontDictionary = value as? [String:Any] else {
            return nil
        }
        return Font(fontDictionary)
    }
    public mutating func set(font: Font, range: Range<Int>) {
        var dictionary = [String:Any]()
        dictionary[Font.Key.name] = font.name
        dictionary[Font.Key.size] = NSNumber(value: font.size)
        if let family = font.family {
            dictionary[Font.Key.family] = family
        }
        if let visibleName = font.visibleName {
            dictionary[Font.Key.visibleName] = visibleName
        }
        impl.writeOnly.setAttributes([Key.font:dictionary], range: range.nsRange())
    }
    public func foregroundColor(at: Int) -> CGColor? {
        return color(Key.font, at: at)
    }
    public mutating func set(foregroundColor: CGColor, range: Range<Int>) {
        set(key: Key.foregroundColor, range: range, color: foregroundColor)
    }
    public func backgroundColor(at: Int) -> CGColor? {
        return color(Key.backgroundColor, at: at)
    }
    public mutating func set(backgroundColor: CGColor, range: Range<Int>) {
        set(key: Key.backgroundColor, range: range, color: backgroundColor)
    }
    public func underlineColor(at: Int) -> CGColor? {
        return color(Key.underlineColor, at: at)
    }
    public mutating func set(underlineColor: CGColor, range: Range<Int>) {
        set(key: Key.underlineColor, range: range, color: underlineColor)
    }
    public func strikethroughColor(at: Int) -> CGColor? {
        return color(Key.strikethroughColor, at: at)
    }
    public mutating func set(strikethroughColor: CGColor, range: Range<Int>) {
        set(key: Key.strikethroughColor, range: range, color: strikethroughColor)
    }
    public func underlineStyle(at: Int) -> UnderlineStyle? {
        guard let int = int(Key.underlineStyle, at: at) else {
            return nil
        }
        return UnderlineStyle(rawValue: UInt32(int))
    }
    public mutating func set(underlineStyle: UnderlineStyle, range: Range<Int>) {
        set(key: Key.underlineStyle, range: range, int:Int(underlineStyle.rawValue))
    }
    public func superscript(at: Int) -> Int? {
        return int(Key.superscript, at: at)
    }
    public mutating func set(superscript: Int?, range: Range<Int>) {
        set(key: Key.superscript, range: range, int: superscript)
    }
    public func strikethrough(at: Int) -> Bool? {
        return bool(Key.strikethrough, at: at)
    }
    public mutating func set(strikethrough: Bool?, range: Range<Int>) {
        set(key: Key.strikethrough, range: range, bool: strikethrough)
    }
    public func shadow(at: Int) -> Bool? {
        return bool(Key.shadow, at: at)
    }
    public mutating func set(shadow: Bool?, range: Range<Int>) {
        set(key: Key.shadow, range: range, bool: shadow)
    }
    public func attachment(at: Int) -> AccessibilityElement.Element? {
        return element(Key.attachment, at: at)
    }
    public mutating func set(attachment: AccessibilityElement.Element?, range: Range<Int>) {
        set(key: Key.attachment, range: range, element: attachment)
    }
    public func link(at: Int) -> Element? {
        return element(Key.link, at: at)
    }
    public mutating func set(link: Element?, range: Range<Int>) {
        set(key: Key.link, range: range, element: link)
    }
    public func naturalLanguage(at: Int) -> String? {
        return string(Key.naturalLanguage, at: at)
    }
    public mutating func set(naturalLanguage: String?, range: Range<Int>) {
        set(key: Key.link, range: range, string: naturalLanguage)
    }
    public func replacement(at: Int) -> String? {
        return string(Key.replacement, at: at)
    }
    public mutating func set(replacement: String?, range: Range<Int>) {
        set(key: Key.link, range: range, string: replacement)
    }
    public func misspelled(at: Int) -> Bool? {
        return bool(Key.misspelled, at: at)
    }
    public mutating func set(misspelled: Bool?, range: Range<Int>) {
        set(key: Key.misspelled, range: range, bool: misspelled)
    }
    public func markedMisspelled(at: Int) -> Bool? {
        return bool(Key.markedMisspelled, at: at)
    }
    public mutating func set(markedMisspelled: Bool?, range: Range<Int>) {
        set(key: Key.markedMisspelled, range: range, bool: markedMisspelled)
    }
    public func autocorrected(at: Int) -> Bool? {
        return bool(Key.autocorrected, at: at)
    }
    public mutating func set(autocorrected: Bool?, range: Range<Int>) {
        set(key: Key.autocorrected, range: range, bool: autocorrected)
    }
//    static let listItemPrefix = NSAttributedStringKey(rawValue: kAXListItemPrefixTextAttribute.takeUnretainedValue() as String) // CFAttributedString
    public func listItemIndex(at: Int) -> Int? {
        return int(Key.listItemIndex, at: at)
    }
    public mutating func set(listItemIndex: Int?, range: Range<Int>) {
        set(key: Key.listItemIndex, range: range, int: listItemIndex)
    }
    public func listItemLevel(at: Int) -> Int? {
        return int(Key.listItemLevel, at: at)
    }
    public mutating func set(listItemLevel: Int?, range: Range<Int>) {
        set(key: Key.listItemLevel, range: range, int: listItemLevel)
    }
    // MARK: -
    public init(attributedString: NSAttributedString) {
        impl = Impl(attributedString)
    }
    public static func ==(lhs: AttributedString, rhs: AttributedString) -> Bool {
        return false
    }
    public var debugDescription: String {
        return "\(impl.readOnly)"
    }
    // MARK: Helpers
    private func string(_ key: NSAttributedStringKey, at: Int) -> String? {
        guard let value = impl.readOnly.attribute(key, at: at, effectiveRange: nil) else {
            return nil
        }
        return value as? String
    }
    private mutating func set(key: NSAttributedStringKey, range: Range<Int>, string: String?) {
        if let string = string {
            impl.writeOnly.setAttributes([key:string], range: range.nsRange())
        } else {
            impl.writeOnly.removeAttribute(key, range: range.nsRange())
        }
    }
    private func int(_ key: NSAttributedStringKey, at: Int) -> Int? {
        guard let value = impl.readOnly.attribute(key, at: at, effectiveRange: nil) else {
            return nil
        }
        return (value as? NSNumber)?.intValue
    }
    private mutating func set(key: NSAttributedStringKey, range: Range<Int>, int: Int?) {
        if let int = int {
            impl.writeOnly.setAttributes([key:NSNumber(value: int)], range: range.nsRange())
        } else {
            impl.writeOnly.removeAttribute(key, range: range.nsRange())
        }
    }
    private func color(_ key: NSAttributedStringKey, at: Int) -> CGColor? {
        guard let value = impl.readOnly.attribute(key, at: at, effectiveRange: nil) else {
            return nil
        }
        guard CFGetTypeID(value as CFTypeRef) == CGColor.typeID else {
            return nil
        }
        return (value as! CGColor)
    }
    private mutating func set(key: NSAttributedStringKey, range: Range<Int>, color: CGColor?) {
        if let color = color {
            impl.writeOnly.setAttributes([key:color], range: range.nsRange())
        } else {
            impl.writeOnly.removeAttribute(key, range: range.nsRange())
        }
    }
    private func element(_ key: NSAttributedStringKey, at: Int) -> Element? {
        guard let value = impl.readOnly.attribute(key, at: at, effectiveRange: nil) else {
            return nil
        }
        guard CFGetTypeID(value as CFTypeRef) == AXUIElement.typeID else {
            return nil
        }
        return AccessibilityElement.Element(element: (value as! AXUIElement))
    }
    private mutating func set(key: NSAttributedStringKey, range: Range<Int>, element: Element?) {
        if let element = element {
            impl.writeOnly.setAttributes([key:element.element], range: range.nsRange())
        } else {
            impl.writeOnly.removeAttribute(key, range: range.nsRange())
        }
    }
    private func bool(_ key: NSAttributedStringKey, at: Int) -> Bool? {
        guard let value = impl.readOnly.attribute(key, at: at, effectiveRange: nil) else {
            return nil
        }
        guard CFGetTypeID(value as CFTypeRef) == CFBoolean.typeID else {
            return nil
        }
        return CFBooleanGetValue(value as! CFBoolean)
    }
    private mutating func set(key: NSAttributedStringKey, range: Range<Int>, bool: Bool?) {
        if let bool = bool {
            let value = (bool ? kCFBooleanTrue : kCFBooleanFalse) as Any
            impl.writeOnly.setAttributes([key:value], range: range.nsRange())
        } else {
            impl.writeOnly.removeAttribute(key, range: range.nsRange())
        }
    }
}

public struct AttributedStringIterator : IteratorProtocol {
    private let string: AttributedString
    fileprivate init(string: AttributedString) {
        self.string = string
        currentRange = NSMakeRange(0, string.count)
    }
    private var currentRange: NSRange?
    public mutating func next() -> (Range<Int>, [AttributedString.Attribute])? {
        guard let current = currentRange else {
            return nil
        }
        var attributes = [AttributedString.Attribute]()
        var next: NSRange?
        string.impl.readOnly.enumerateAttributes(in: current, options: []) { attributesDictionary, range, stop in
            next = range
            attributes = AttributedString.attributes(keys: Array<NSAttributedStringKey>(attributesDictionary.keys))
            stop.initialize(to: true)
        }
        if let next = next {
            let max = NSMaxRange(next)
            currentRange = NSMakeRange(max, string.count - max)
            return (next.range(), attributes)
        } else {
            currentRange = nil
            return nil
        }
    }
}

extension AttributedString : Sequence {
    public func makeIterator() -> AttributedStringIterator {
        return AttributedStringIterator(string: self)
    }
}
