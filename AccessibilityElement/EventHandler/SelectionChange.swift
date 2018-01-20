//
//  SelectionChange.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

enum AXTextStateChangeType : Int {
    case unknown
    case edit
    case move
    case extend
    case boundary
}

enum AXTextEditType : Int {
    case unknown
    case delete // Generic text delete
    case insert // Generic text insert
    case typing // Insert via typing
    case dictation // Insert via dictation
    case cut // Delete via Cut
    case paste // Insert via Paste
    case attributesChange // Change font, style, alignment, color, etc.
}

enum AXTextSelectionDirection : Int {
    case unknown
    case beginning
    case end
    case previous
    case next
    case discontiguous
}

enum AXTextSelectionGranularity : Int {
    case unknown
    case character
    case word
    case line
    case sentence
    case paragraph
    case page
    case document
    case all // All granularity represents the action of selecting the whole document as a single action. Extending selection by some other granularity until it encompasses the whole document will not result in a all granularity notification.
}

public enum SelectionChange {
    struct Keys {
        static let changeType = "AXTextStateChangeType"
        static let editType = "AXTextStateChangeType"
    }
    case edit(Edit)
    case move(Navigation)
    case extend(Navigation)
    case boundary(Navigation)
    public init?(info: [String:Any], element: AnyElement) {
        guard let typeRawValue = info[Keys.changeType] as? Int else {
            return nil
        }
        guard let type = AXTextStateChangeType(rawValue: typeRawValue) else {
            return nil
        }
        switch type {
        case .unknown:
            return nil
        case .edit:
            guard let editRawValue = info[Keys.editType] as? Int else {
                return nil
            }
            guard let edit = AXTextEditType(rawValue: editRawValue) else {
                return nil
            }
            switch edit {
            case .unknown:
                return nil
            case .delete:
                self = .edit(.delete)
            case .insert:
                self = .edit(.insert)
            case .typing:
                self = .edit(.typing)
            case .dictation:
                self = .edit(.dictation)
            case .cut:
                self = .edit(.cut)
            case .paste:
                self = .edit(.paste)
            case .attributesChange:
                self = .edit(.attributesChange)
            }
        case .move:
            guard let navigation = Navigation(info: info, element: element) else {
                return nil
            }
            self = .move(navigation)
        case .extend:
            guard let navigation = Navigation(info: info, element: element) else {
                return nil
            }
            self = .extend(navigation)
        case .boundary:
            guard let navigation = Navigation(info: info, element: element) else {
                return nil
            }
            self = .boundary(navigation)
        }
    }
}

public enum Edit {
    case delete // Generic text delete
    case insert // Generic text insert
    case typing // Insert via typing
    case dictation // Insert via dictation
    case cut // Delete via Cut
    case paste // Insert via Paste
    case attributesChange // Change font, style, alignment, color, etc.
}

public struct Navigation {
    struct Keys {
        static let sync = "AXTextStateSync"
        static let direction = "AXTextSelectionDirection"
        static let granularity = "AXTextSelectionGranularity"
        static let focusChanged = "AXTextSelectionChangedFocus"
    }
    public enum Direction {
        case beginning
        case end
        case previous
        case next
        case discontiguous
    }
    public enum Granularity {
        case unknown
        case character
        case word
        case line
        case sentence
        case paragraph
        case page
        case document
        case all // All granularity represents the action of selecting the whole document as a single action. Extending selection by some other granularity until it encompasses the whole document will not result in a all granularity notification.
    }
    public var element: AnyElement?
    public var selection: Range<Position<AXTextMarker>>?
    public var direction: Direction
    public var granulatiry: Granularity
    public var focusChanged: Bool
    public var sync: Bool
    public init?(info: [String:Any], element: AnyElement) {
        guard let directionRawValue = info[Keys.direction] as? Int else {
            return nil
        }
        guard let direction = AXTextSelectionDirection(rawValue: directionRawValue) else {
            return nil
        }
        guard let granularityRawValue = info[Keys.granularity] as? Int else {
            return nil
        }
        guard let granularity = AXTextSelectionGranularity(rawValue: granularityRawValue) else {
            return nil
        }
        focusChanged = info[Keys.focusChanged] as? Bool ?? false
        sync = info[Keys.focusChanged] as? Bool ?? false
        switch direction {
        case .unknown:
            return nil
        case .beginning:
            self.direction = .beginning
        case .end:
            self.direction = .end
        case .previous:
            self.direction = .previous
        case .next:
            self.direction = .next
        case .discontiguous:
            self.direction = .discontiguous
        }
        switch granularity {
        case .unknown:
            return nil
        case .character:
            self.granulatiry = .character
        case .word:
            self.granulatiry = .word
        case .line:
            self.granulatiry = .line
        case .sentence:
            self.granulatiry = .sentence
        case .paragraph:
            self.granulatiry = .paragraph
        case .page:
            self.granulatiry = .page
        case .document:
            self.granulatiry = .document
        case .all:
            self.granulatiry = .all
        }
        self.element = info["AXTextChangeElement"] as? Element
        selection = info["AXSelectedTextMarkerRange"] as? Range<Position<AXTextMarkerRange>>
    }
}
