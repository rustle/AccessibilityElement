//
//  Specialization.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public protocol AnySpecialization {
    var describerRequests: [DescriberRequest] { get }
    mutating func connect()
    mutating func focusIn() -> String?
    mutating func focusOut() -> String?
    mutating func disconnect()
}

public protocol Specialization : AnySpecialization {
    associatedtype ElementType : _AccessibilityElement
    weak var controller: Controller<ElementType>? { get }
}

public extension Specialization {
    mutating public func connect() {
        
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
    mutating func disconnect() {
        
    }
}

public struct CoercingLens<FocusedType, ValueType, CoercedType> {
    public var value: CoercedType? {
        get {
            return target[keyPath: keyPath] as? CoercedType
        }
        set {
            if let value = newValue as? ValueType {
                target[keyPath: keyPath] = value
            }
        }
    }
    private let target: FocusedType
    private let keyPath: ReferenceWritableKeyPath<FocusedType, ValueType>
    public init(target: FocusedType, keyPath: ReferenceWritableKeyPath<FocusedType, ValueType>) {
        self.target = target
        self.keyPath = keyPath
    }
}

public extension Specialization {
    public var lens: CoercingLens<Controller<ElementType>, AnySpecialization, Self>? {
        guard let controller = self.controller else {
            return nil
        }
        return CoercingLens(target: controller, keyPath: \Controller<ElementType>.specialization)
    }
}
