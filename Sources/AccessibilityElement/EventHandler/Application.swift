//
//  Application.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Cocoa
import Combine
import os.log

private let log = OSLog(subsystem: "A11Y", category: "Application")

public final class Application<ElementType: Element>: EventHandler {
    // MARK: EventHandler
    public var output: (([Output.Job.Payload]) -> Void)?
    public weak var _controller: Controller<Application<ElementType>>?
    public let _node: Node<ElementType>
    public required init(node: Node<ElementType>,
                         applicationObserver: ApplicationObserver<ElementType>) {
        _node = node
        self.applicationObserver = applicationObserver
        focus = ApplicationFocus(applicationObserver: applicationObserver)
        windowLifeCycleObserver = WindowLifeCycleObserver(element:node._element,
                                                          applicationObserver: applicationObserver)
    }
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    // MARK: Focused UI Element
    private var focus: ApplicationFocus<ElementType>
    private let hierarchy = DefaultHierarchy<ElementType>()
    private let focusedUIElementChangedHandler = DefaultFocusedUIElementChangedHandler()
    public var isFocused: Bool = false
    // MARK: Observers
    public let applicationObserver: ApplicationObserver<ElementType>
    private var cancellables = Set<AnyCancellable>()
    private let windowLifeCycleObserver: WindowLifeCycleObserver<ElementType>
}

// MARK: EventHandler
public extension Application {
    var describerRequests: [DescriberRequest] {
        return []
    }
    func configure(output: (([Output.Job.Payload]) -> Void)?) {
        self.output = output
    }
}

public extension Application {
    enum Error: Swift.Error {
        case invalidElement
        case containerSearchFailed
        case nilController
    }
}

// MARK: Window State
public extension Application {
    private func rebuildChildrenIfNeeded() {
        guard let controller = _controller else {
            return
        }
        if windowLifeCycleObserver.windowsDirty {
            do {
                controller._childControllers = try controller.childControllers(node: _node)
            } catch {
                controller._childControllers = []
            }
            windowLifeCycleObserver.windowsDirty = false
        }
    }
    private func focusChanged(element: ElementType) {
        guard let controller = _controller else {
            return
        }
        let value = focusedUIElementChangedHandler.focusChanged(element: element,
                                                                hierarchy: hierarchy,
                                                                focus: focus,
                                                                applicationController: controller)
        if let echo = value, echo.count > 0 {
            output?([.speech(echo, nil)])
        }
    }
    private func focusChanged(window: ElementType) {
        if let focusedElement = try? _node._element.applicationFocusedElement() {
            focusChanged(element: focusedElement)
        } else {
            do {
                let focused = try window.walk { subElement -> ElementType? in
                    if try subElement.isKeyboardFocused() {
                        return subElement
                    }
                    return nil
                }
                if let focused = focused {
                    focusChanged(element: focused)
                }
            } catch {
                focusChanged(element: window)
            }
        }
    }
}

// MARK: Observers
public extension Application {
    private func registerObservers() throws {
        os_log(.debug, log: log, "%{public}@", #function)

        try windowLifeCycleObserver.start()
        func observe(_ notification: NSAccessibility.Notification,
                     handler: @escaping ((element: ElementType, info: ElementNotificationInfo?)) -> Void) throws -> AnyCancellable {
            try applicationObserver
                .publisher(element: _node._element,
                           notification: notification)
                .sink(receiveCompletion: { _ in },
                      receiveValue: handler)
        }
        try observe(.focusedUIElementChanged) { [weak self] in
            self?.focusChanged(element: $0.element)
        }.store(in: &cancellables)
        try observe(.focusedWindowChanged) { [weak self] in
            self?.focusChanged(window: $0.element)
        }.store(in: &cancellables)
    }
    private func unregisterObservers() {
        os_log(.debug, log: log, "%{public}@", #function)

        windowLifeCycleObserver.stop()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}

// MARK: EventHandler
public extension Application {
    func connect() {
        os_log(.debug, log: log, "%{public}@", #function)

        do {
            try _node._element.set(enhancedUserInterface: true)
        } catch {
        }
        do {
            try registerObservers()
        } catch {
            os_log(.debug, log: log, "registerObservers() error %{public}@", "\(error)")
        }
        windowLifeCycleObserver.windowsDirty = true
    }
    func focusIn() -> String? {
        os_log(.debug, log: log, "%{public}@", #function)

        if isFocused {
            return nil
        }
        isFocused = true
        rebuildChildrenIfNeeded()
        let title: String
        do {
            title = try node.element.title()
        } catch {
            // TODO: Localize
            title = "unknown application"
        }
        if let focusedElement = try? _node._element.applicationFocusedElement() {
            focusChanged(element: focusedElement)
        } else {
            do {
                let focusedElement = try _node._element.walk { subElement -> ElementType? in
                    if try subElement.isKeyboardFocused() {
                        return subElement
                    }
                    return nil
                }
                if let focusedElement = focusedElement {
                    focusChanged(element: focusedElement)
                    return title
                }
            } catch { }
            if let focusedElement = try? _node._element.focusedWindow() {
                focusChanged(window: focusedElement)
            }
        }
        return title
    }
    func focusOut() -> String? {
        os_log(.debug, log: log, "%{public}@", #function)

        isFocused = false
        return nil
    }
    func disconnect() {
        os_log(.debug, log: log, "%{public}@", #function)

        unregisterObservers()
    }
    func handleEvent(identifier: String, type: EventType) throws {
        os_log(.debug, log: log, "%{public}@", #function)

        try self.focus.state.focused?.eventHandler.handleEvent(identifier: identifier, type: type)
    }
}
