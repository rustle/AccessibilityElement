//
//  FocusArbitration.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Cocoa
import Combine
import os.log

/// Evaluate cascading list of focus providers to find the currently focused application
public final class FocusArbitrator: ObservableObject {
    static let log = OSLog(subsystem: "A11Y", category: "FocusArbitrator")

    /// Common errors a focus provider may encounter
    public enum Error: Swift.Error {
        case timedOut
        case nilFocus
        case nilBundleIdentifier
    }
    public static func systemFocusedApplicationElement() throws -> Focus {
        func systemFocus() throws -> SystemElement {
            let value = try AXUIElement.systemWide().value(attribute: NSAccessibility.Attribute.focusedApplication) as CFTypeRef
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
            return Focus(processIdentifier: focusedElement.processIdentifier,
                         bundleIdentifier: bundleIdentifier)
        }
        throw FocusArbitrator.Error.nilBundleIdentifier
    }
    public static func frontmostApplication() throws -> Focus {
        if let frontmost = NSWorkspace.shared.frontmostApplication {
            if let bundleIdentifier = BundleIdentifier(rawValue: frontmost.bundleIdentifier) {
                return Focus(processIdentifier: ProcessIdentifier(frontmost.processIdentifier),
                             bundleIdentifier: bundleIdentifier)
            }
            throw FocusArbitrator.Error.nilBundleIdentifier
        }
        throw FocusArbitrator.Error.nilFocus
    }
    public static func menuBarOwningApplication() throws -> Focus {
        guard let menuBar = NSWorkspace.shared.menuBarOwningApplication else {
            throw FocusArbitrator.Error.nilFocus
        }
        guard let bundleIdentifier = BundleIdentifier(rawValue: menuBar.bundleIdentifier) else {
            throw FocusArbitrator.Error.nilBundleIdentifier
        }
        return Focus(processIdentifier: ProcessIdentifier(menuBar.processIdentifier),
                     bundleIdentifier: bundleIdentifier)
    }
    public struct Focus {
        public let processIdentifier: ProcessIdentifier
        public let bundleIdentifier: BundleIdentifier
    }
    @Published public private(set) var focus = Focus(processIdentifier: -1,
                                                     bundleIdentifier: "")
    public init(focusProviders: [() throws -> Focus]) {
        self.focusProviders = focusProviders
    }
    private let queue = CancellableQueue(label: "FocusArbitrator")
    private let focusProviders: [() throws -> Focus]
    public func update() {
        queue.cancelAll()
        queue.async { workItem in
            os_log(.info, log: FocusArbitrator.log, "Updating focus")
            for provider in self.focusProviders {
                do {
                    if workItem.isCancelled {
                       break
                    }
                    let value = try provider()
                    if !workItem.isCancelled {
                        os_log(.info, log: FocusArbitrator.log, "Found focus %{public}@", "\(value)")
                        self.focus = value
                    }
                    break
                } catch {
                    os_log(.info, log: FocusArbitrator.log, "Error while searching for focus %{public}@", "\(error)")
                }
            }
        }
    }
}
