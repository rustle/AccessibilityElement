//
//  Substitutions.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public protocol Substitutions {
    func perform(_ value: String) -> String
}

public struct SimpleSubstitutions : Substitutions, Codable {
    public var words: [String:String]
    public var characters: [String:String]
    public init(wordSubstitutions: [String:String], characters: [String:String]) {
        self.words = wordSubstitutions
        self.characters = characters
    }
    public func perform(_ value: String) -> String {
        if words.count + characters.count == 0 {
            return value
        }
        var buffer = String()
        if words.count > 0 {
            value.enumerateSubstrings(in: value.startIndex..<value.endIndex,
                                      options: [.byWords]) { string, range, enclosingRange, stop in
                if enclosingRange.lowerBound < range.lowerBound {
                    buffer.append(contentsOf: value[enclosingRange.lowerBound..<range.lowerBound])
                }
                let string = string!
                if let sub = self.words[string] {
                    buffer.append(sub)
                } else {
                    buffer.append(string)
                }
                if enclosingRange.upperBound > range.upperBound {
                    buffer.append(contentsOf: value[range.upperBound..<enclosingRange.upperBound])
                }
            }
        }
        if characters.count > 0 {
            value.enumerateSubstrings(in: value.startIndex..<value.endIndex,
                                      options: [.byComposedCharacterSequences]) { string, range, enclosingRange, stop in
                let string = string!
                if let sub = self.characters[string] {
                    buffer.append(sub)
                } else {
                    buffer.append(string)
                }
            }
        }
        return buffer
    }
}

extension Character {
    func isWhitespaceOrNewline(offset: Int) -> Bool {
        let unicodeScalars = self.unicodeScalars
        if unicodeScalars.count == 1 {
            let unicode = unicodeScalars[unicodeScalars.startIndex]
            if CharacterSet.whitespacesAndNewlines.contains(unicode) {
                return true
            }
        }
        return false
    }
}

public struct EmSubstitutions : Substitutions {
    static let em: String = {
        let synthesizer = NSSpeechSynthesizer()
        synthesizer.rate = 300
        return "[[inpt phon]]\(synthesizer.phonemes(from: "[[char ltrl]]m[[char norm]]"))[[inpt text]]"
    }()
    public static let m = Character("m")
    public static let space = Character(" ")
    public func perform(_ value: String) -> String {
        var buffer = String()
        let scanner = Scanner(string: value)
        scanner.charactersToBeSkipped = nil
        let decimals = CharacterSet.decimalDigits
        let inverted = decimals.inverted
        let whitespace = CharacterSet.whitespacesAndNewlines
        func scanToDecimal() {
            let before = scanner.scanLocation
            _ = scanner.scanUpToCharacters(from: decimals, into: nil)
            let after = scanner.scanLocation
            if after > before {
                buffer.append(contentsOf: value[before..<after])
            }
        }
        func scanToNonDecimal() {
            let before = scanner.scanLocation
            _ = scanner.scanUpToCharacters(from: inverted, into: nil)
            let after = scanner.scanLocation
            if after > before {
                buffer.append(contentsOf: value[before..<after])
            }
            var cursor = after
            if cursor < value.count {
                let plusOne = value[value.index(value.startIndex, offsetBy: cursor)]
                if plusOne == EmSubstitutions.m {
                    cursor += 1
                    if cursor == value.count { // At the last character
                        buffer.append(contentsOf: EmSubstitutions.em)
                        scanner.scanLocation = cursor
                    } else if cursor < value.count { // Not at the last character
                        let plusTwo = value[value.index(value.startIndex, offsetBy: cursor)]
                        if plusTwo.isWhitespaceOrNewline(offset: after+1) {
                            buffer.append(contentsOf: EmSubstitutions.em)
                            scanner.scanLocation = cursor
                        }
                    }
                } else if plusOne == EmSubstitutions.space {
                    cursor += 1
                    if cursor == value.count { // At the last character
                        buffer.append(plusOne)
                        scanner.scanLocation = cursor
                    } else if cursor < value.count { // Not at the last character
                        let plusTwo = value[value.index(value.startIndex, offsetBy: cursor)]
                        if plusTwo == EmSubstitutions.m {
                            cursor += 1
                            buffer.append(plusOne)
                            if cursor == value.count { // At the last character
                                buffer.append(contentsOf: EmSubstitutions.em)
                            } else if cursor < value.count { // Not at the last character
                                let plusThree = value[value.index(value.startIndex, offsetBy: cursor)]
                                if plusThree.isWhitespaceOrNewline(offset: cursor) {
                                    buffer.append(contentsOf: EmSubstitutions.em)
                                } else {
                                    buffer.append(plusTwo)
                                }
                                buffer.append(plusThree)
                                cursor += 1
                            }
                            scanner.scanLocation = cursor
                        }
                    }
                }
            }
        }
        while !scanner.isAtEnd {
            scanToDecimal()
            scanToNonDecimal()
        }
        return buffer
    }
}
