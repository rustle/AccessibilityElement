//
//  FocusObserver.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Cocoa
import Combine

public class FocusObserver<ElementType>: Runner, ObservableObject where ElementType : Element {
    public let spotlightObserver: FocusTheftObserver<ElementType>
    public init(observerManager: ObserverManager<ElementType>) {
        spotlightObserver = FocusTheftObserver(bundleIdentifier: .spotlight,
                                               applicationProvider: FocusTheftObserver<ElementType>.systemApplicationLookup,
                                               observerManager: observerManager)
    }
    @Published public private(set) var running = Running.stopped
    public var shouldEvaluateFocus: AnyPublisher<Void, Never> {
        _shouldEvaluateFocus
            .eraseToAnyPublisher()
    }
    private let _shouldEvaluateFocus = PassthroughSubject<Void, Never>()
    private var frontmost: AnyCancellable? {
        didSet {
            oldValue?.cancel()
        }
    }
    private var menuBar: AnyCancellable? {
        didSet {
            oldValue?.cancel()
        }
    }
    public func start() {
        switch running {
        case .stopped:
            let workspace = NSWorkspace.shared
            let update: () -> Void = { [weak self] in
                self?._shouldEvaluateFocus.send(())
            }
            func observe(keyPath: KeyPath<NSWorkspace, NSRunningApplication?>) -> AnyCancellable? {
                workspace
                    .publisher(for: keyPath)
                    .receive(on: DispatchQueue.main)
                    .sink { _ in
                        update()
                    }
            }
            frontmost = observe(keyPath: \NSWorkspace.frontmostApplication)
            menuBar = observe(keyPath: \NSWorkspace.menuBarOwningApplication)
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
            frontmost?.cancel()
            frontmost = nil
            menuBar?.cancel()
            menuBar = nil
            spotlightObserver.stop()
            running = .stopped
        }
    }
}
