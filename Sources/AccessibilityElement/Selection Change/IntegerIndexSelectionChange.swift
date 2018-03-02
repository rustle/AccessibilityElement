//
//  IntegerIndexSelectionChange.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa

public func SelectionChangeForIntegerIndexChangeNotification(info: [String:Any],
                                                             element: AnyElement) throws -> SelectionChange<Int>? {
    let selections = try element.selectedTextRanges()
    guard selections.count > 0 else {
        throw ElementError.noValue
    }
    let selection = selections[0]
    return .move(Navigation<Int>(element: element,
                                 selection: selection,
                                 direction: .discontiguous,
                                 granularity: .unknown,
                                 focusChanged: false,
                                 sync: false))
}
