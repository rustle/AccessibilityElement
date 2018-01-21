//
//  Application.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import os.log

public extension Array {
    mutating func appendOptional(_ newElement: Element?) {
        guard let newElement = newElement else {
            return
        }
        append(newElement)
    }
}

public struct Application<ElementType> : EventHandler where ElementType : _Element {
    public var describerRequests: [DescriberRequest] {
        return []
    }
    public var output: ((String) -> Void)?
    public weak var _controller: Controller<ElementType, Application<ElementType>>?
    public let _node: Node<ElementType>
    public init(node: Node<ElementType>) {
        _node = node
    }
    private enum Error : Swift.Error {
        case invalidElement
        case containerSearchFailed
        case nilController
    }
    // MARK: Window State
    private var windowTokenMap = [Element:ApplicationObserver.Token]()
    private var childrenDirty = false
    private mutating func rebuildChildrenIfNeeded() {
        guard let controller = _controller else {
            return
        }
        if childrenDirty {
            controller.childControllers = try? controller.childControllers(node: _node)
            childrenDirty = false
        }
    }
    private mutating func destroyed(window: Element) {
        guard let observer = observer else {
            return
        }
        guard let token = windowTokenMap[window] else {
            return
        }
        do {
            try observer.stopObserving(token: token)
        } catch {}
        childrenDirty = true
    }
    private mutating func created(window: Element) {
        childrenDirty = true
        guard let observer = self.observer else {
            return
        }
        guard let controller = _controller else {
            return
        }
        do {
            windowTokenMap[window] = try observer.startObserving(element: window, notification: .uiElementDestroyed) { window, _ in
                controller._eventHandler.destroyed(window: window)
            }
        } catch {}
    }
    private mutating func focusChanged(window: Element) {
        guard let focusedElement = try? _node._element.applicationFocusedElement() else {
            return
        }
        focusChanged(element: focusedElement)
    }
    // MARK: Focused UI Element
    private struct Focus<ElementType> where ElementType : _Element {
        var focusedContainer: _Controller<ElementType>?
        var focusedController: _Controller<ElementType>?
        mutating func set(focusedContainerNode: Node<ElementType>?,
                          focusedControllerNode: Node<ElementType>?,
                          applicationController: _Controller<ElementType>?) {
            var focusedContainer: _Controller<ElementType>?
            if let focusedContainerNode = focusedContainerNode {
                do {
                    let eventHandler = try EventHandlerRegistrar.shared.eventHandler(node: focusedContainerNode)
                    focusedContainer = (try eventHandler.makeController()) as? _Controller<ElementType>
                    focusedContainer?.applicationController = applicationController
                } catch {
                    fatalError()
                }
            }
            var focusedController: _Controller<ElementType>?
            if let focusedControllerNode = focusedControllerNode {
                do {
                    let eventHandler = try EventHandlerRegistrar.shared.eventHandler(node: focusedControllerNode)
                    focusedController = (try eventHandler.makeController()) as? _Controller<ElementType>
                    focusedController?.applicationController = applicationController
                } catch {
                    fatalError()
                }
            }
            // TODO: re-use controllers already in place if possible
            // TODO: connect/disconection up the chain
            var disconnect = [_Controller<ElementType>]()
            disconnect.appendOptional(self.focusedContainer)
            disconnect.appendOptional(self.focusedController)
            self.focusedContainer = focusedContainer
            self.focusedController = focusedController
            var connect = [_Controller<ElementType>]()
            connect.appendOptional(self.focusedContainer)
            connect.appendOptional(self.focusedController)
            // Unfortunate workaround for:
            // Simultaneous accesses to 0x102034798, but modification requires exclusive access.
            // Previous access (a modification) started at AccessibilityElement`closure #3 in Application.registerObservers() + 306 (0x1000d7742).
            // Current access (a read) started at:
            // 0    libswiftCore.dylib                 0x000000010058b070 swift_beginAccess + 605
            // 1    AccessibilityElement               0x00000001000f3060 Controller._eventHandler.getter + 101
            // 2    AccessibilityElement               0x00000001000f32b0 Controller.eventHandler.getter + 89
            // 3    AccessibilityElement               0x000000010010c730 WebArea.registerObservers() + 992
            // 4    AccessibilityElement               0x000000010010bf40 WebArea.connect() + 1638
            // 5    AccessibilityElement               0x00000001001161d0 protocol witness for AnyEventHandler.connect() in conformance <A> WebArea<A> + 9
            // 6    AccessibilityElement               0x00000001000d4b80 Application.Focus.set(focusedContainerNode:focusedControllerNode:applicationController:) + 2823
            // 7    AccessibilityElement               0x00000001000d3280 Application.focusChanged(element:) + 3417
            // 8    AccessibilityElement               0x00000001000d7610 closure #3 in Application.registerObservers() + 356
            DispatchQueue.main.async {
                for controller in disconnect {
                    controller.eventHandler.disconnect()
                }
                for controller in connect {
                    controller.eventHandler.connect()
                }
            }
        }
    }
    private var focus = Focus<ElementType>()
    private let hierarchy = DefaultHierarchy<ElementType>()
    private func findContainer(element: ElementType) throws -> ElementType {
        var current: ElementType? = element
        while current != nil {
            if hierarchy.classify(current!) == .container {
                return current!
            }
            current = try? current!.parent()
        }
        throw Application.Error.containerSearchFailed
    }
    private mutating func focusChanged(element: ElementType) {
        do {
            let container = try findContainer(element: element)
            var focusedNode: Node<ElementType>? = Node(element: element, role: .include)
            let node = hierarchy.buildHierarchy(from: container,
                                                targeting: &focusedNode)
            focus.set(focusedContainerNode: node,
                      focusedControllerNode: focusedNode,
                      applicationController: _controller)
            if let echo = focus.focusedController?.eventHandler.focusIn(), echo.count > 0 {
                output?(echo)
            }
        } catch {
            let node = Node(element: element, role: .include)
            focus.set(focusedContainerNode: nil,
                      focusedControllerNode: node,
                      applicationController: _controller)
            if let echo = focus.focusedController?.eventHandler.focusIn(), echo.count > 0 {
                output?(echo)
            }
        }
    }
    // MARK: Observers
    public var observer: ApplicationObserver?
    private var windowCreatedToken: ApplicationObserver.Token?
    private var focusedWindowChangedToken: ApplicationObserver.Token?
    private var focusedUIElementToken: ApplicationObserver.Token?
    private mutating func registerObservers() throws {
        guard ElementType.self == Element.self else {
            throw Application.Error.invalidElement
        }
        guard let controller = _controller else {
            throw Application.Error.nilController
        }
        let element = _node._element as! Element
        let observer = try ObserverManager.shared.registerObserver(application: element)
        self.observer = observer
        func register(notification: NSAccessibilityNotificationName, handler: @escaping ObserverHandler) throws -> ApplicationObserver.Token {
            return try observer.startObserving(element: element, notification: .windowCreated, handler: handler)
        }
        windowCreatedToken = try register(notification: .windowCreated) { [weak controller] window, info in
            controller?._eventHandler.created(window: window)
        }
        focusedWindowChangedToken = try register(notification: .focusedWindowChanged) { [weak controller] window, _ in
            controller?._eventHandler.focusChanged(window: window)
        }
        focusedUIElementToken = try register(notification: .focusedUIElementChanged) { [weak controller] element, _ in
            controller?._eventHandler.focusChanged(element: element as! ElementType)
        }
        
        focusedWindowChangedToken = try observer.startObserving(element: element, notification: .focusedUIElementChanged) { [weak controller] focusedElement, _ in
            controller?._eventHandler.focusChanged(element: focusedElement as! ElementType)
        }
    }
    private mutating func unregisterObservers() {
        func cleanup(keyPath: WritableKeyPath<Application, ApplicationObserver.Token?>) {
            if let token = self[keyPath: keyPath] {
                try? observer?.stopObserving(token: token)
                self[keyPath: keyPath] = nil
            }
        }
        cleanup(keyPath: \Application.windowCreatedToken)
        cleanup(keyPath: \Application.focusedWindowChangedToken)
        cleanup(keyPath: \Application.focusedWindowChangedToken)
        observer = nil
    }
    // MARK: -
    public var isFocused: Bool = false
    public mutating func connect() {
        do {
            try _node._element.set(enhancedUserInterface: true)
        } catch {
        }
        do {
            try registerObservers()
        } catch {
        }
        childrenDirty = true
    }
    public mutating func focusIn() -> String? {
        if isFocused {
            return nil
        }
        isFocused = true
        rebuildChildrenIfNeeded()
        guard let title = try? node.element.title() else {
            return "unknown application"
        }
        return title
    }
    public mutating func focusOut() -> String? {
        isFocused = false
        return nil
    }
    public mutating func disconnect() {
        unregisterObservers()
    }
}
