//
//  AXUIElement.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import Cocoa

public extension AXUIElement {
    public enum AXError : Error {
        case actionUnsupported
        case apiDisabled
        case attributeUnsupported
        case cannotComplete
        case failure
        case illegalArgument
        case invalidUIElement
        case invalidUIElementObserver
        case notEnoughPrecision
        case notificationAlreadyRegistered
        case success
        case notificationUnsupported
        case notImplemented
        case notificationNotRegistered
        case noValue
        case parameterizedAttributeUnsupported
        init(error: ApplicationServices.AXError) {
            switch error {
            case .actionUnsupported:
                self = .actionUnsupported
            case .apiDisabled:
                self = .apiDisabled
            case .attributeUnsupported:
                self = .attributeUnsupported
            case .cannotComplete:
                self = .cannotComplete
            case .failure:
                self = .failure
            case .illegalArgument:
                self = .illegalArgument
            case .invalidUIElement:
                self = .invalidUIElement
            case .invalidUIElementObserver:
                self = .invalidUIElementObserver
            case .notEnoughPrecision:
                self = .notEnoughPrecision
            case .notificationAlreadyRegistered:
                self = .notificationAlreadyRegistered
            case .success:
                self = .success
            case .notificationUnsupported:
                self = .notificationUnsupported
            case .notImplemented:
                self = .notImplemented
            case .notificationNotRegistered:
                self = .notificationNotRegistered
            case .noValue:
                self = .noValue
            case .parameterizedAttributeUnsupported:
                self = .parameterizedAttributeUnsupported
            }
        }
    }
    //public func AXUIElementGetTypeID() -> CFTypeID
    public static var typeID: CFTypeID {
        return AXUIElementGetTypeID()
    }
    //public func AXIsProcessTrustedWithOptions(_ options: CFDictionary?) -> Bool
    public static func isTrusted(promptIfNeeded: Bool = true) -> Void {
        let options: CFDictionary
        if promptIfNeeded {
            options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() : kCFBooleanTrue] as CFDictionary
        } else {
            options = [:] as CFDictionary
        }
        AXIsProcessTrustedWithOptions(options)
    }
    //public func AXUIElementCreateSystemWide() -> AXUIElement
    public static func systemWide() -> AXUIElement {
        return AXUIElementCreateSystemWide()
    }
    //public func AXUIElementCreateApplication(_ pid: pid_t) -> AXUIElement
    public static func application(processIdentifier: Int) -> AXUIElement {
        return AXUIElementCreateApplication(pid_t(processIdentifier))
    }

    //public func AXUIElementCopyAttributeValues(_ element: AXUIElement, _ attribute: CFString, _ index: CFIndex, _ maxValues: CFIndex, _ values: UnsafeMutablePointer<CFArray?>) -> AXError

    //public struct AXCopyMultipleAttributeOptions : OptionSet {
    //    public init(rawValue: UInt32)
    //    public static var stopOnError: AXCopyMultipleAttributeOptions { get }
    //}
    //public func AXUIElementCopyMultipleAttributeValues(_ element: AXUIElement, _ attributes: CFArray, _ options: AXCopyMultipleAttributeOptions, _ values: UnsafeMutablePointer<CFArray?>) -> AXError

    //public func AXUIElementGetPid(_ element: AXUIElement, _ pid: UnsafeMutablePointer<pid_t>) -> AXError
    public func processIdentifier() throws -> Int {
        var value: pid_t = 0
        let error = AXUIElementGetPid(self, &value)
        guard error == .success else {
            throw AXError(error: error)
        }
        return Int(value)
    }
    //public func AXUIElementSetMessagingTimeout(_ element: AXUIElement, _ timeoutInSeconds: Float) -> AXError
    public func set(messageTimeout: Double) throws {
        let error = AXUIElementSetMessagingTimeout(self, Float(messageTimeout))
        guard error == .success else {
            throw AXError(error: error)
        }
    }
    //public func AXUIElementCopyAttributeNames(_ element: AXUIElement, _ names: UnsafeMutablePointer<CFArray?>) -> AXError
    public func attributes() throws -> [NSAccessibilityAttributeName] {
        var names: CFArray?
        let error = AXUIElementCopyAttributeNames(self, &names)
        guard error == .success else {
            throw AXError(error: error)
        }
        return try cast(names)
    }
    //public func AXUIElementCopyParameterizedAttributeNames(_ element: AXUIElement, _ names: UnsafeMutablePointer<CFArray?>) -> AXError
    public func parameterizedAttributes() throws -> [NSAccessibilityAttributeName] {
        var names: CFArray?
        let error = AXUIElementCopyParameterizedAttributeNames(self, &names)
        guard error == .success else {
            throw AXError(error: error)
        }
        return try cast(names)
    }
    //public func AXUIElementCopyAttributeValue(_ element: AXUIElement, _ attribute: CFString, _ value: UnsafeMutablePointer<CoreFoundation.CFTypeRef?>) -> AXError
    public func value(attribute: NSAccessibilityAttributeName) throws -> Any {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(self, attribute as CFString, &value)
        guard error == .success else {
            throw AXError(error: error)
        }
        return try cast(value)
    }
    //public func AXUIElementCopyParameterizedAttributeValue(_ element: AXUIElement, _ parameterizedAttribute: CFString, _ parameter: CoreFoundation.CFTypeRef, _ result: UnsafeMutablePointer<CoreFoundation.CFTypeRef?>) -> AXError
    public func parameterizedValue(attribute: NSAccessibilityAttributeName, parameter: Any) throws -> Any {
        var value: CFTypeRef?
        let error = AXUIElementCopyParameterizedAttributeValue(self, attribute as CFString, parameter as CFTypeRef, &value)
        guard error == .success else {
            throw AXError(error: error)
        }
        return try cast(value)
    }
    //public func AXUIElementGetAttributeValueCount(_ element: AXUIElement, _ attribute: CFString, _ count: UnsafeMutablePointer<CFIndex>) -> AXError
    public func count(attribute: String) throws -> Int {
        var count: CFIndex = 0
        let error = AXUIElementGetAttributeValueCount(self, attribute as CFString, &count)
        guard error == .success else {
            throw AXError(error: error)
        }
        return count
    }
    //public func AXUIElementIsAttributeSettable(_ element: AXUIElement, _ attribute: CFString, _ settable: UnsafeMutablePointer<DarwinBoolean>) -> AXError
    public func settable(attribute: String) throws -> Bool {
        var value: DarwinBoolean = false
        let error = AXUIElementIsAttributeSettable(self, attribute as CFString, &value)
        guard error == .success else {
            throw AXError(error: error)
        }
        return value.boolValue
    }
    //public func AXUIElementSetAttributeValue(_ element: AXUIElement, _ attribute: CFString, _ value: CoreFoundation.CFTypeRef) -> AXError
    public func set(attribute: String, value: Any?) throws {
        let error = AXUIElementSetAttributeValue(self, attribute as CFString, value as CFTypeRef)
        guard error == .success else {
            throw AXError(error: error)
        }
    }
    //public func AXUIElementCopyActionNames(_ element: AXUIElement, _ names: UnsafeMutablePointer<CFArray?>) -> AXError
    public func actions() throws -> [NSAccessibilityActionName] {
        var actions: CFArray?
        let error = AXUIElementCopyActionNames(self, &actions)
        guard error == .success else {
            throw AXError(error: error)
        }
        return try cast(actions)
    }
    //public func AXUIElementCopyActionDescription(_ element: AXUIElement, _ action: CFString, _ description: UnsafeMutablePointer<CFString?>) -> AXError
    public func description(action: NSAccessibilityActionName) throws -> String {
        var description: CFString?
        let error = AXUIElementCopyActionDescription(self, action.rawValue as CFString, &description)
        guard error == .success else {
            throw AXError(error: error)
        }
        return try cast(description)
    }
    //public func AXUIElementPerformAction(_ element: AXUIElement, _ action: CFString) -> AXError
    public func perform(action: NSAccessibilityActionName) throws {
        let error = AXUIElementPerformAction(self, action as CFString)
        guard error == .success else {
            throw AXError(error: error)
        }
    }
    //public func AXUIElementCopyElementAtPosition(_ application: AXUIElement, _ x: Float, _ y: Float, _ element: UnsafeMutablePointer<AXUIElement?>) -> AXError
    public func at(point: CGPoint) throws -> AXUIElement {
        var uiElement: AXUIElement?
        let error = AXUIElementCopyElementAtPosition(self, Float(point.x), Float(point.y), &uiElement)
        guard error == .success else {
            throw AXError(error: error)
        }
        return try cast(uiElement)
    }
    private func cast<T>(_ value: Any?) throws -> T {
        guard let a = value else {
            throw AXError.noValue
        }
        guard let b = a as? T else {
            throw AccessibilityError.typeMismatch
        }
        return b
    }
}
