//
//  Application.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa
import Signals

public final class Application<ObserverProvidingType> : EventHandler where ObserverProvidingType : ObserverProviding {
    // MARK: EventHandler
    public var output: (([Output.Job.Payload]) -> Void)?
    public weak var _controller: Controller<Application<ObserverProvidingType>>?
    public let _node: Node<ElementType>
    public required init(node: Node<ElementType>,
                         applicationObserver: ApplicationObserver<ObserverProvidingType>) {
        _node = node
        self.applicationObserver = applicationObserver
        focus = ApplicationFocus(applicationObserver: applicationObserver)
        windowLifeCycleObserver = WindowLifeCycleObserver(element:node._element,
                                                          applicationObserver: applicationObserver)
    }
    // MARK: Focused UI Element
    private var focus: ApplicationFocus<ObserverProvidingType>
    private let hierarchy = DefaultHierarchy<ElementType>()
    private let focusedUIElementChangedHandler = DefaultFocusedUIElementChangedHandler()
    public var isFocused: Bool = false
    // MARK: Observers
    public let applicationObserver: ApplicationObserver<ObserverProvidingType>
    private var onFocusedUIElementChanged: Subscription<(element: ElementType, info: ObserverInfo?)>?
    private var onFocusedWindowChanged: Subscription<(element: ElementType, info: ObserverInfo?)>?
    private let windowLifeCycleObserver: WindowLifeCycleObserver<ObserverProvidingType>
}

// MARK: EventHandler
public extension Application {
    public typealias ElementType = ObserverProvidingType.ElementType
    public var describerRequests: [DescriberRequest] {
        return []
    }
    public func configure(output: (([Output.Job.Payload]) -> Void)?) {
        self.output = output
    }
}

public extension Application {
    public enum Error : Swift.Error {
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
        try windowLifeCycleObserver.start()
        onFocusedUIElementChanged = try applicationObserver.signal(element: _node._element,
                                                                   notification: .focusedUIElementChanged).subscribe { [weak self] in
            self?.focusChanged(element: $0.element)
        }
        onFocusedWindowChanged = try applicationObserver.signal(element: _node._element,
                                                                notification: .focusedWindowChanged).subscribe { [weak self] in
            self?.focusChanged(window: $0.element)
        }
    }
    private func unregisterObservers() {
        windowLifeCycleObserver.stop()
        onFocusedUIElementChanged?.cancel()
        onFocusedUIElementChanged = nil
        onFocusedWindowChanged?.cancel()
        onFocusedWindowChanged = nil
    }
}

// MARK: EventHandler
public extension Application {
    public func connect() {
        do {
            try _node._element.set(enhancedUserInterface: true)
        } catch {
        }
        do {
            try registerObservers()
        } catch let error {
            print(error)
        }
        windowLifeCycleObserver.windowsDirty = true
    }
    public func focusIn() -> String? {
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
    public func focusOut() -> String? {
        isFocused = false
        return nil
    }
    public func disconnect() {
        unregisterObservers()
    }
    public func handleEvent(identifier: String, type: EventType) throws {
        try self.focus.state.focused?.eventHandler.handleEvent(identifier: identifier, type: type)
    }
}
