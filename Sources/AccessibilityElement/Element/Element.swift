//
//  AccessibilityElement.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import Cocoa

/// Protocol all elements must conform to, without any methods or properties that contain a self constraint. Useful for tasks like forming heterogeneous collections and inclusion in other type erased containers.
public protocol AnyElement {
    /// Nonlocalized string that defines the element’s role in the app.
    func role() throws -> NSAccessibilityRole
    /// Localized string that describes the element’s role in the app.
    func roleDescription() throws -> String
    ///
    func subrole() throws -> NSAccessibilitySubrole
    ///
    func value() throws -> Any
    ///
    func string<IndexType>(range: Range<Position<IndexType>>) throws -> String
    ///
    func attributedString<IndexType>(range: Range<Position<IndexType>>) throws -> AttributedString
    ///
    func numberOfCharacters() throws -> Int
    ///
    func description() throws -> String
    ///
    func title() throws -> String
    ///
    func url() throws -> URL
    ///
    func isKeyboardFocused() throws -> Bool
    ///
    func frame() throws -> Frame
    /// Value of caret browsing preference in a web area.
    ///
    /// When enabled, web area will use document like cursor navigation in response
    /// to arrow navigation
    ///
    /// Appropriate for use with a WebKit web area element.
    func caretBrowsingEnabled() throws -> Bool
    /// Set value of caret browsing preference in a web area.
    ///
    /// When enabled, web area will use document like cursor navigation in response
    /// to arrow navigation
    ///
    /// Appropriate for use with a WebKit web area element.
    func set(caretBrowsing: Bool) throws
    ///
    func range<IndexType>(unorderedPositions: (first: Position<IndexType>, second: Position<IndexType>)) throws -> Range<Position<IndexType>>
    ///
    func enhancedUserInterface() throws -> Bool
    ///
    func set(enhancedUserInterface: Bool) throws
    ///
    func selectedTextRanges() throws -> [Range<Position<Int>>]
    ///
    func selectedTextMarkerRanges() throws -> [Range<Position<AXTextMarker>>]
    ///
    func set(selectedTextMarkerRanges: [Range<Position<AXTextMarker>>]) throws
    ///
    func line<IndexType>(position: Position<IndexType>) throws -> Int where IndexType : Codable
    ///
    func range<IndexType>(line: Int) throws -> Range<Position<IndexType>>
    ///
    func first<IndexType>() throws -> Position<IndexType>
    ///
    func last<IndexType>() throws -> Position<IndexType>
    ///
    var processIdentifier: ProcessIdentifier { get }
}

public protocol Element : AnyElement, TreeElement, Hashable {
    associatedtype ObserverProvidingType : ObserverProviding
    ///
    static func systemWide() throws -> Self
    ///
    static func application(processIdentifier: ProcessIdentifier) throws -> Self
    ///
    func titleElement() throws -> Self
    ///
    func parent() throws -> Self
    ///
    func children() throws -> [Self]
    ///
    func topLevelElement() throws -> Self
    ///
    func applicationFocusedElement() throws -> Self
    ///
    func windows() throws -> [Self]
    ///
    func focusedWindow() throws -> Self
}

public extension Element {
    public static func systemWide() throws -> Self {
        throw ElementError.notImplemented
    }
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
    
    public func titleElement() throws -> Self {
        throw ElementError.notImplemented
    }
    public func parent() throws -> Self {
        throw ElementError.notImplemented
    }
    public func children() throws -> [Self] {
        throw ElementError.notImplemented
    }
    public func topLevelElement() throws -> Self {
        throw ElementError.notImplemented
    }
    public func applicationFocusedElement() throws -> Self {
        throw ElementError.notImplemented
    }
    public func role() throws -> NSAccessibilityRole {
        throw ElementError.notImplemented
    }
    public func roleDescription() throws -> String {
        throw ElementError.notImplemented
    }
    public func subrole() throws -> NSAccessibilitySubrole {
        throw ElementError.notImplemented
    }
    public func value() throws -> Any {
        throw ElementError.notImplemented
    }
    public func string<IndexType>(range: Range<Position<IndexType>>) throws -> String {
        throw ElementError.notImplemented
    }
    public func attributedString<IndexType>(range: Range<Position<IndexType>>) throws -> AttributedString {
        throw ElementError.notImplemented
    }
    public func numberOfCharacters() throws -> Int {
        throw ElementError.notImplemented
    }
    public func description() throws -> String {
        throw ElementError.notImplemented
    }
    public func title() throws -> String {
        throw ElementError.notImplemented
    }
    public func isKeyboardFocused() throws -> Bool {
        throw ElementError.notImplemented
    }
    public func frame() throws -> Frame {
        throw ElementError.notImplemented
    }
    public func caretBrowsingEnabled() throws -> Bool {
        throw ElementError.notImplemented
    }
    public func set(caretBrowsing: Bool) throws {
        throw ElementError.notImplemented
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
        throw ElementError.notImplemented
    }
    public func enhancedUserInterface() throws -> Bool {
        throw ElementError.notImplemented
    }
    public func set(enhancedUserInterface: Bool) throws {
        throw ElementError.notImplemented
    }
    public func windows() throws -> [Self] {
        throw ElementError.notImplemented
    }
    public func focusedWindow() throws ->  Self {
        throw ElementError.notImplemented
    }
    public func url() throws -> URL {
        throw ElementError.notImplemented
    }
    public func selectedTextRanges() throws -> [Range<Position<Int>>] {
        throw ElementError.notImplemented
    }
    public func selectedTextMarkerRanges() throws -> [Range<Position<AXTextMarker>>] {
        throw ElementError.notImplemented
    }
    public func set(selectedTextMarkerRanges: [Range<Position<AXTextMarker>>]) throws {
        throw ElementError.notImplemented
    }
    public func line<IndexType>(position: Position<IndexType>) throws -> Int where IndexType : Codable {
        throw ElementError.notImplemented
    }
    public func range<IndexType>(line: Int) throws -> Range<Position<IndexType>> {
        throw ElementError.notImplemented
    }
    public func first<IndexType>() throws -> Position<IndexType> {
        throw ElementError.notImplemented
    }
    public func last<IndexType>() throws -> Position<IndexType> {
        throw ElementError.notImplemented
    }
    public var processIdentifier: ProcessIdentifier {
        return 0
    }
}
