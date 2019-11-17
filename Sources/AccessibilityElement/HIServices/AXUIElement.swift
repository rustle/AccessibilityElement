//
//  AXUIElement.swift
//
//  Copyright © 2017-2019 Doug Russell. All rights reserved.
//

import Cocoa

fileprivate class _UIElement {
    private static var RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)!
    typealias UIElementTransportRepresentation = @convention(c) (AXUIElement) -> Unmanaged<CFData>
    static var transportRepresentation: UIElementTransportRepresentation = {
        let symbol = dlsym(RTLD_DEFAULT,
                           "_AXUIElementRemoteTokenCreate")
        return unsafeBitCast(symbol,
                             to: UIElementTransportRepresentation.self)
    }()
    typealias UIElementCreateWithTransportRepresentation = @convention(c) (CFData) -> Unmanaged<AXUIElement>
    static var createWithTransportRepresentation: UIElementCreateWithTransportRepresentation = {
        let symbol = dlsym(RTLD_DEFAULT, "_AXUIElementCreateWithRemoteToken")
        return unsafeBitCast(symbol, to: UIElementCreateWithTransportRepresentation.self)
    }()
}

public extension AXUIElement {
    //public func AXUIElementGetTypeID() -> CFTypeID
    static var typeID: CFTypeID {
        AXUIElementGetTypeID()
    }
    //public func AXIsProcessTrustedWithOptions(_ options: CFDictionary?) -> Bool
    static func isTrusted(promptIfNeeded: Bool = true) -> Void {
        let options: CFDictionary
        if promptIfNeeded {
            options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() : kCFBooleanTrue] as CFDictionary
        } else {
            options = [:] as CFDictionary
        }
        AXIsProcessTrustedWithOptions(options)
    }
    //public func AXUIElementCreateSystemWide() -> AXUIElement
    static func systemWide() -> AXUIElement {
        AXUIElementCreateSystemWide()
    }
    //public func AXUIElementCreateApplication(_ pid: pid_t) -> AXUIElement
    static func application(processIdentifier: ProcessIdentifier) -> AXUIElement {
        AXUIElementCreateApplication(pid_t(processIdentifier))
    }
    //private func _AXUIElementRemoteTokenCreate(_ element: AXUIElement) -> CFData
    func transportRepresentation() -> Data {
        _UIElement
            .transportRepresentation(self)
            .takeUnretainedValue() as Data
    }
    //private func _AXUIElementCreateWithRemoteToken(_ data: CFData) -> AXUIElement
    static func element(transportRepresentation: Data) -> AXUIElement {
        _UIElement
            .createWithTransportRepresentation(transportRepresentation as CFData)
            .takeRetainedValue()
    }
    //public func AXUIElementCopyAttributeValues(_ element: AXUIElement,
    //                                           _ attribute: CFString,
    //                                           _ index: CFIndex,
    //                                           _ maxValues: CFIndex,
    //                                           _ values: UnsafeMutablePointer<CFArray?>) -> AXError
    //public struct AXCopyMultipleAttributeOptions : OptionSet {
    //    public init(rawValue: UInt32)
    //    public static var stopOnError: AXCopyMultipleAttributeOptions { get }
    //}
    //public func AXUIElementCopyMultipleAttributeValues(_ element: AXUIElement,
    //                                                   _ attributes: CFArray,
    //                                                   _ options: AXCopyMultipleAttributeOptions,
    //                                                   _ values: UnsafeMutablePointer<CFArray?>) -> AXError
    //public func AXUIElementGetPid(_ element: AXUIElement,
    //                              _ pid: UnsafeMutablePointer<pid_t>) -> AXError
    func processIdentifier() throws -> ProcessIdentifier {
        var value: pid_t = 0
        let error = AXUIElementGetPid(self, &value)
        guard error == .success else {
            throw ElementError(axError: error)
        }
        return ProcessIdentifier(value)
    }
    //public func AXUIElementSetMessagingTimeout(_ element: AXUIElement,
    //                                           _ timeoutInSeconds: Float) -> AXError
    func set(messageTimeout: Double) throws {
        let error = AXUIElementSetMessagingTimeout(self, Float(messageTimeout))
        guard error == .success else {
            throw ElementError(axError: error)
        }
    }
    //public func AXUIElementCopyAttributeNames(_ element: AXUIElement,
    //                                          _ names: UnsafeMutablePointer<CFArray?>) -> AXError
    func attributes() throws -> [NSAccessibility.Attribute] {
        var names: CFArray?
        let error = AXUIElementCopyAttributeNames(self,
                                                  &names)
        guard error == .success else {
            throw ElementError(axError: error)
        }
        return try cast(names)
    }
    //public func AXUIElementCopyParameterizedAttributeNames(_ element: AXUIElement,
    //                                                       _ names: UnsafeMutablePointer<CFArray?>) -> AXError
    func parameterizedAttributes() throws -> [NSAccessibility.Attribute] {
        var names: CFArray?
        let error = AXUIElementCopyParameterizedAttributeNames(self,
                                                               &names)
        guard error == .success else {
            throw ElementError(axError: error)
        }
        return try cast(names)
    }
    //public func AXUIElementCopyAttributeValue(_ element: AXUIElement,
    //                                          _ attribute: CFString,
    //                                          _ value: UnsafeMutablePointer<CoreFoundation.CFTypeRef?>) -> AXError
    func value(attribute: NSAccessibility.Attribute) throws -> Any {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(self, attribute.rawValue as CFString, &value)
        guard error == .success else {
            throw ElementError(axError: error)
        }
        return try cast(value)
    }
    //public func AXUIElementCopyParameterizedAttributeValue(_ element: AXUIElement,
    //                                                       _ parameterizedAttribute: CFString,
    //                                                       _ parameter: CoreFoundation.CFTypeRef,
    //                                                       _ result: UnsafeMutablePointer<CoreFoundation.CFTypeRef?>) -> AXError
    func parameterizedValue(attribute: NSAccessibility.ParameterizedAttribute,
                            parameter: Any) throws -> Any {
        var value: CFTypeRef?
        let error = AXUIElementCopyParameterizedAttributeValue(self,
                                                               attribute.rawValue as CFString,
                                                               parameter as CFTypeRef,
                                                               &value)
        guard error == .success else {
            throw ElementError(axError: error)
        }
        return try cast(value)
    }
    //public func AXUIElementGetAttributeValueCount(_ element: AXUIElement,
    //                                              _ attribute: CFString,
    //                                              _ count: UnsafeMutablePointer<CFIndex>) -> AXError
    func count(attribute: NSAccessibility.Attribute) throws -> Int {
        var count: CFIndex = 0
        let error = AXUIElementGetAttributeValueCount(self,
                                                      attribute.rawValue as CFString,
                                                      &count)
        guard error == .success else {
            throw ElementError(axError: error)
        }
        return count
    }
    //public func AXUIElementIsAttributeSettable(_ element: AXUIElement, _ attribute: CFString, _ settable: UnsafeMutablePointer<DarwinBoolean>) -> AXError
    func settable(attribute: NSAccessibility.Attribute) throws -> Bool {
        var value: DarwinBoolean = false
        let error = AXUIElementIsAttributeSettable(self,
                                                   attribute.rawValue as CFString,
                                                   &value)
        guard error == .success else {
            throw ElementError(axError: error)
        }
        return value.boolValue
    }
    //public func AXUIElementSetAttributeValue(_ element: AXUIElement, _ attribute: CFString, _ value: CoreFoundation.CFTypeRef) -> AXError
    func set(attribute: NSAccessibility.Attribute, value: Any?) throws {
        let error = AXUIElementSetAttributeValue(self, attribute.rawValue as CFString, value as CFTypeRef)
        guard error == .success else {
            throw ElementError(axError: error)
        }
    }
    //public func AXUIElementCopyActionNames(_ element: AXUIElement,
    //                                       _ names: UnsafeMutablePointer<CFArray?>) -> AXError
    func actions() throws -> [NSAccessibility.Action] {
        var actions: CFArray?
        let error = AXUIElementCopyActionNames(self, &actions)
        guard error == .success else {
            throw ElementError(axError: error)
        }
        return try cast(actions)
    }
    //public func AXUIElementCopyActionDescription(_ element: AXUIElement,
    //                                             _ action: CFString,
    //                                             _ description: UnsafeMutablePointer<CFString?>) -> AXError
    func description(action: NSAccessibility.Action) throws -> String {
        var description: CFString?
        let error = AXUIElementCopyActionDescription(self,
                                                     action.rawValue as CFString,
                                                     &description)
        guard error == .success else {
            throw ElementError(axError: error)
        }
        return try cast(description)
    }
    //public func AXUIElementPerformAction(_ element: AXUIElement, _ action: CFString) -> AXError
    func perform(action: NSAccessibility.Action) throws {
        let error = AXUIElementPerformAction(self,
                                             action as CFString)
        guard error == .success else {
            throw ElementError(axError: error)
        }
    }
    //public func AXUIElementCopyElementAtPosition(_ application: AXUIElement,
    //                                             _ x: Float,
    //                                             _ y: Float,
    //                                             _ element: UnsafeMutablePointer<AXUIElement?>) -> AXError
    func at(point: CGPoint) throws -> AXUIElement {
        var uiElement: AXUIElement?
        let error = AXUIElementCopyElementAtPosition(self,
                                                     Float(point.x),
                                                     Float(point.y),
                                                     &uiElement)
        guard error == .success else {
            throw ElementError(axError: error)
        }
        return try cast(uiElement)
    }
    private func cast<T>(_ value: Any?) throws -> T {
        guard let a = value else {
            throw ElementError.noValue
        }
        guard let b = a as? T else {
            throw AccessibilityError.typeMismatch
        }
        return b
    }
}
