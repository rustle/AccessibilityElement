//
//  Specialization.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public protocol AnySpecialization {
    var describerRequests: [DescriberRequest] { get }
    mutating func connect() -> String?
    mutating func focusIn() -> String?
    mutating func focusOut() -> String?
}

public protocol Specialization : AnySpecialization {
    associatedtype ElementType : AccessibilityElement
    weak var controller: Controller<ElementType>? { get }
}

public extension Specialization {
    mutating public func connect() -> String? {
        return nil
    }
    mutating public func focusIn() -> String? {
        guard let controller = controller else {
            return nil
        }
        if controller.childControllers == nil {
            controller.childControllers = controller.childControllers(node: controller.node)
        }
        return nil
    }
    mutating public func focusOut() -> String? {
        return nil
    }
}
