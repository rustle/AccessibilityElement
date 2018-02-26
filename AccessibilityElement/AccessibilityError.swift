//
//  AccessibilityError.swift
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

import Foundation

///
public enum AccessibilityError : Error {
    ///
    case typeMismatch
    ///
    case invalidInput
}

/// 
public enum ElementError : Error {
    ///
    case actionUnsupported
    ///
    case apiDisabled
    ///
    case attributeUnsupported
    ///
    case parameterizedAttributeUnsupported
    ///
    case cannotComplete
    ///
    case failure
    ///
    case illegalArgument
    ///
    case invalidUIElement
    ///
    case notEnoughPrecision
    ///
    case notImplemented
    ///
    case noValue
    ///
    init(axError: ApplicationServices.AXError) {
        switch axError {
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
            fatalError()
        case .notEnoughPrecision:
            self = .notEnoughPrecision
        case .notificationAlreadyRegistered:
            self = .cannotComplete
        case .success:
            fatalError()
        case .notificationUnsupported:
            fatalError()
        case .notImplemented:
            self = .notImplemented
        case .notificationNotRegistered:
            fatalError()
        case .noValue:
            self = .noValue
        case .parameterizedAttributeUnsupported:
            self = .parameterizedAttributeUnsupported
        }
    }
}

///
public enum ObserverError : Error {
    ///
    case actionUnsupported
    ///
    case apiDisabled
    ///
    case attributeUnsupported
    ///
    case parameterizedAttributeUnsupported
    ///
    case cannotComplete
    ///
    case failure
    ///
    case illegalArgument
    ///
    case invalidUIElement
    ///
    case invalidUIElementObserver
    ///
    case notEnoughPrecision
    ///
    case notificationAlreadyRegistered
    ///
    case notificationUnsupported
    ///
    case notImplemented
    ///
    case notificationNotRegistered
    ///
    case noValue
    ///
    init(axError: ApplicationServices.AXError) {
        switch axError {
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
            fatalError()
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
