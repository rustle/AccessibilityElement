//
//  WindowLifeCycleObserver.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa
import Signals

public class WindowLifeCycleObserver<ElementType> : Runner where ElementType : _Element {
    public let applicationObserver: ApplicationObserver<ElementType>
    public let element: ElementType
    public var windowsDirty: Bool = false
    private var windowTokenMap = [ElementType:ApplicationObserver<ElementType>.Token]()
    private var onWindowCreated: Subscription<(element: ElementType, info: ObserverInfo?)>?
    public init(element: ElementType,
                applicationObserver: ApplicationObserver<ElementType>) {
        self.element = element
        self.applicationObserver = applicationObserver
    }
    private func destroyed(window: ElementType) {
        guard let token = windowTokenMap[window] else {
            return
        }
        do {
            try applicationObserver.stopObserving(token: token)
        } catch {}
        windowsDirty = true
    }
    private func created(window: ElementType) {
        windowsDirty = true
        do {
            windowTokenMap[window] = try applicationObserver.startObserving(element: window,
                                                                            notification: .uiElementDestroyed) { [weak self] window, _ in
                self?.destroyed(window: window)
            }
        } catch {
            
        }
    }
    public let runningSignal = Signal<Running>()
    public private(set) var running = Running.stopped {
        didSet {
            runningSignal⏦running
        }
    }
    public func start() throws {
        switch running {
        case .started:
            break
        case .stopped:
            onWindowCreated = try applicationObserver.signal(element: element,
                                                             notification: .windowCreated).subscribe { [weak self] in
                self?.created(window: $0.element)
            }
            running = .started
        }
    }
    public func stop() {
        switch running {
        case .stopped:
            break
        case .started:
            onWindowCreated?.cancel()
            onWindowCreated = nil
            running = .stopped
        }
    }
}
