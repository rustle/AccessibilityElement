//
//  TextMarkerSelectionChange.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa

public func SelectionChangeForTextMarkerChangeNotification(info: [String:Any]?,
                                                           element: AnyElement) throws -> SelectionChange<AXTextMarker>? {
    if let info = info {
        return SelectionChangeForRichTextMarkerChangeNotification(info: info,
                                                                  element: element)
    }
    let selections = try element.selectedTextMarkerRanges()
    guard selections.count > 0 else {
        throw ElementError.noValue
    }
    let selection = selections[0]
    return .move(Navigation<AXTextMarker>(element: element,
                                          selection: selection,
                                          direction: .discontiguous,
                                          granularity: .unknown,
                                          focusChanged: false,
                                          sync: false))
}
