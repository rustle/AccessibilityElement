//
//  Button.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct Button<ElementType> : Specialization where ElementType : _AccessibilityElement {
    public var describerRequests: [DescriberRequest] {
        let requests: [DescriberRequest] = [
            Describer<ElementType>.Fallthrough(required: true, attributes: [.title, .description, .stringValue, .titleElement(Describer<ElementType>.Fallthrough(required: true, attributes: [.title, .description, .stringValue]))]),
            Describer<ElementType>.Single(required: true, attribute: .roleDescription),
        ]
        return requests
    }
    public weak var controller: Controller<ElementType>?
    public init(controller: Controller<ElementType>) {
        self.controller = controller
    }
    public mutating func focusIn() -> String? {
        guard let controller = controller else {
            return nil
        }
        let element = controller.node.element
        guard let results = try? Describer().describe(element: element, requests: describerRequests) else {
            return nil
        }
        return results.map { $0! }.joined(separator: ", ")
    }
}
