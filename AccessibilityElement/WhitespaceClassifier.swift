//
//  WhitespaceClassifier.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct WhitespaceClassifier {
    public let tabSize: Int
    public enum Indentation {
        case spaces
        case tabs
    }
    public let indentation: Indentation
    public let value: String
    public let leadingWhitespace: Range<String.Index>?
    public let remainder: Range<String.Index>
    public init(value: String,
                tabSize: Int,
                indentation: Indentation) {
        self.tabSize = tabSize
        self.indentation = indentation
        self.value = value
        var lowerBound = value.startIndex
        if let range = value.rangeOfCharacter(from: CharacterSet.whitespaces.inverted,
                                              options: [],
                                              range: lowerBound..<value.endIndex) {
            lowerBound = range.lowerBound
            if range.lowerBound == value.startIndex {
                leadingWhitespace = nil
            } else {
                leadingWhitespace = value.startIndex..<range.lowerBound
            }
        } else {
            leadingWhitespace = nil
        }
        remainder = lowerBound..<value.endIndex
    }
    public struct WhitespaceStatistics {
        public let tabSize: Int
        public let indentation: Indentation
        public enum Leading {
            case mixed
            case level(Int)
            case levelWithModulus(Int, Int)
            case modulus(Int)
        }
        public var leading: Leading
    }
    public func whitespaceStatistics() -> WhitespaceStatistics? {
        guard let leadingWhitespace = leadingWhitespace else {
            return nil
        }
        let whitespace = value[leadingWhitespace]
        switch indentation {
        case .spaces:
            var spaceCount = 0
            for char in whitespace {
                switch char {
                case Character(" "):
                    spaceCount += 1
                default:
                    print("\"\(whitespace)\"")
                    return WhitespaceStatistics(tabSize: tabSize, indentation: indentation, leading: .mixed)
                }
            }
            let indent = spaceCount / tabSize
            let mod = spaceCount % tabSize
            if indent > 0 {
                if mod == 0 {
                    return WhitespaceStatistics(tabSize: tabSize, indentation: indentation, leading: .level(indent))
                } else {
                    return WhitespaceStatistics(tabSize: tabSize, indentation: indentation, leading: .levelWithModulus(indent, mod))
                }
            } else if mod > 0 {
                return WhitespaceStatistics(tabSize: tabSize, indentation: indentation, leading: .modulus(mod))
            }
        case .tabs:
            var tabCount = 0
            for char in whitespace {
                switch char {
                case Character("\t"):
                    tabCount += 1
                default:
                    return WhitespaceStatistics(tabSize: tabSize, indentation: indentation, leading: .mixed)
                }
            }
            return WhitespaceStatistics(tabSize: tabSize, indentation: indentation, leading: .level(tabCount))
        }
        return nil
    }
}
