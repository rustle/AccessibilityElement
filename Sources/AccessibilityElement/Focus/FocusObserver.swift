//
//  FocusObserver.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa
import Signals

public class FocusObserver<ElementType> : Runner where ElementType : _Element {
    public let spotlightObserver: FocusTheftObserver<ElementType>
    public init(observerManager: ObserverManager<ElementType>) {
        spotlightObserver = FocusTheftObserver(bundleIdentifier: .spotlight,
                                               applicationProvider: FocusTheftObserver<ElementType>.systemApplicationLookup,
                                               observerManager: observerManager)
    }
    public let runningSignal = Signal<Running>()
    public private(set) var running = Running.stopped {
        didSet {
            runningSignal⏦running
        }
    }
    public var shouldEvaluateFocusSignal: Signal<Void> = Signal()
    private var frontmostObservable: KeyValueObservable?
    private var menuBarObservable: KeyValueObservable?
    public func start() {
        switch running {
        case .stopped:
            let workspace = NSWorkspace.shared
            let update: () -> Void = { [weak self] in
                self?.shouldEvaluateFocusSignal.fire(())
            }
            func observe(object: NSObject,
                         keyPath: String) -> KeyValueObservable {
                let observer = KeyValueObserverSignal<NSRunningApplication>()
                let observable = KeyValueObservable(object: object,
                                                    keyPath: keyPath)
                observable.add(observer: observer)
                observer.subscribe { _ in
                    update()
                }.queue(DispatchQueue.main)
                return observable
            }
            frontmostObservable = observe(object: workspace,
                                          keyPath: #keyPath(NSWorkspace.frontmostApplication))
            menuBarObservable = observe(object: workspace,
                                        keyPath: #keyPath(NSWorkspace.menuBarOwningApplication))
            spotlightObserver.start()
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
            frontmostObservable?.stopObserving()
            frontmostObservable = nil
            menuBarObservable?.stopObserving()
            menuBarObservable = nil
            spotlightObserver.stop()
            running = .stopped
        }
    }
}
