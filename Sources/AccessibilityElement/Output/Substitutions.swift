//
//  Substitutions.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import SwiftScanner

public struct SynthesizerMarkup {
    public static let characterLiteral = "[[char ltrl]]"
    public static let characterNormal = "[[char norm]]"
    public static func literalMarkup(for value: Any) -> String {
        return "\(characterLiteral)\(value)\(characterNormal)"
    }
}

public protocol Substitutions {
    func perform(_ value: String) -> String
}

public struct ConfusableSubstitutions : Substitutions {
    public func perform(_ value: String) -> String {
        fatalError()
    }
}

public struct DecomposingSubstitutions : Substitutions {
    public func perform(_ value: String) -> String {
        let folded = value.folding(options: .diacriticInsensitive, locale: .current)
        let decomposed = folded.decomposedStringWithCompatibilityMapping
        return decomposed
    }
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
    func isWhitespaceOrNewline() -> Bool {
        return ExtendedGraphemeClusterSet.whitespacesAndNewlines.contains(self)
    }
}

public struct AbbreviationExpansion : Substitutions {
    static let ehm: String = SynthesizerMarkup.literalMarkup(for: Character("m"))
    static let ehs: String = SynthesizerMarkup.literalMarkup(for: Character("s"))
    static let ehmEhs: String = SynthesizerMarkup.literalMarkup(for: "ms")
    static let ehmEhm: String = SynthesizerMarkup.literalMarkup(for: "mm")
    public static let m = Character("m")
    public static let s = Character("s")
    public static let space = Character(" ")
    public func perform(_ value: String) -> String {
        var buffer = String()
        buffer.reserveCapacity(value.utf16.count)
        // TODO: test scanning with move and accumulate false and manually appending substrings instead
        // of making temp Strings
        let scanner = StringScanner(value)
        let decimals = CharacterSet.decimalDigits
        let inverted = decimals.inverted
        func scanToDecimal() {
            do {
                let scanned = try scanner.scan(upTo: decimals)
                buffer.append(scanned)
            } catch StringScannerError.eof {
                return
            } catch {
                return
            }
        }
        func scanToNonDecimal() {
            do {
                let scanned = try scanner.scan(upTo: inverted)
                buffer.append(scanned)
                let start = scanner.position
                var cursor = start
                func bump() {
                    cursor = value.index(after: cursor)
                }
                func backup() {
                    cursor = value.index(before: cursor)
                }
                func skip() throws {
                    try scanner.skip(length:value.distance(from: start, to: cursor))
                }
                if cursor < value.endIndex {
                    let plusOne = value[cursor]
                    switch plusOne {
                    case AbbreviationExpansion.m:
                        bump()
                        if cursor == value.endIndex { // At the last character
                            buffer.append(contentsOf: AbbreviationExpansion.ehm)
                        } else if cursor < value.endIndex { // Not at the last character
                            let plusTwo = value[cursor]
                            if plusTwo.isWhitespaceOrNewline() {
                                buffer.append(contentsOf: AbbreviationExpansion.ehm)
                                buffer.append(plusTwo)
                                bump()
                            } else {
                                switch plusTwo {
                                case AbbreviationExpansion.m:
                                    bump()
                                    if cursor == value.endIndex { // At the last character
                                        buffer.append(contentsOf: AbbreviationExpansion.ehmEhm)
                                    } else if cursor < value.endIndex { // Not at the last character
                                        let plusThree = value[cursor]
                                        if plusThree.isWhitespaceOrNewline() {
                                            buffer.append(contentsOf: AbbreviationExpansion.ehmEhm)
                                            buffer.append(plusThree)
                                        } else {
                                            buffer.append(plusOne)
                                            buffer.append(plusTwo)
                                            buffer.append(plusThree)
                                        }
                                        bump()
                                    }
                                case AbbreviationExpansion.s:
                                    bump()
                                    if cursor == value.endIndex { // At the last character
                                        buffer.append(contentsOf: AbbreviationExpansion.ehmEhs)
                                    } else if cursor < value.endIndex { // Not at the last character
                                        let plusThree = value[cursor]
                                        bump()
                                        if plusThree.isWhitespaceOrNewline() {
                                            buffer.append(contentsOf: AbbreviationExpansion.ehmEhs)
                                            buffer.append(plusThree)
                                        } else {
                                            buffer.append(plusOne)
                                            buffer.append(plusTwo)
                                            buffer.append(plusThree)
                                        }
                                    }
                                default:
                                    buffer.append(plusOne)
                                }
                            }
                        }
                    case AbbreviationExpansion.space:
                        bump()
                        if cursor == value.endIndex { // At the last character
                            buffer.append(plusOne)
                        } else if cursor < value.endIndex { // Not at the last character
                            let plusTwo = value[cursor]
                            switch plusTwo {
                            case AbbreviationExpansion.m:
                                bump()
                                buffer.append(plusOne)
                                if cursor == value.endIndex { // At the last character
                                    buffer.append(contentsOf: AbbreviationExpansion.ehm)
                                } else if cursor < value.endIndex { // Not at the last character
                                    let plusThree = value[cursor]
                                    if plusThree.isWhitespaceOrNewline() {
                                        buffer.append(contentsOf: AbbreviationExpansion.ehm)
                                        buffer.append(plusThree)
                                        bump()
                                    } else {
                                        switch plusThree {
                                        case AbbreviationExpansion.m:
                                            bump()
                                            if cursor == value.endIndex {
                                                buffer.append(contentsOf: AbbreviationExpansion.ehmEhm)
                                            } else if cursor < value.endIndex { // Not at the last character
                                                let plusFour = value[cursor]
                                                if plusFour.isWhitespaceOrNewline() {
                                                    buffer.append(contentsOf: AbbreviationExpansion.ehmEhm)
                                                } else {
                                                    buffer.append(plusTwo)
                                                    buffer.append(plusThree)
                                                }
                                                buffer.append(plusFour)
                                                bump()
                                            }
                                        case AbbreviationExpansion.s:
                                            bump()
                                            if cursor == value.endIndex {
                                                buffer.append(contentsOf: AbbreviationExpansion.ehmEhs)
                                            } else if cursor < value.endIndex { // Not at the last character
                                                fatalError()
                                            }
                                        default:
                                            buffer.append(plusTwo)
                                            buffer.append(plusThree)
                                            bump()
                                        }
                                    }
                                }
                            case AbbreviationExpansion.s:
                                bump()
                                buffer.append(plusOne)
                                if cursor == value.endIndex { // At the last character
                                    buffer.append(contentsOf: AbbreviationExpansion.ehs)
                                } else if cursor < value.endIndex { // Not at the last character
                                    let plusThree = value[cursor]
                                    if plusThree.isWhitespaceOrNewline() {
                                        buffer.append(contentsOf: AbbreviationExpansion.ehs)
                                        buffer.append(plusThree)
                                    } else {
                                        buffer.append(plusTwo)
                                        buffer.append(plusThree)
                                    }
                                    bump()
                                }
                            default:
                                backup()
                            }
                        }
                    default:
                        break
                    }
                }
                try skip()
            } catch StringScannerError.eof {
                return
            } catch {
                return
            }
        }
        while !scanner.isAtEnd {
            scanToDecimal()
            scanToNonDecimal()
        }
        return buffer
    }
}

public struct PunctuationExpansion : Substitutions {
    private enum Mode {
        case punctuation
        case other
    }
    public func perform(_ value: String) -> String {
        var buffer = String()
        var mode = Mode.other
        func setMode(_ newMode: Mode) {
            if mode != newMode {
                switch newMode {
                case .punctuation:
                    buffer.append(SynthesizerMarkup.characterLiteral)
                case .other:
                    buffer.append(SynthesizerMarkup.characterNormal)
                }
                mode = newMode
            }
        }
        let punctuation = ExtendedGraphemeClusterSet.punctuationCharacters
        buffer.reserveCapacity(value.utf16.count)
        for character in value {
            if punctuation.contains(character) {
                setMode(.punctuation)
            } else {
                setMode(.other)
            }
            buffer.append(character)
        }
        setMode(.other)
        return buffer
    }
}
