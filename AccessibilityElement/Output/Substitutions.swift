//
//  Substitutions.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import SwiftScanner

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
    func isWhitespaceOrNewline() -> Bool {
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
        buffer.reserveCapacity(value.utf8.count)
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
                if cursor < value.endIndex {
                    let plusOne = value[cursor]
                    if plusOne == EmSubstitutions.m {
                        cursor = value.index(after: cursor)
                        if cursor == value.endIndex { // At the last character
                            buffer.append(contentsOf: EmSubstitutions.em)
                            try scanner.skip(length:1)
                        } else if cursor < value.endIndex { // Not at the last character
                            let plusTwo = value[cursor]
                            if plusTwo.isWhitespaceOrNewline() {
                                buffer.append(contentsOf: EmSubstitutions.em)
                                try scanner.skip(length:1)
                            }
                        }
                    } else if plusOne == EmSubstitutions.space {
                        cursor = value.index(after: cursor)
                        if cursor == value.endIndex { // At the last character
                            buffer.append(plusOne)
                            try scanner.skip(length:1)
                        } else if cursor < value.endIndex { // Not at the last character
                            let plusTwo = value[cursor]
                            if plusTwo == EmSubstitutions.m {
                                cursor = value.index(after: cursor)
                                buffer.append(plusOne)
                                if cursor == value.endIndex { // At the last character
                                    buffer.append(contentsOf: EmSubstitutions.em)
                                    try scanner.skip(length: value.distance(from: start, to: cursor))
                                } else if cursor < value.endIndex { // Not at the last character
                                    let plusThree = value[cursor]
                                    if plusThree.isWhitespaceOrNewline() {
                                        buffer.append(contentsOf: EmSubstitutions.em)
                                    } else {
                                        buffer.append(plusTwo)
                                    }
                                    buffer.append(plusThree)
                                    cursor = value.index(after: cursor)
                                    try scanner.skip(length:value.distance(from: start, to: cursor))
                                }
                            }
                        }
                    }
                }
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
