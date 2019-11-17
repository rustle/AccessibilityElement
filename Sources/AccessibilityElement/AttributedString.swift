//
//  AttributedString.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Foundation

fileprivate extension NSRange {
    func range() -> Range<Int> {
        return location ..< (location + length)
    }
}

fileprivate extension Range where Bound == Int {
    func nsRange() -> NSRange {
        return NSMakeRange(lowerBound, count)
    }
}

public struct AttributedString: Equatable {
    public typealias Key = NSAttributedString.Key
    private enum Error : Swift.Error {
        case unknownKey
    }
    private static func stringEnumToEnum(_ key: Key) throws -> Attribute {
        switch key {
        case Keys.textAlignment:
            return .textAlignment
        case Keys.font:
            return .font
        case Keys.foregroundColor:
            return .foregroundColor
        case Keys.backgroundColor:
            return .backgroundColor
        case Keys.underlineColor:
            return .underlineColor
        case Keys.strikethroughColor:
            return .strikethroughColor
        case Keys.underlineStyle:
            return .underlineStyle
        case Keys.superscript:
            return .superscript
        case Keys.strikethrough:
            return .strikethrough
        case Keys.shadow:
            return .shadow
        case Keys.attachment:
            return .attachment
        case Keys.link:
            return .link
        case Keys.naturalLanguage:
            return .naturalLanguage
        case Keys.replacement:
            return .replacement
        case Keys.misspelled:
            return .misspelled
        case Keys.markedMisspelled:
            return .markedMisspelled
        case Keys.autocorrected:
            return .autocorrected
        case Keys.listItemPrefix:
            return .listItemPrefix
        case Keys.listItemIndex:
            return .listItemIndex
        case Keys.listItemLevel:
            return .listItemLevel
        default:
            throw AttributedString.Error.unknownKey
        }
    }
    private static func enumToStringEnum(_ key: Attribute) -> NSAttributedString.Key {
        switch key {
        case .textAlignment:
            return Keys.textAlignment
        case .font:
            return Keys.font
        case .foregroundColor:
            return Keys.foregroundColor
        case .backgroundColor:
            return Keys.backgroundColor
        case .underlineColor:
            return Keys.underlineColor
        case .strikethroughColor:
            return Keys.strikethroughColor
        case .underlineStyle:
            return Keys.underlineStyle
        case .superscript:
            return Keys.superscript
        case .strikethrough:
            return Keys.strikethrough
        case .shadow:
            return Keys.shadow
        case .attachment:
            return Keys.attachment
        case .link:
            return Keys.link
        case .naturalLanguage:
            return Keys.naturalLanguage
        case .replacement:
            return Keys.replacement
        case .misspelled:
            return Keys.misspelled
        case .markedMisspelled:
            return Keys.markedMisspelled
        case .autocorrected:
            return Keys.autocorrected
        case .listItemPrefix:
            return Keys.listItemPrefix
        case .listItemIndex:
            return Keys.listItemIndex
        case .listItemLevel:
            return Keys.listItemLevel
        }
    }
    public enum Attribute: Codable {
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
        private enum AttributeCodingKeys : String, CodingKey {
            case value
        }
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: AttributeCodingKeys.self)
            try container.encode(AttributedString.enumToStringEnum(self).rawValue, forKey: .value)
        }
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: AttributeCodingKeys.self)
            let value = try values.decode(String.self, forKey: .value)
            let key = NSAttributedString.Key(rawValue: value)
            self = try AttributedString.stringEnumToEnum(key)
        }
    }
    fileprivate static func attributes(keys: [NSAttributedString.Key]) -> [Attribute] {
        var attributes = [Attribute]()
        for key in keys {
            if let value = try? stringEnumToEnum(key) {
                attributes.append(value)
            }
        }
        return attributes
    }
    private struct Keys {
        static let textAlignment = NSAttributedString.Key(rawValue: "AXTextAlignmentValue")
        static let font = NSAttributedString.Key(rawValue: kAXFontTextAttribute.takeUnretainedValue() as String) // [String:Any]
        static let foregroundColor = NSAttributedString.Key(rawValue: kAXForegroundColorTextAttribute.takeUnretainedValue() as String) // CGColor
        static let backgroundColor = NSAttributedString.Key(rawValue: kAXBackgroundColorTextAttribute.takeUnretainedValue() as String) // CGColor
        static let underlineColor = NSAttributedString.Key(rawValue: kAXUnderlineColorTextAttribute.takeUnretainedValue() as String) // CGColor
        static let strikethroughColor = NSAttributedString.Key(rawValue: kAXStrikethroughColorTextAttribute.takeUnretainedValue() as String) // CGColor
        static let underlineStyle = NSAttributedString.Key(rawValue: kAXUnderlineTextAttribute.takeUnretainedValue() as String) // CFNumber - AXUnderlineStyle
        static let superscript = NSAttributedString.Key(rawValue: kAXSuperscriptTextAttribute.takeUnretainedValue() as String) // CFNumber = + number for superscript - for subscript
        static let strikethrough = NSAttributedString.Key(rawValue: kAXStrikethroughTextAttribute.takeUnretainedValue() as String) // CFBoolean
        static let shadow = NSAttributedString.Key(rawValue: kAXShadowTextAttribute.takeUnretainedValue() as String) // CFBoolean
        static let attachment = NSAttributedString.Key(rawValue: kAXAttachmentTextAttribute.takeUnretainedValue() as String) // AXUIElement
        static let link = NSAttributedString.Key(rawValue: kAXLinkTextAttribute.takeUnretainedValue() as String) // AXUIElement
        static let naturalLanguage = NSAttributedString.Key(rawValue: kAXNaturalLanguageTextAttribute.takeUnretainedValue() as String) // String
        static let replacement = NSAttributedString.Key(rawValue: kAXReplacementStringTextAttribute.takeUnretainedValue() as String) // String
        static let misspelled = NSAttributedString.Key(rawValue: kAXMisspelledTextAttribute.takeUnretainedValue() as String) // CFBoolean
        static let markedMisspelled = NSAttributedString.Key(rawValue: kAXMarkedMisspelledTextAttribute.takeUnretainedValue() as String) // CFBoolean
        static let autocorrected = NSAttributedString.Key(rawValue: kAXAutocorrectedTextAttribute.takeUnretainedValue() as String) // CFBoolean
        static let listItemPrefix = NSAttributedString.Key(rawValue: kAXListItemPrefixTextAttribute.takeUnretainedValue() as String) // CFAttributedString
        static let listItemIndex = NSAttributedString.Key(rawValue: kAXListItemIndexTextAttribute.takeUnretainedValue() as String) // CFNumber
        static let listItemLevel = NSAttributedString.Key(rawValue: kAXListItemLevelTextAttribute.takeUnretainedValue() as String) // CFNumber
    }
    public struct Font : Equatable, Codable {
        struct Keys {
            static let name = kAXFontNameKey.takeUnretainedValue() as String // String
            static let family = kAXFontFamilyKey.takeUnretainedValue() as String // String
            static let visibleName = kAXVisibleNameKey.takeUnretainedValue() as String // String
            static let size = kAXFontSizeKey.takeUnretainedValue() as String // CFNumber
        }
        public var name: String
        public var size: Int
        public var family: String?
        public var visibleName: String?
        init?(_ values: [String:Any]) {
            var n: String?
            var s: Int?
            for (key, value) in values {
                switch key {
                case Keys.name:
                    if let string = value as? String {
                        n = string
                    }
                case Keys.size:
                    if let int = value as? Int {
                        s = int
                    } else if let double = value as? Double {
                        s = Int(double)
                    } else if let float = value as? Float {
                        s = Int(float)
                    }
                case Keys.family:
                    family = value as? String
                case Keys.visibleName:
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
        public static func ==(lhs: AttributedString.Font, rhs: AttributedString.Font) -> Bool {
            return
                lhs.name == rhs.name &&
                lhs.family == rhs.family &&
                lhs.size == rhs.size &&
                lhs.visibleName == rhs.visibleName
        }
    }
    fileprivate class Implementation {
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
    fileprivate var implementation: Implementation
    public var count: Int {
        return implementation.readOnly.length
    }
    public var string: String {
        return implementation.readOnly.string
    }
    // TODO: These are just guesses
    public enum TextAlignment : Int, Codable {
        case left
        case center
        case right
        case justified
    }
    public typealias UnderlineStyle = AXUnderlineStyle
    public func textAlignment(at: Int) -> TextAlignment? {
        guard let value = implementation.readOnly.attribute(Keys.textAlignment, at: at, effectiveRange: nil) else {
            return nil
        }
        guard let int = value as? Int else {
            return nil
        }
        return TextAlignment(rawValue: int)
    }
    public mutating func set(textAlignment: TextAlignment, range: Range<Int>) {
        implementation.writeOnly.setAttributes([Keys.textAlignment:NSNumber(value: textAlignment.rawValue)], range: range.nsRange())
    }
    public func font(at: Int) -> Font? {
        guard let value = implementation.readOnly.attribute(Keys.font, at: at, effectiveRange: nil) else {
            return nil
        }
        guard let fontDictionary = value as? [String:Any] else {
            return nil
        }
        return Font(fontDictionary)
    }
    public mutating func set(font: Font, range: Range<Int>) {
        var dictionary = [String:Any]()
        dictionary[Font.Keys.name] = font.name
        dictionary[Font.Keys.size] = NSNumber(value: font.size)
        if let family = font.family {
            dictionary[Font.Keys.family] = family
        }
        if let visibleName = font.visibleName {
            dictionary[Font.Keys.visibleName] = visibleName
        }
        implementation.writeOnly.setAttributes([Keys.font:dictionary], range: range.nsRange())
    }
    public func foregroundColor(at: Int) -> CGColor? {
        return color(Keys.font, at: at)
    }
    public mutating func set(foregroundColor: CGColor, range: Range<Int>) {
        set(key: Keys.foregroundColor, range: range, color: foregroundColor)
    }
    public func backgroundColor(at: Int) -> CGColor? {
        return color(Keys.backgroundColor, at: at)
    }
    public mutating func set(backgroundColor: CGColor, range: Range<Int>) {
        set(key: Keys.backgroundColor, range: range, color: backgroundColor)
    }
    public func underlineColor(at: Int) -> CGColor? {
        return color(Keys.underlineColor, at: at)
    }
    public mutating func set(underlineColor: CGColor, range: Range<Int>) {
        set(key: Keys.underlineColor, range: range, color: underlineColor)
    }
    public func strikethroughColor(at: Int) -> CGColor? {
        return color(Keys.strikethroughColor, at: at)
    }
    public mutating func set(strikethroughColor: CGColor, range: Range<Int>) {
        set(key: Keys.strikethroughColor, range: range, color: strikethroughColor)
    }
    public func underlineStyle(at: Int) -> UnderlineStyle? {
        guard let int = int(Keys.underlineStyle, at: at) else {
            return nil
        }
        return UnderlineStyle(rawValue: UInt32(int))
    }
    public mutating func set(underlineStyle: UnderlineStyle, range: Range<Int>) {
        set(key: Keys.underlineStyle, range: range, int:Int(underlineStyle.rawValue))
    }
    public func superscript(at: Int) -> Int? {
        return int(Keys.superscript, at: at)
    }
    public mutating func set(superscript: Int?, range: Range<Int>) {
        set(key: Keys.superscript, range: range, int: superscript)
    }
    public func strikethrough(at: Int) -> Bool? {
        return bool(Keys.strikethrough, at: at)
    }
    public mutating func set(strikethrough: Bool?, range: Range<Int>) {
        set(key: Keys.strikethrough, range: range, bool: strikethrough)
    }
    public func shadow(at: Int) -> Bool? {
        return bool(Keys.shadow, at: at)
    }
    public mutating func set(shadow: Bool?, range: Range<Int>) {
        set(key: Keys.shadow, range: range, bool: shadow)
    }
    public func attachment(at: Int) -> SystemElement? {
        return element(Keys.attachment, at: at)
    }
    public mutating func set(attachment: SystemElement?, range: Range<Int>) {
        set(key: Keys.attachment, range: range, element: attachment)
    }
    public func link(at: Int) -> SystemElement? {
        return element(Keys.link, at: at)
    }
    public mutating func set(link: SystemElement?, range: Range<Int>) {
        set(key: Keys.link, range: range, element: link)
    }
    public func naturalLanguage(at: Int) -> String? {
        return string(Keys.naturalLanguage, at: at)
    }
    public mutating func set(naturalLanguage: String?, range: Range<Int>) {
        set(key: Keys.link, range: range, string: naturalLanguage)
    }
    public func replacement(at: Int) -> String? {
        return string(Keys.replacement, at: at)
    }
    public mutating func set(replacement: String?, range: Range<Int>) {
        set(key: Keys.link, range: range, string: replacement)
    }
    public func misspelled(at: Int) -> Bool? {
        return bool(Keys.misspelled, at: at)
    }
    public mutating func set(misspelled: Bool?, range: Range<Int>) {
        set(key: Keys.misspelled, range: range, bool: misspelled)
    }
    public func markedMisspelled(at: Int) -> Bool? {
        return bool(Keys.markedMisspelled, at: at)
    }
    public mutating func set(markedMisspelled: Bool?, range: Range<Int>) {
        set(key: Keys.markedMisspelled, range: range, bool: markedMisspelled)
    }
    public func autocorrected(at: Int) -> Bool? {
        return bool(Keys.autocorrected, at: at)
    }
    public mutating func set(autocorrected: Bool?, range: Range<Int>) {
        set(key: Keys.autocorrected, range: range, bool: autocorrected)
    }
    public func listItemPrefix(at: Int) -> AttributedString? {
        return attributedString(Keys.listItemPrefix, at: at)
    }
    public mutating func set(listItemPrefix: AttributedString?, range: Range<Int>) {
        
    }
    public func listItemIndex(at: Int) -> Int? {
        return int(Keys.listItemIndex, at: at)
    }
    public mutating func set(listItemIndex: Int?, range: Range<Int>) {
        set(key: Keys.listItemIndex, range: range, int: listItemIndex)
    }
    public func listItemLevel(at: Int) -> Int? {
        return int(Keys.listItemLevel, at: at)
    }
    public mutating func set(listItemLevel: Int?, range: Range<Int>) {
        set(key: Keys.listItemLevel, range: range, int: listItemLevel)
    }
    // MARK: -
    public init(attributedString: NSAttributedString) {
        implementation = Implementation(attributedString)
    }
    public static func ==(lhs: AttributedString, rhs: AttributedString) -> Bool {
        return false
    }
    // MARK: Helpers
    private func string(_ key: NSAttributedString.Key, at: Int) -> String? {
        guard let value = implementation.readOnly.attribute(key, at: at, effectiveRange: nil) else {
            return nil
        }
        return value as? String
    }
    private mutating func set(key: NSAttributedString.Key, range: Range<Int>, string: String?) {
        if let string = string {
            implementation.writeOnly.setAttributes([key:string], range: range.nsRange())
        } else {
            implementation.writeOnly.removeAttribute(key, range: range.nsRange())
        }
    }
    private func attributedString(_ key: NSAttributedString.Key, at: Int) -> AttributedString? {
        guard let value = implementation.readOnly.attribute(key, at: at, effectiveRange: nil) else {
            return nil
        }
        guard let attributedString = value as? NSAttributedString else {
            return nil
        }
        return AttributedString(attributedString: attributedString)
    }
    private mutating func set(key: NSAttributedString.Key, range: Range<Int>, attributedString: AttributedString?) {
        if let attributedString = attributedString {
            implementation.writeOnly.setAttributes([key:attributedString.implementation.readOnly], range: range.nsRange())
        } else {
            implementation.writeOnly.removeAttribute(key, range: range.nsRange())
        }
    }
    private func int(_ key: NSAttributedString.Key, at: Int) -> Int? {
        guard let value = implementation.readOnly.attribute(key, at: at, effectiveRange: nil) else {
            return nil
        }
        return (value as? NSNumber)?.intValue
    }
    private mutating func set(key: NSAttributedString.Key, range: Range<Int>, int: Int?) {
        if let int = int {
            implementation.writeOnly.setAttributes([key:NSNumber(value: int)], range: range.nsRange())
        } else {
            implementation.writeOnly.removeAttribute(key, range: range.nsRange())
        }
    }
    private func color(_ key: NSAttributedString.Key, at: Int) -> CGColor? {
        guard let value = implementation.readOnly.attribute(key, at: at, effectiveRange: nil) else {
            return nil
        }
        guard CFGetTypeID(value as CFTypeRef) == CGColor.typeID else {
            return nil
        }
        return (value as! CGColor)
    }
    private mutating func set(key: NSAttributedString.Key, range: Range<Int>, color: CGColor?) {
        if let color = color {
            implementation.writeOnly.setAttributes([key:color], range: range.nsRange())
        } else {
            implementation.writeOnly.removeAttribute(key, range: range.nsRange())
        }
    }
    private func element(_ key: NSAttributedString.Key, at: Int) -> SystemElement? {
        guard let value = implementation.readOnly.attribute(key, at: at, effectiveRange: nil) else {
            return nil
        }
        guard CFGetTypeID(value as CFTypeRef) == AXUIElement.typeID else {
            return nil
        }
        return SystemElement(element: (value as! AXUIElement))
    }
    private mutating func set(key: NSAttributedString.Key, range: Range<Int>, element: SystemElement?) {
        if let element = element {
            implementation.writeOnly.setAttributes([key:element.element], range: range.nsRange())
        } else {
            implementation.writeOnly.removeAttribute(key, range: range.nsRange())
        }
    }
    private func bool(_ key: NSAttributedString.Key, at: Int) -> Bool? {
        guard let value = implementation.readOnly.attribute(key, at: at, effectiveRange: nil) else {
            return nil
        }
        guard CFGetTypeID(value as CFTypeRef) == CFBooleanGetTypeID() else {
            return nil
        }
        return CFBooleanGetValue((value as! CFBoolean))
    }
    private mutating func set(key: NSAttributedString.Key, range: Range<Int>, bool: Bool?) {
        if let bool = bool {
            let value = (bool ? kCFBooleanTrue : kCFBooleanFalse) as Any
            implementation.writeOnly.setAttributes([key:value], range: range.nsRange())
        } else {
            implementation.writeOnly.removeAttribute(key, range: range.nsRange())
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
        string.implementation.readOnly.enumerateAttributes(in: current, options: []) { attributesDictionary, range, stop in
            next = range
            attributes = AttributedString.attributes(keys: Array<NSAttributedString.Key>(attributesDictionary.keys))
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

extension AttributedString : Codable {
    fileprivate enum AttributedStringCodingKeys : String, CodingKey {
        case string
        case attributes
    }
    // No need for book keeping logic for issues like overlapping ranges
    // because this is boxing and unboxing NSAttributedString values
    // that have already done that work.
    fileprivate class AttributesContainer : Codable {
        fileprivate struct Value<ValueType> : Codable where ValueType : Codable {
            let range: Range<Int>
            let value: ValueType
            init(_ range: Range<Int>, _ value: ValueType) {
                self.range = range
                self.value = value
            }
            // MARK: Codable
            fileprivate enum ValueCodingKeys : String, CodingKey {
                case range
                case value
            }
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: ValueCodingKeys.self)
                try container.encode(CodableRangeContainer(range: range), forKey: .range)
                try container.encode(value, forKey: .value)
            }
            public init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: ValueCodingKeys.self)
                let rangeContainer = try values.decode(CodableRangeContainer<Int>.self, forKey: .range)
                self.range = rangeContainer.range
                self.value = try values.decode(ValueType.self, forKey: .value)
            }
        }
        lazy var textAlignments = [Value<TextAlignment>]()
        lazy var fonts = [Value<Font>]()
        lazy var foregroundColors = [Value<CodableColorContainer>]()
        lazy var backgroundColors = [Value<CodableColorContainer>]()
        lazy var underlineColors = [Value<CodableColorContainer>]()
        lazy var strikethroughColors = [Value<CodableColorContainer>]()
        lazy var underlineStyles = [Value<Int>]()
        lazy var superscripts = [Value<Int>]()
        lazy var strikethroughs = [Value<Bool>]()
        lazy var shadows = [Value<Bool>]()
        lazy var attachments = [Value<SystemElement>]()
        lazy var links = [Value<SystemElement>]()
        lazy var naturalLanguages = [Value<String>]()
        lazy var replacements = [Value<String>]()
        lazy var misspelleds = [Value<Bool>]()
        lazy var markedMisspelleds = [Value<Bool>]()
        lazy var autocorrecteds = [Value<Bool>]()
        lazy var listItemPrefixs = [Value<AttributedString>]()
        lazy var listItemIndexs = [Value<Int>]()
        lazy var listItemLevels = [Value<Int>]()
    }
    private func attributesContainer() -> AttributesContainer {
        var attributesContainer = AttributesContainer()
        func color(_ range: Range<Int>,
                   _ color: CGColor) -> AttributesContainer.Value<CodableColorContainer> {
            return AttributesContainer.Value(range, CodableColorContainer(color: color))
        }
        for (range, attributes) in self {
            for attribute in attributes {
                switch attribute {
                case .textAlignment:
                    attributesContainer.textAlignments
                        .append(AttributesContainer.Value(range,
                                                          textAlignment(at: range.lowerBound)!))
                case .font:
                    attributesContainer.fonts
                        .append(AttributesContainer.Value(range,
                                                          font(at: range.lowerBound)!))
                case .foregroundColor:
                    attributesContainer.foregroundColors
                        .append(color(range,
                                      foregroundColor(at: range.lowerBound)!))
                case .backgroundColor:
                    attributesContainer.backgroundColors
                        .append(color(range,
                                      backgroundColor(at: range.lowerBound)!))
                case .underlineColor:
                    attributesContainer.underlineColors
                        .append(color(range,
                                      underlineColor(at: range.lowerBound)!))
                case .strikethroughColor:
                    attributesContainer.strikethroughColors
                        .append(color(range,
                                      strikethroughColor(at: range.lowerBound)!))
                case .underlineStyle:
                    attributesContainer.underlineStyles
                        .append(AttributesContainer.Value(range,
                                                          Int(underlineStyle(at: range.lowerBound)!.rawValue)))
                case .superscript:
                    attributesContainer.superscripts
                        .append(AttributesContainer.Value(range,
                                                          superscript(at: range.lowerBound)!))
                case .strikethrough:
                    attributesContainer.strikethroughs
                        .append(AttributesContainer.Value(range,
                                                          strikethrough(at: range.lowerBound)!))
                case .shadow:
                    attributesContainer.shadows
                        .append(AttributesContainer.Value(range,
                                                          shadow(at: range.lowerBound)!))
                case .attachment:
                    attributesContainer.attachments
                        .append(AttributesContainer.Value(range,
                                                          attachment(at: range.lowerBound)!))
                case .link:
                    attributesContainer.links
                        .append(AttributesContainer.Value(range,
                                                          link(at: range.lowerBound)!))
                case .naturalLanguage:
                    attributesContainer.naturalLanguages
                        .append(AttributesContainer.Value(range,
                                                          naturalLanguage(at: range.lowerBound)!))
                case .replacement:
                    attributesContainer.replacements
                        .append(AttributesContainer.Value(range,
                                                          replacement(at: range.lowerBound)!))
                case .misspelled:
                    attributesContainer.misspelleds
                        .append(AttributesContainer.Value(range,
                                                          misspelled(at: range.lowerBound)!))
                case .markedMisspelled:
                    attributesContainer.markedMisspelleds
                        .append(AttributesContainer.Value(range,
                                                          markedMisspelled(at: range.lowerBound)!))
                case .autocorrected:
                    attributesContainer.autocorrecteds
                        .append(AttributesContainer.Value(range,
                                                          autocorrected(at: range.lowerBound)!))
                case .listItemPrefix:
                    attributesContainer.listItemPrefixs
                        .append(AttributesContainer.Value(range,
                                                          listItemPrefix(at: range.lowerBound)!))
                case .listItemIndex:
                    attributesContainer.listItemIndexs
                        .append(AttributesContainer.Value(range,
                                                          listItemIndex(at: range.lowerBound)!))
                case .listItemLevel:
                    attributesContainer.listItemLevels
                        .append(AttributesContainer.Value(range,
                                                          listItemLevel(at: range.lowerBound)!))
                }
            }
        }
        return attributesContainer
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AttributedStringCodingKeys.self)
        try container.encode(implementation.readOnly.string, forKey: .string)
        try container.encode(attributesContainer(), forKey: .attributes)
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: AttributedStringCodingKeys.self)
        let string = try values.decode(String.self, forKey: .string)
        let attributes = try values.decode(AttributesContainer.self, forKey: .attributes)
        let attributedString = NSAttributedString(string: string)
        implementation = Implementation(attributedString)
        for textAlignment in attributes.textAlignments {
            set(textAlignment: textAlignment.value, range: textAlignment.range)
        }
        for font in attributes.fonts {
            set(font: font.value, range: font.range)
        }
        for foregroundColor in attributes.foregroundColors {
            set(foregroundColor: foregroundColor.value.color, range: foregroundColor.range)
        }
        for backgroundColor in attributes.backgroundColors {
            set(backgroundColor: backgroundColor.value.color, range: backgroundColor.range)
        }
        for underlineColor in attributes.underlineColors {
            set(underlineColor: underlineColor.value.color, range: underlineColor.range)
        }
        for strikethroughColor in attributes.strikethroughColors {
            set(strikethroughColor: strikethroughColor.value.color, range: strikethroughColor.range)
        }
        for underlineStyle in attributes.underlineStyles {
            set(underlineStyle: UnderlineStyle(rawValue: UInt32(underlineStyle.value))!, range: underlineStyle.range)
        }
        for superscript in attributes.superscripts {
            set(superscript: superscript.value, range: superscript.range)
        }
        for strikethrough in attributes.strikethroughs {
            set(strikethrough: strikethrough.value, range: strikethrough.range)
        }
        for shadow in attributes.shadows {
            set(shadow: shadow.value, range: shadow.range)
        }
        for attachment in attributes.attachments {
            set(attachment: attachment.value, range: attachment.range)
        }
        for link in attributes.links {
            set(link: link.value, range: link.range)
        }
        for naturalLanguage in attributes.naturalLanguages {
            set(naturalLanguage: naturalLanguage.value, range: naturalLanguage.range)
        }
        for replacement in attributes.replacements {
            set(replacement: replacement.value, range: replacement.range)
        }
        for misspelled in attributes.misspelleds {
            set(misspelled: misspelled.value, range: misspelled.range)
        }
        for markedMisspelled in attributes.markedMisspelleds {
            set(markedMisspelled: markedMisspelled.value, range: markedMisspelled.range)
        }
        for autocorrected in attributes.autocorrecteds {
            set(autocorrected: autocorrected.value, range: autocorrected.range)
        }
        for listItemPrefix in attributes.listItemPrefixs {
            set(listItemPrefix: listItemPrefix.value, range: listItemPrefix.range)
        }
        for listItemIndex in attributes.listItemIndexs {
            set(listItemIndex: listItemIndex.value, range: listItemIndex.range)
        }
        for listItemLevel in attributes.listItemLevels {
            set(listItemLevel: listItemLevel.value, range: listItemLevel.range)
        }
    }
}

extension AttributedString : CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(implementation.readOnly)"
    }
}

extension AttributedString.Font : CustomDebugStringConvertible {
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
}
