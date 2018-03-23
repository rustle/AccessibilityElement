//
//  Application.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import Signals

public final class Application<ObserverProvidingType> : EventHandler where ObserverProvidingType : ObserverProviding {
    // MARK: EventHandler
    public var output: (([Output.Job.Payload]) -> Void)?
    public weak var _controller: Controller<Application<ObserverProvidingType>>?
    public let _node: Node<ElementType>
    public required init(node: Node<ElementType>, applicationObserver: ApplicationObserver<ObserverProvidingType>) {
        _node = node
        self.applicationObserver = applicationObserver
        focus = ApplicationFocus(applicationObserver: applicationObserver)
    }
    // MARK: Window State
    private var windowTokenMap = [ObserverProvidingType.ElementType:ApplicationObserver<ObserverProvidingType>.Token]()
    private var childrenDirty = false
    // MARK: Focused UI Element
    private var focus: ApplicationFocus<ObserverProvidingType>
    private let hierarchy = DefaultHierarchy<ElementType>()
    public var isFocused: Bool = false
    // MARK: Observers
    public let applicationObserver: ApplicationObserver<ObserverProvidingType>
    private var onFocusedUIElementChanged: Subscription<(element: ElementType, info: ObserverInfo?)>?
    private var onWindowCreated: Subscription<(element: ElementType, info: ObserverInfo?)>?
    private var onFocusedWindowChanged: Subscription<(element: ElementType, info: ObserverInfo?)>?
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
        if childrenDirty {
            do {
                controller.childControllers = try controller.childControllers(node: _node)
            } catch {
                controller.childControllers = []
            }
            childrenDirty = false
        }
    }
    private func destroyed(window: ElementType) {
        guard let (_, _, observer) = try? observerContext() else {
            return
        }
        guard let token = windowTokenMap[window] else {
            return
        }
        do {
            try observer.stopObserving(token: token)
        } catch {
            
        }
        childrenDirty = true
    }
    private func created(window: ElementType) {
        childrenDirty = true
        guard let (controller, _, observer) = try? observerContext() else {
            return
        }
        do {
            windowTokenMap[window] = try observer.startObserving(element: window, notification: .uiElementDestroyed) { window, _ in
                controller._eventHandler.destroyed(window: window)
            }
        } catch {}
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
                    return
                }
            } catch { }
            focusChanged(element: window)
        }
    }
}

// MARK: Focused UI Element
public extension Application {
    private func findContainer(element: ElementType) throws -> ElementType {
        var current: ElementType? = element
        while current != nil {
            if hierarchy.classify(current!) == .container {
                return current!
            }
            do {
                current = try current!.parent()
            } catch let error {
                print(error)
                throw error
            }
        }
        throw Application.Error.containerSearchFailed
    }
    private func focusChanged(element: ElementType) {
        guard let controller = _controller else {
            return
        }
        do {
            let container = try findContainer(element: element)
            var focusedNode: Node<ElementType>? = Node(element: element, role: .include)
            let node = hierarchy.buildHierarchy(from: container,
                                                targeting: &focusedNode)
            try focus.set(focusedContainerNode: node,
                          focusedControllerNode: focusedNode,
                          applicationController: controller)
            if let echo = focus.state.focused?.eventHandler.focusIn(), echo.count > 0 {
                output?([.speech(echo, nil)])
            }
        } catch {
            do {
                let node = Node(element: element, role: .include)
                try focus.set(focusedContainerNode: nil,
                              focusedControllerNode: node,
                              applicationController: controller)
                if let echo = focus.state.focused?.eventHandler.focusIn(), echo.count > 0 {
                    output?([.speech(echo, nil)])
                }
            } catch { }
        }
    }
}

// MARK: Observers
public extension Application {
    public func observerContext() throws -> (Controller<Application>, ElementType, ApplicationObserver<ObserverProvidingType>) {
        guard let controller = _controller else {
            throw Application.Error.nilController
        }
        let element = _node._element
        return (controller, element, applicationObserver)
    }
    private func registerObservers() throws {
        let (controller, element, observer) = try observerContext()
        onWindowCreated = try observer.signal(element: element,
                                              notification: .windowCreated).subscribe { [weak controller] in
            controller?._eventHandler.created(window: $0.element)
        }
        onFocusedUIElementChanged = try observer.signal(element: element,
                                                        notification: .focusedUIElementChanged).subscribe { [weak controller] in
            controller?._eventHandler.focusChanged(element: $0.element)
        }
        onFocusedWindowChanged = try observer.signal(element: element,
                                                     notification: .focusedWindowChanged).subscribe { [weak controller] in
            controller?._eventHandler.focusChanged(window: $0.element)
        }
    }
    private func unregisterObservers() {
        onWindowCreated?.cancel()
        onWindowCreated = nil
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
        childrenDirty = true
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
