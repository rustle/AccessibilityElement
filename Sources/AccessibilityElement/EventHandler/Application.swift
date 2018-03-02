//
//  Application.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import Signals

open class Application<ObserverProvidingType> : EventHandler where ObserverProvidingType : ObserverProviding {
    public typealias ElementType = ObserverProvidingType.ElementType
    public var describerRequests: [DescriberRequest] {
        return []
    }
    public var output: (([Output.Job.Payload]) -> Void)?
    public func configure(output: (([Output.Job.Payload]) -> Void)?) {
        self.output = output
    }
    public weak var _controller: Controller<Application<ObserverProvidingType>>?
    public let _node: Node<ElementType>
    public required init(node: Node<ElementType>, applicationObserver: ApplicationObserver<ObserverProvidingType>) {
        _node = node
        self.applicationObserver = applicationObserver
        focus = Focus(applicationObserver: applicationObserver)
    }
    private enum Error : Swift.Error {
        case invalidElement
        case containerSearchFailed
        case nilController
    }
    // MARK: Window State
    private var windowTokenMap = [ObserverProvidingType.ElementType:ApplicationObserver<ObserverProvidingType>.Token]()
    private var childrenDirty = false
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
    // MARK: Focused UI Element
    private struct Focus {
        enum Error : Swift.Error {
            case focusFailed(Swift.Error)
            case typeMismatch
            case focusedElementNotInHierarchy
        }
        typealias ElementType = ObserverProvidingType.ElementType
        let applicationObserver: ApplicationObserver<ObserverProvidingType>
        init(applicationObserver: ApplicationObserver<ObserverProvidingType>) {
            self.applicationObserver = applicationObserver
        }
        var focusedContainerController: _Controller<ElementType>?
        var focusedController: _Controller<ElementType>?
        enum Clear {
            case full
            case container
        }
        private mutating func reset(_ type: Clear) {
            //print("reset \(type)")
        }
        private mutating func build(from focusedContainerController: _Controller<ElementType>,
                                    to focusedControllerNode: Node<ElementType>,
                                    applicationController: _Controller<ElementType>?) throws {
            if let currentFocusedController = focusedController, currentFocusedController.node == focusedControllerNode {
                return
            }
            do {
                if let previouslyFocusedController = self.focusedController {
                    _ = previouslyFocusedController.eventHandler.focusOut()
                }
                let ancestor = focusedContainerController.node
                var nodes = [Node<ElementType>]()
                var current: Node<ElementType>? = focusedControllerNode
                while current != nil, current! != ancestor {
                    do {
                        nodes.append(current!)
                        current = try current!.up()
                    } catch {
                        current = nil
                    }
                }
                nodes.reverse()
                var controller = focusedContainerController
                for node in nodes {
                    // need to add dirty flag for children to _Controller
                    if controller.childControllers.count == 0 {
                        controller.childControllers = try controller.childControllers(node: node)
                    }
                    guard let index = controller._childControllers.index(where: { controller in
                        return controller.node == node
                    }) else {
                        throw Focus.Error.focusedElementNotInHierarchy
                    }
                    controller = controller._childControllers[index]
                }
                self.focusedController = controller
                _ = controller.eventHandler.focusIn()
            } catch let error {
                throw Focus.Error.focusFailed(error)
            }
        }
        private mutating func fullRebuild(focusedContainerNode: Node<ElementType>,
                                          focusedControllerNode: Node<ElementType>?,
                                          applicationController: _Controller<ElementType>?) throws {
            var focusedContainerController: _Controller<ElementType>
            do {
                let shared = try EventHandlerRegistrar<ObserverProvidingType>.shared()
                let eventHandler = try shared.eventHandler(node: focusedContainerNode,
                                                           applicationObserver: applicationObserver)
                focusedContainerController = (try eventHandler.makeController()) as! _Controller<ElementType>
                focusedContainerController.applicationController = applicationController
                focusedContainerController.eventHandler.connect()
            } catch let error {
                throw Focus.Error.focusFailed(error)
            }
            try sameContainerRebuild(focusedContainerController: focusedContainerController,
                                     focusedControllerNode: focusedControllerNode,
                                     applicationController: applicationController)
        }
        private mutating func sameContainerRebuild(focusedContainerController: _Controller<ElementType>,
                                                   focusedControllerNode: Node<ElementType>?,
                                                   applicationController: _Controller<ElementType>?) throws {
            if let updatedFocusedControllerNode = focusedControllerNode {
                try build(from: focusedContainerController,
                          to: updatedFocusedControllerNode,
                          applicationController: applicationController)
            } else {
                self.focusedContainerController = focusedContainerController
                reset(.container)
            }
        }
        mutating func set(focusedContainerNode: Node<ElementType>?,
                          focusedControllerNode: Node<ElementType>?,
                          applicationController: _Controller<ElementType>?) throws {
            guard let updatedFocusedContainerNode = focusedContainerNode else {
                reset(.full)
                return
            }
            if let currentFocusedContainerController = self.focusedContainerController,
                currentFocusedContainerController.node == updatedFocusedContainerNode {
                do {
                    try sameContainerRebuild(focusedContainerController: currentFocusedContainerController,
                                             focusedControllerNode: focusedControllerNode,
                                             applicationController: applicationController)
                } catch { }
            }
            try fullRebuild(focusedContainerNode: updatedFocusedContainerNode,
                            focusedControllerNode: focusedControllerNode,
                            applicationController: applicationController)
        }
    }
    private var focus: Focus
    private let hierarchy = DefaultHierarchy<ElementType>()
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
        do {
            let container = try findContainer(element: element)
            var focusedNode: Node<ElementType>? = Node(element: element, role: .include)
            let node = hierarchy.buildHierarchy(from: container,
                                                targeting: &focusedNode)
            try focus.set(focusedContainerNode: node,
                          focusedControllerNode: focusedNode,
                          applicationController: _controller)
            if let echo = focus.focusedController?.eventHandler.focusIn(), echo.count > 0 {
                output?([.speech(echo, nil)])
            }
        } catch {
            do {
                let node = Node(element: element, role: .include)
                try focus.set(focusedContainerNode: nil,
                              focusedControllerNode: node,
                              applicationController: _controller)
                if let echo = focus.focusedController?.eventHandler.focusIn(), echo.count > 0 {
                    output?([.speech(echo, nil)])
                }
            } catch { }
        }
    }
    // MARK: Observers
    public let applicationObserver: ApplicationObserver<ObserverProvidingType>
    public func observerContext() throws -> (Controller<Application>, ElementType, ApplicationObserver<ObserverProvidingType>) {
        guard let controller = _controller else {
            throw Application.Error.nilController
        }
        let element = _node._element
        return (controller, element, applicationObserver)
    }
    private var onFocusedUIElementChanged: SignalSubscription<(element: ElementType, info: ObserverInfo?)>?
    private var onWindowCreated: SignalSubscription<(element: ElementType, info: ObserverInfo?)>?
    private var onFocusedWindowChanged: SignalSubscription<(element: ElementType, info: ObserverInfo?)>?
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
    // MARK: -
    public var isFocused: Bool = false
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
        try self.focus.focusedController?.eventHandler.handleEvent(identifier: identifier, type: type)
    }
}
