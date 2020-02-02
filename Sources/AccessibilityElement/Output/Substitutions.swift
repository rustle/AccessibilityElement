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

public struct ConfusableSubstitutions: Substitutions {
    public func perform(_ value: String) -> String {
        fatalError()
    }
}

// Strips away diacratics that may interfere with output if used
// inappropriately. For example as styled or glitch text on
// Twitter
// "ḓĩẲçrätīčś" -> "diAcratics", "Ⓚ" -> "K", "𝔞" -> "a", "U̵" -> "U"
public struct DecomposingSubstitutions: Substitutions {
    public func perform(_ value: String) -> String {
        let folded = value.folding(options: .diacriticInsensitive,
                                   locale: .current)
        let decomposed = folded.decomposedStringWithCompatibilityMapping
        return decomposed
    }
}

public struct SimpleSubstitutions: Substitutions, Codable {
    public var words: [String:String]
    public var characters: [String:String]
    public init(wordSubstitutions: [String:String],
                characters: [String:String]) {
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
                guard let string = string else {
                    return
                }
                if enclosingRange.lowerBound < range.lowerBound {
                    buffer.append(contentsOf: value[enclosingRange.lowerBound..<range.lowerBound])
                }
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
                guard let string = string else {
                    return
                }
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

public struct PunctuationExpansion: Substitutions {
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
