//
//  AttributedTextAttributes.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

public struct AttributedTextAttributes: RawRepresentable, Hashable, Codable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension AttributedTextAttributes {
    // MARK: Font (value: [String: Any] — see kAXFont*Key)

    // kAXFontTextAttribute
    static let font = Self(rawValue: "AXFont")

    // MARK: Color (CGColor)

    // kAXForegroundColorTextAttribute
    static let foregroundColor = Self(rawValue: "AXForegroundColor")
    // kAXBackgroundColorTextAttribute
    static let backgroundColor = Self(rawValue: "AXBackgroundColor")
    // kAXUnderlineColorTextAttribute
    static let underlineColor = Self(rawValue: "AXUnderlineColor")
    // kAXStrikethroughColorTextAttribute
    static let strikethroughColor = Self(rawValue: "AXStrikethroughColor")

    // MARK: Style

    // kAXUnderlineTextAttribute
    static let underline = Self(rawValue: "AXUnderline")
    // kAXSuperscriptTextAttribute
    static let superscript = Self(rawValue: "AXSuperscript")
    // kAXStrikethroughTextAttribute
    static let strikethrough = Self(rawValue: "AXStrikethrough")
    // kAXShadowTextAttribute
    static let shadow = Self(rawValue: "AXShadow")

    // MARK: Elements

    // kAXAttachmentTextAttribute
    static let attachment = Self(rawValue: "AXAttachment")
    // kAXLinkTextAttribute
    static let link = Self(rawValue: "AXLink")

    // MARK: Language

    // kAXNaturalLanguageTextAttribute
    static let naturalLanguage = Self(rawValue: "AXNaturalLanguage")
    // kAXReplacementStringTextAttribute
    static let replacementString = Self(rawValue: "AXReplacementString")

    // MARK: Spelling

    // kAXMisspelledTextAttribute
    static let misspelled = Self(rawValue: "AXMisspelled")
    // kAXMarkedMisspelledTextAttribute
    static let markedMisspelled = Self(rawValue: "AXMarkedMisspelled")

    // MARK: Autocorrection

    // kAXAutocorrectedTextAttribute
    static let autocorrected = Self(rawValue: "AXAutocorrected")

    // MARK: List items

    // kAXListItemPrefixTextAttribute
    static let listItemPrefix = Self(rawValue: "AXListItemPrefix")
    // kAXListItemIndexTextAttribute
    static let listItemIndex  = Self(rawValue: "AXListItemIndex")
    // kAXListItemLevelTextAttribute
    static let listItemLevel  = Self(rawValue: "AXListItemLevel")
}
