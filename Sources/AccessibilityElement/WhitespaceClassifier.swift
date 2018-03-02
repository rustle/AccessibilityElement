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
        var lowerBound: String.Index
        if let range = value.rangeOfCharacter(from: CharacterSet.whitespaces.inverted,
                                              options: [],
                                              range: value.startIndex..<value.endIndex) {
            lowerBound = range.lowerBound
            if range.lowerBound == value.startIndex {
                leadingWhitespace = nil
            } else {
                leadingWhitespace = value.startIndex..<range.lowerBound
            }
        } else {
            leadingWhitespace = value.startIndex..<value.endIndex
            lowerBound = value.endIndex
        }
        remainder = lowerBound..<value.endIndex
    }
    public struct WhitespaceStatistics {
        public let tabSize: Int
        public let indentation: Indentation
        public enum Run {
            case spaces(Int)
            case tabs(Int)
            case other(Int)
        }
        public enum Leading {
            case mixed([Run])
            case level(Int)
            case levelWithModulus(Int, Int)
            case modulus(Int)
        }
        public var leading: Leading
    }
    private struct Constants {
        static let space = Character(" ")
        static let tab = Character("\t")
    }
    public func whitespaceStatistics() -> WhitespaceStatistics? {
        guard let leadingWhitespace = leadingWhitespace else {
            return nil
        }
        let whitespace = value[leadingWhitespace]
        #if false
        var log = String(whitespace)
        log = log.replacingOccurrences(of: " ", with: "[space]")
        log = log.replacingOccurrences(of: "\t", with: "[tab]")
        print(log)
        #endif
        switch indentation {
        case .spaces:
            var runs = [WhitespaceStatistics.Run]()
            runs.append(.spaces(0))
            for char in whitespace {
                if runs.count == 1 {
                    guard case let .spaces(count) = runs[0] else {
                        fatalError()
                    }
                    switch char {
                    case Constants.space:
                        runs[0] = .spaces(count+1)
                    case Constants.tab:
                        runs.append(.tabs(1))
                    default:
                        runs.append(.other(1))
                    }
                } else {
                    switch runs[runs.count-1] {
                    case .spaces(let count):
                        switch char {
                        case Constants.space:
                            runs[runs.count-1] = .spaces(count+1)
                        case Constants.tab:
                            runs.append(.tabs(1))
                        default:
                            runs.append(.other(1))
                        }
                    case .tabs(let count):
                        switch char {
                        case Constants.space:
                            runs.append(.spaces(1))
                        case Constants.tab:
                            runs[runs.count-1] = .tabs(count+1)
                        default:
                            runs.append(.other(1))
                        }
                    case .other(let count):
                        switch char {
                        case Constants.space:
                            runs.append(.spaces(1))
                        case Constants.tab:
                            runs.append(.tabs(1))
                        default:
                            runs[runs.count-1] = .other(count+1)
                        }
                    }
                }
            }
            guard runs.count == 1 else {
                return WhitespaceStatistics(tabSize: tabSize,
                                            indentation: indentation,
                                            leading: .mixed(runs))
            }
            guard case let .spaces(spaceCount) = runs[0] else {
                fatalError()
            }
            let indent = spaceCount / tabSize
            let mod = spaceCount % tabSize
            if indent > 0 {
                if mod == 0 {
                    return WhitespaceStatistics(tabSize: tabSize,
                                                indentation: indentation,
                                                leading: .level(indent))
                } else {
                    return WhitespaceStatistics(tabSize: tabSize,
                                                indentation: indentation,
                                                leading: .levelWithModulus(indent, mod))
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
                    return WhitespaceStatistics(tabSize: tabSize, indentation: indentation, leading: .mixed([]))
                }
            }
            return WhitespaceStatistics(tabSize: tabSize, indentation: indentation, leading: .level(tabCount))
        }
        return nil
    }
}
