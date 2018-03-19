//
//  FocusTheftObserver.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa
import Signals

/// Infer focus changes indirectly via accessibility notifications on applications that take focus, but don't become frontmost.
/// Known culprits are Spotlight and NotificationCenter
public class FocusTheftObserver<ObserverProvidingType> : Runner where ObserverProvidingType : ObserverProviding {
    public typealias ElementType = ObserverProvidingType.ElementType
    public static func systemApplicationLookup(_ bundleIdentifier: BundleIdentifier) throws -> ProcessIdentifier {
        let applications = NSWorkspace.shared.runningApplications;
        let index = applications.index() { application in
            guard let bundle = application.bundleIdentifier?.lowercased() else {
                return false
            }
            return bundle == bundleIdentifier
        }
        if let index = index {
            return ProcessIdentifier(applications[index].processIdentifier)
        }
        throw NSError()
    }
    public enum WindowState {
        case created
        case destroyed
    }
    public let windowStateSignal = Signal<WindowState>()
    public var windowState = WindowState.destroyed {
        didSet {
            windowStateSignal⏦windowState
        }
    }
    public let runningSignal = Signal<Running>()
    public private(set) var running = Running.stopped {
        didSet {
            runningSignal⏦running
        }
    }
    public let bundleIdentifier: BundleIdentifier
    public let observerManager: ObserverManager<ObserverProvidingType>
    public let applicationProvider: (BundleIdentifier) throws -> ProcessIdentifier
    public init(bundleIdentifier: BundleIdentifier,
                applicationProvider: @escaping (BundleIdentifier) throws -> ProcessIdentifier,
                observerManager: ObserverManager<ObserverProvidingType>) {
        self.bundleIdentifier = bundleIdentifier
        self.applicationProvider = applicationProvider
        self.observerManager = observerManager
    }
    private var observer: ApplicationObserver<ObserverProvidingType>?
    private var createdToken: ApplicationObserver<ObserverProvidingType>.Token?
    private var destroyedToken: ApplicationObserver<ObserverProvidingType>.Token?
    private func register(window: ElementType) {
        guard let observer = observer else {
            return
        }
        guard destroyedToken == nil else {
            return
        }
        do {
            destroyedToken = try observer.startObserving(element: window, notification: .uiElementDestroyed) { [weak self] element, info in
                self?.windowState = .destroyed
            }
        } catch {
            
        }
    }
    public func start() {
        switch running {
        case .stopped:
            guard let application = try? applicationProvider(bundleIdentifier) else {
                return
            }
            let element = ElementType.application(processIdentifier: application)
            do {
                observer = try observerManager.registerObserver(application: element)
            } catch {
                return
            }
            do {
                guard let observer = observer else {
                    return
                }
                createdToken = try observer.startObserving(element: element, notification: .windowCreated) { [weak self] element, info in
                    self?.windowState = .created
                    self?.register(window: element)
                }
            } catch {
                return
            }
            running = .started
        case .started:
            break
        }
    }
    public func stop() {
        switch running {
        case .stopped:
            break
        case .started:
            guard let observer = observer else {
                return
            }
            if let created = createdToken {
                do {
                    try observer.stopObserving(token: created)
                } catch {
                    return
                }
                createdToken = nil
            }
            if let destroyed = destroyedToken {
                do {
                    try observer.stopObserving(token: destroyed)
                } catch {
                    return
                }
                destroyedToken = nil
            }
            self.observer = nil
            running = .stopped
        }
    }
}
