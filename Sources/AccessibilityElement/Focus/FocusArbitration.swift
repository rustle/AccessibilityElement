//
//  FocusArbitration.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa
import Signals

/// Evaluate cascading list of focus providers to find the currently focused application
public class FocusArbitrator {
    /// Common errors a focus provider may encounter
    public enum Error : Swift.Error {
        case timedOut
        case nilFocus
        case nilBundleIdentifier
    }
    public static func systemFocusedApplicationElement() throws -> (ProcessIdentifier, BundleIdentifier) {
        func systemFocus() throws -> SystemElement {
            let value = try AXUIElement.systemWide().value(attribute: NSAccessibilityAttributeName(rawValue: "AXFocusedApplication")) as CFTypeRef
            if CFGetTypeID(value) == AXUIElement.typeID {
                return SystemElement(element: value as! AXUIElement)
            }
            throw AccessibilityError.typeMismatch
        }
        func runningApplication(processIdentifier: Int) -> NSRunningApplication? {
            for application in NSWorkspace.shared.runningApplications {
                if application.processIdentifier == processIdentifier {
                    return application
                }
            }
            return nil
        }
        func systemFocus(timeout milliseconds: Int) throws -> SystemElement {
            let group = DispatchGroup()
            group.enter()
            var focusedApplication: SystemElement?
            DispatchQueue.global().async {
                do {
                    focusedApplication = try systemFocus()
                    group.leave()
                } catch {
                    group.leave()
                }
            }
            switch group.wait(timeout: DispatchTime.now() + .milliseconds(milliseconds)) {
            case .success:
                if let focusedApplication = focusedApplication {
                    return focusedApplication
                }
                throw FocusArbitrator.Error.nilFocus
            case .timedOut:
                throw FocusArbitrator.Error.timedOut
            }
        }
        let focusedElement = try systemFocus(timeout: 16)
        if let bundleIdentifier = BundleIdentifier(rawValue: runningApplication(processIdentifier: focusedElement.processIdentifier)?.bundleIdentifier) {
            return (focusedElement.processIdentifier, bundleIdentifier)
        }
        throw FocusArbitrator.Error.nilBundleIdentifier
    }
    public static func frontmostApplication() throws -> (ProcessIdentifier, BundleIdentifier) {
        if let frontmost = NSWorkspace.shared.frontmostApplication {
            if let bundleIdentifier = BundleIdentifier(rawValue: frontmost.bundleIdentifier) {
                return (ProcessIdentifier(frontmost.processIdentifier), bundleIdentifier)
            }
            throw FocusArbitrator.Error.nilBundleIdentifier
        }
        throw FocusArbitrator.Error.nilFocus
    }
    public static func menuBarOwningApplication() throws -> (ProcessIdentifier, BundleIdentifier) {
        if let menuBar = NSWorkspace.shared.menuBarOwningApplication {
            if let bundleIdentifier = BundleIdentifier(rawValue: menuBar.bundleIdentifier) {
                return (Int(menuBar.processIdentifier), bundleIdentifier)
            }
            throw FocusArbitrator.Error.nilBundleIdentifier
        }
        throw FocusArbitrator.Error.nilFocus
    }
    public let focus: Signal<(ProcessIdentifier, BundleIdentifier)> = Signal()
    public init(focusProviders: [() throws -> (ProcessIdentifier, BundleIdentifier)]) {
        self.focusProviders = focusProviders
    }
    private let queue = CancellableQueue(label: "FocusArbitrator")
    private let focusProviders: [() throws -> (ProcessIdentifier, BundleIdentifier)]
    public func update() {
        queue.cancelAll()
        queue.async { workItem in
            for provider in self.focusProviders {
                do {
                    if workItem.isCancelled {
                       break
                    }
                    let value = try provider()
                    if !workItem.isCancelled {
                        self.focus⏦value
                    }
                    break
                } catch {
                    
                }
            }
        }
    }
}
