//
//  TextMarkerSelectionChange.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa

fileprivate enum AXTextStateChangeType : Int {
    case unknown
    case edit
    case move
    case extend
    case boundary
}

fileprivate enum AXTextEditType : Int {
    case unknown
    case delete // Generic text delete
    case insert // Generic text insert
    case typing // Insert via typing
    case dictation // Insert via dictation
    case cut // Delete via Cut
    case paste // Insert via Paste
    case attributesChange // Change font, style, alignment, color, etc.
}

fileprivate enum AXTextSelectionDirection : Int {
    case unknown
    case beginning
    case end
    case previous
    case next
    case discontiguous
}

fileprivate enum AXTextSelectionGranularity : Int {
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

fileprivate struct TextMarkerSelectionChangeKeys {
    static let changeType = "AXTextStateChangeType"
    static let editType = "AXTextStateChangeType"
}

fileprivate func _ProbablyChromiumSelectionChangeForRichTextMarkerChangeNotification(info: [String:Any],
                                                                                     element: AnyElement) -> SelectionChange<AXTextMarker>? {
    guard let navigation = NavigationForRichTextMarkerChangeNotification(info: info, element: element) else {
        return nil
    }
    return .move(navigation)
}

public func SelectionChangeForRichTextMarkerChangeNotification(info: [String:Any],
                                                               element: AnyElement) -> SelectionChange<AXTextMarker>? {
    guard let typeRawValue = info[TextMarkerSelectionChangeKeys.changeType] as? Int else {
        return nil
    }
    guard let type = AXTextStateChangeType(rawValue: typeRawValue) else {
        return nil
    }
    switch type {
    case .unknown:
        return _ProbablyChromiumSelectionChangeForRichTextMarkerChangeNotification(info: info,
                                                                                   element: element)
    case .edit:
        guard let editRawValue = info[TextMarkerSelectionChangeKeys.editType] as? Int else {
            return nil
        }
        guard let edit = AXTextEditType(rawValue: editRawValue) else {
            return nil
        }
        switch edit {
        case .unknown:
            return nil
        case .delete:
            return .edit(.delete)
        case .insert:
            return .edit(.insert)
        case .typing:
            return .edit(.typing)
        case .dictation:
            return .edit(.dictation)
        case .cut:
            return .edit(.cut)
        case .paste:
            return .edit(.paste)
        case .attributesChange:
            return .edit(.attributesChange)
        }
    case .move:
        guard let navigation = NavigationForRichTextMarkerChangeNotification(info: info,
                                                                             element: element) else {
            return nil
        }
        return .move(navigation)
    case .extend:
        guard let navigation = NavigationForRichTextMarkerChangeNotification(info: info,
                                                                             element: element) else {
            return nil
        }
        return .extend(navigation)
    case .boundary:
        guard let navigation = NavigationForRichTextMarkerChangeNotification(info: info,
                                                                             element: element) else {
            return nil
        }
        return .boundary(navigation)
    }
}

fileprivate struct TextMarkerNavigationKeys {
    static let sync = "AXTextStateSync"
    static let direction = "AXTextSelectionDirection"
    static let granularity = "AXTextSelectionGranularity"
    static let focusChanged = "AXTextSelectionChangedFocus"
    static let textChangeElement = "AXTextChangeElement"
    static let selectedTextMarkerRange = "AXSelectedTextMarkerRange"
}

public func _ProbablyChromiumNavigationForRichTextMarkerChangeNotification(info: [String:Any],
                                                                           element: AnyElement) -> Navigation<AXTextMarker>? {
    let element = info[TextMarkerNavigationKeys.textChangeElement] as? Element
    let selection = info[TextMarkerNavigationKeys.selectedTextMarkerRange] as? Range<Position<AXTextMarker>>
    return Navigation<AXTextMarker>(element: element,
                                    selection: selection,
                                    direction: nil,
                                    granularity: nil,
                                    focusChanged: false,
                                    sync: false)
}

public func NavigationForRichTextMarkerChangeNotification(info: [String:Any],
                                                          element: AnyElement) -> Navigation<AXTextMarker>? {
    guard let directionRawValue = info[TextMarkerNavigationKeys.direction] as? Int else {
        return nil
    }
    guard let axDirection = AXTextSelectionDirection(rawValue: directionRawValue) else {
        return nil
    }
    guard let axGranularityRawValue = info[TextMarkerNavigationKeys.granularity] as? Int else {
        return nil
    }
    guard let axGranularity = AXTextSelectionGranularity(rawValue: axGranularityRawValue) else {
        return nil
    }
    let focusChanged = info[TextMarkerNavigationKeys.focusChanged] as? Bool ?? false
    let sync = info[TextMarkerNavigationKeys.sync] as? Bool ?? false
    let direction: Navigation<AXTextMarker>.Direction
    switch axDirection {
    case .unknown:
        return _ProbablyChromiumNavigationForRichTextMarkerChangeNotification(info: info,
                                                                              element: element)
    case .beginning:
        direction = .beginning
    case .end:
        direction = .end
    case .previous:
        direction = .previous
    case .next:
        direction = .next
    case .discontiguous:
        direction = .discontiguous
    }
    let granularity: Navigation<AXTextMarker>.Granularity
    switch axGranularity {
    case .unknown:
        return _ProbablyChromiumNavigationForRichTextMarkerChangeNotification(info: info,
                                                                              element: element)
    case .character:
        granularity = .character
    case .word:
        granularity = .word
    case .line:
        granularity = .line
    case .sentence:
        granularity = .sentence
    case .paragraph:
        granularity = .paragraph
    case .page:
        granularity = .page
    case .document:
        granularity = .document
    case .all:
        granularity = .all
    }
    let element = info[TextMarkerNavigationKeys.textChangeElement] as? Element
    let selection = info[TextMarkerNavigationKeys.selectedTextMarkerRange] as? Range<Position<AXTextMarker>>
    return Navigation<AXTextMarker>(element: element,
                                    selection: selection,
                                    direction: direction,
                                    granularity: granularity,
                                    focusChanged: focusChanged,
                                    sync: sync)
}
