//
//  TextField.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct TextField<ElementType> : Specialization where ElementType : _AccessibilityElement {
    public var describerRequests: [DescriberRequest] = {
        let requests: [DescriberRequest] = [
            Describer<ElementType>.Single(required: true, attribute: .attachmentText),
        ]
        return requests
    }()
    public weak var controller: Controller<ElementType>?
    public init(controller: Controller<ElementType>) {
        self.controller = controller
    }
    private let describer = Describer<ElementType>()
    public mutating func focusIn() -> String? {
        guard let controller = controller else {
            return nil
        }
        let element = controller.node.element
        guard let results: [String?] = try? Describer().describe(element: element, requests: describerRequests) else {
            return nil
        }
        return results.prune().first
    }
}
