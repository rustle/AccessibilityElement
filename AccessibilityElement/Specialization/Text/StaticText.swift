//
//  StaticText.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct StaticText<ElementType> : Specialization where ElementType : AccessibilityElement {
    public var describerRequests: [DescriberRequest] {
        let requests: [DescriberRequest] = [
            Describer<ElementType>.Single(required: true, attribute: .stringValue)
        ]
        return requests
    }
    public weak var controller: Controller<ElementType>?
    public init(controller: Controller<ElementType>) {
        self.controller = controller
    }
    public mutating func focusIn() -> String? {
        guard let controller = controller else {
            return "no controller"
        }
        let element = controller.node.element
        guard let results: [String?] = try? Describer().describe(element: element, requests: describerRequests) else {
            return nil
        }
        return results.prune().joined(separator: "")
    }
}
