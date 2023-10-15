//
//  AccessibilityError.swift
//
//  Copyright © 2017-2023 Doug Russell. All rights reserved.
//

import AX
import Cocoa

///
public enum AccessibilityError: Error {
    ///
    case typeMismatch
    ///
    case invalidInput
}

/// 
public enum ElementError: Error {
    /// The action is not supported by the UIElement.
    case actionUnsupported
    /// The accessibility API is disabled.
    case apiDisabled
    /// The attribute is not supported by the UIElement.
    case attributeUnsupported
    /// The parameterized attribute is not supported by the UIElement.
    case parameterizedAttributeUnsupported
    /// The function cannot complete because messaging failed in some way or because the application with which the function is communicating is busy or unresponsive.
    case cannotComplete
    /// A system error occurred, such as the failure to allocate an object.
    case failure
    /// An illegal argument was passed to the function.
    case illegalArgument
    /// The UIElement passed to the function is invalid.
    case invalidUIElement
    /// Not enough precision.
    case notEnoughPrecision
    /// Indicates that the function or method is not implemented (this can be returned if a process does not support the accessibility API).
    case notImplemented
    /// The requested value or UIElement does not exist.
    case noValue
    ///
    init(error: AX.AXError) {
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
        case .notEnoughPrecision:
            self = .notEnoughPrecision
        case .notificationAlreadyRegistered:
            self = .cannotComplete
        case .notImplemented:
            self = .notImplemented
        case .notificationNotRegistered:
            fatalError()
        case .noValue:
            self = .noValue
        case .parameterizedAttributeUnsupported:
            self = .parameterizedAttributeUnsupported
        default:
            fatalError()
        }
    }
    public var localizedDescription: String {
        switch self {
        case .actionUnsupported:
            return "ElementError.actionUnsupported - The action is not supported by the UIElement."
        case .apiDisabled:
            return "ElementError.apiDisabled - The accessibility API is disabled."
        case .attributeUnsupported:
            return "ElementError.attributeUnsupported - The attribute is not supported by the UIElement."
        case .parameterizedAttributeUnsupported:
            return "ElementError.parameterizedAttributeUnsupported - The parameterized attribute is not supported by the UIElement."
        case .cannotComplete:
            return "ElementError.cannotComplete - The function cannot complete because messaging failed in some way or because the application with which the function is communicating is busy or unresponsive."
        case .failure:
            return "ElementError.failure - A system error occurred, such as the failure to allocate an object."
        case .illegalArgument:
            return "ElementError.illegalArgument - An illegal argument was passed to the function."
        case .invalidUIElement:
            return "ElementError.invalidUIElement - The UIElement passed to the function is invalid."
        case .notEnoughPrecision:
            return "ElementError.notEnoughPrecision - Not enough precision."
        case .notImplemented:
            return "ElementError.notImplemented - Indicates that the function or method is not implemented (this can be returned if a process does not support the accessibility API)."
        case .noValue:
            return "ElementError.noValue - The requested value or UIElement does not exist."
        }
    }
}

///
public enum ObserverError: Error {
    /// The accessibility API is disabled.
    case apiDisabled
    /// The function cannot complete because messaging failed in some way or because the application with which the function is communicating is busy or unresponsive.
    case cannotComplete
    /// A system error occurred, such as the failure to allocate an object.
    case failure
    /// An illegal argument was passed to the function.
    case illegalArgument
    /// The UIElement passed to the function is invalid.
    case invalidUIElement
    /// The Observer passed to the function is not a valid observer.
    case invalidUIElementObserver
    /// This notification has already been registered.
    case notificationAlreadyRegistered
    /// The notification is not supported by the UIElement
    case notificationUnsupported
    /// Indicates that the function or method is not implemented (this can be returned if a process does not support the accessibility API).
    case notImplemented
    /// Indicates that a notification is not registered yet.
    case notificationNotRegistered
    /// The requested value or UIElement does not exist.
    case noValue
    ///
    init(error: AX.AXError) {
        switch error {
        case .apiDisabled:
            self = .apiDisabled
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
        case .notificationAlreadyRegistered:
            self = .notificationAlreadyRegistered
        case .notificationUnsupported:
            self = .notificationUnsupported
        case .notImplemented:
            self = .notImplemented
        case .notificationNotRegistered:
            self = .notificationNotRegistered
        case .noValue:
            self = .noValue
        default:
            fatalError()
        }
    }
    public var localizedDescription: String {
        switch self {
        case .apiDisabled:
            return "ObserverError.apiDisabled - The accessibility API is disabled."
        case .cannotComplete:
            return "ObserverError.cannotComplete - The function cannot complete because messaging failed in some way or because the application with which the function is communicating is busy or unresponsive."
        case .failure:
            return "ObserverError.failure - A system error occurred, such as the failure to allocate an object."
        case .illegalArgument:
            return "ObserverError.illegalArgument - An illegal argument was passed to the function."
        case .invalidUIElement:
            return "ObserverError.invalidUIElement - The UIElement passed to the function is invalid."
        case .invalidUIElementObserver:
            return "ObserverError.invalidUIElementObserver - The Observer passed to the function is not a valid observer."
        case .notificationAlreadyRegistered:
            return "ObserverError.notificationAlreadyRegistered - This notification has already been registered."
        case .notificationUnsupported:
            return "ObserverError.notificationUnsupported - The notification is not supported by the UIElement"
        case .notImplemented:
            return "ObserverError.notImplemented - Indicates that the function or method is not implemented (this can be returned if a process does not support the accessibility API)."
        case .notificationNotRegistered:
            return "ObserverError.notificationNotRegistered - Indicates that a notification is not registered yet."
        case .noValue:
            return "ObserverError.noValue - The requested value or UIElement does not exist."
        }
    }
}

func promoteAXObserverErrorToObserverErrorOnThrow<T>(_ work: () throws -> T) rethrows -> T {
    do {
        return try work()
    } catch let error as AX.AXError {
        throw ObserverError(error: error)
    } catch {
        throw error
    }
}
