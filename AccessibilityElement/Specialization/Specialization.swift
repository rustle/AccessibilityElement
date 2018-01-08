//
//  Specialization.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public protocol AnySpecialization {
    func connect()
    func focusIn()
    func focusOut()
}

public protocol Specialization : AnySpecialization {
    associatedtype ElementType : AccessibilityElement
    weak var controller: Controller<ElementType>? { get }
}

public extension Specialization {
    public func connect() {
        
    }
    public func focusIn() {
        guard let controller = controller else {
            return
        }
        if controller.childControllers == nil {
            controller.childControllers = controller.childControllers(node: controller.node)
        }
    }
    public func focusOut() {
        
    }
}
