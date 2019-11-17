//
//  WindowLifeCycleObserver.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa
import Combine

public class WindowLifeCycleObserver<ElementType> : Runner, ObservableObject where ElementType : Element {
    public let applicationObserver: ApplicationObserver<ElementType>
    public let element: ElementType
    public var windowsDirty: Bool = false
    private var windowTokenMap = [ElementType:ApplicationObserver<ElementType>.Token]()
    private var onWindowCreated: AnyCancellable? {
        didSet {
            oldValue?.cancel()
        }
    }
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
    @Published public private(set) var running = Running.stopped
    public func start() throws {
        switch running {
        case .started:
            break
        case .stopped:
            onWindowCreated = try applicationObserver
                .publisher(element: element,
                           notification: .windowCreated)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { [weak self] in
                    self?.created(window: $0.element)
                })
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
