//
//  TextAttachment.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct TextAttachment<ElementType> : Specialization where ElementType : AccessibilityElement {
    public var describerRequests: [DescriberRequest] {
        let requests: [DescriberRequest] = [
            Describer<ElementType>.Single(required: false, attribute: .attachmentText)
        ]
        return requests
    }
    public weak var controller: Controller<ElementType>?
    public init(controller: Controller<ElementType>) {
        self.controller = controller
    }
    private let describer = Describer<ElementType>()
    public mutating func focusIn() -> String? {
        guard let controller = controller else {
            return "no controller"
        }
        let element = controller.node.element
        _ = try? describer.describe(element: element, requests: describerRequests)
        return nil
    }
}
