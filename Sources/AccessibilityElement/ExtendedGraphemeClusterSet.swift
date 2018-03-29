//
//  ExtendedGraphemeClusterSet.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

/// `CharacterSet` like type that supports grapheme clusters composed of more than 1 unicode scalar
public struct ExtendedGraphemeClusterSet {
    /// Returns a set containing the characters in Unicode General Category Cc and Cf.
    public static let controlCharacters = ExtendedGraphemeClusterSet(characterSet: CharacterSet.controlCharacters)
    /// Returns a set containing the characters in Unicode General Category Zs and `CHARACTER TABULATION (U+0009)`.
    public static let whitespaces = ExtendedGraphemeClusterSet(characterSet: CharacterSet.whitespaces)
    /// Returns a set containing characters in Unicode General Category Z*, `U+000A ~ U+000D`, and `U+0085`.
    public static let whitespacesAndNewlines = ExtendedGraphemeClusterSet(characterSet: CharacterSet.whitespacesAndNewlines)
    /// Returns a set containing the characters in the category of Decimal Numbers.
    public static let decimalDigits = ExtendedGraphemeClusterSet(characterSet: CharacterSet.decimalDigits)
    /// Returns a set containing the characters in Unicode General Category L* & M*.
    public static let letters = ExtendedGraphemeClusterSet(characterSet: CharacterSet.letters)
    /// Returns a set containing the characters in Unicode General Category Ll.
    public static let lowercaseLetters = ExtendedGraphemeClusterSet(characterSet: CharacterSet.lowercaseLetters)
    /// Returns a set containing the characters in Unicode General Category Lu and Lt.
    public static let uppercaseLetters = ExtendedGraphemeClusterSet(characterSet: CharacterSet.uppercaseLetters)
    /// Returns a set containing the characters in Unicode General Category M*.
    public static let nonBaseCharacters = ExtendedGraphemeClusterSet(characterSet: CharacterSet.nonBaseCharacters)
    /// Returns a set containing the characters in Unicode General Categories L*, M*, and N*.
    public static let alphanumerics = ExtendedGraphemeClusterSet(characterSet: CharacterSet.alphanumerics)
    /// Returns a set containing individual Unicode characters that can also be represented as composed character sequences (such as for letters with accents), by the definition of "standard decomposition" in version 3.2 of the Unicode character encoding standard.
    public static let decomposables = ExtendedGraphemeClusterSet(characterSet: CharacterSet.decomposables)
    /// Returns a set containing values in the category of Non-Characters or that have not yet been defined in version 3.2 of the Unicode standard.
    public static let illegalCharacters = ExtendedGraphemeClusterSet(characterSet: CharacterSet.illegalCharacters)
    /// Returns a set containing the characters in Unicode General Category P*.
    public static let punctuationCharacters = ExtendedGraphemeClusterSet(characterSet: CharacterSet.punctuationCharacters)
    /// Returns a set containing the characters in Unicode General Category Lt.
    public static let capitalizedLetters = ExtendedGraphemeClusterSet(characterSet: CharacterSet.capitalizedLetters)
    /// Returns a set containing the characters in Unicode General Category S*.
    public static let symbols = ExtendedGraphemeClusterSet(characterSet: CharacterSet.symbols)
    /// Returns a set containing the newline characters (`U+000A ~ U+000D`, `U+0085`, `U+2028`, and `U+2029`).
    public static let newlines = ExtendedGraphemeClusterSet(characterSet: CharacterSet.newlines)
    /// Returns a set containing the characters allowed in a user URL subcomponent.
    public static let urlUserAllowed = ExtendedGraphemeClusterSet(characterSet: CharacterSet.urlUserAllowed)
    /// Returns a set containing the characters allowed in a password URL subcomponent.
    public static let urlPasswordAllowed = ExtendedGraphemeClusterSet(characterSet: CharacterSet.urlPasswordAllowed)
    /// Returns a set containing the characters allowed in a host URL subcomponent.
    public static let urlHostAllowed = ExtendedGraphemeClusterSet(characterSet: CharacterSet.urlHostAllowed)
    /// Returns a set containing the characters allowed in a path URL component.
    public static let urlPathAllowed = ExtendedGraphemeClusterSet(characterSet: CharacterSet.urlPathAllowed)
    /// Returns a set containing the characters allowed in a query URL component.
    public static let urlQueryAllowed = ExtendedGraphemeClusterSet(characterSet: CharacterSet.urlQueryAllowed)
    /// Returns a set containing the characters allowed in a fragment URL component.
    public static let urlFragmentAllowed = ExtendedGraphemeClusterSet(characterSet: CharacterSet.urlFragmentAllowed)
    /// Test for membership of a particular `Character` in the `SwiftCharacterSet`.
    public func contains(_ member: Character) -> Bool {
        let unicodeScalars = member.unicodeScalars
        if unicodeScalars.count == 1 {
            let unicodeScalar = unicodeScalars[unicodeScalars.startIndex]
            if characterSet.contains(unicodeScalar) {
                return true
            }
        }
        return characters.contains(member)
    }
    /// Insert the 'Character' into the `ExtendedGraphemeClusterSet`.
    public mutating func insert(_ member: Character) {
        let unicodeScalars = member.unicodeScalars
        if unicodeScalars.count == 1 {
            let unicodeScalar = unicodeScalars[unicodeScalars.startIndex]
            characterSet.insert(unicodeScalar)
        } else {
            characters.insert(member)
        }
    }
    /// Remove the values from the specified string from the `ExtendedGraphemeClusterSet`.
    public mutating func remove(_ member: Character) {
        let unicodeScalars = member.unicodeScalars
        if unicodeScalars.count == 1 {
            let unicodeScalar = unicodeScalars[unicodeScalars.startIndex]
            characterSet.remove(unicodeScalar)
        } else {
            characters.remove(member)
        }
    }
    /// Insert the values from the specified string into the `ExtendedGraphemeClusterSet`.
    public mutating func insert(charactersIn string: String) {
        for character in string {
            insert(character)
        }
    }
    /// Remove the values from the specified string from the `ExtendedGraphemeClusterSet`.
    public mutating func remove(charactersIn string: String) {
        for character in string {
            remove(character)
        }
    }
    private var characterSet: CharacterSet
    private var characters = Set<Character>()
    public init() {
        characterSet = CharacterSet()
    }
    public init(characterSet: CharacterSet) {
        self.characterSet = characterSet
    }
}
