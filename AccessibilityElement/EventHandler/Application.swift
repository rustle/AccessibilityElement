//
//  Application.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import Signals

public extension Array {
    mutating func appendOptional(_ newElement: Element?) {
        guard let newElement = newElement else {
            return
        }
        append(newElement)
    }
}

public struct Application<ObserverProvidingType> : EventHandler where ObserverProvidingType : ObserverProviding, ObserverProvidingType.ElementType : _Element {
    public typealias ElementType = ObserverProvidingType.ElementType
    public var describerRequests: [DescriberRequest] {
        return []
    }
    public var output: ((String) -> Void)?
    public mutating func configure(output: ((String) -> Void)?) {
        self.output = output
    }
    public weak var _controller: Controller<ElementType, Application<ObserverProvidingType>>?
    public let _node: Node<ElementType>
    public init(node: Node<ElementType>, applicationObserver: ApplicationObserver<ObserverProvidingType>) {
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
    private mutating func rebuildChildrenIfNeeded() {
        guard let controller = _controller else {
            return
        }
        if childrenDirty {
            controller.childControllers = try? controller.childControllers(node: _node)
            childrenDirty = false
        }
    }
    private mutating func destroyed(window: ElementType) {
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
    private mutating func created(window: ElementType) {
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
    private mutating func focusChanged(window: ElementType) {
        if let focusedElement = try? _node._element.applicationFocusedElement() {
            focusChanged(element: focusedElement)
        } else {
            focusChanged(element: window)
        }
    }
    // MARK: Focused UI Element
    private struct Focus<ObserverProvidingType> where ObserverProvidingType : ObserverProviding, ObserverProvidingType.ElementType : _Element {
        typealias ElementType = ObserverProvidingType.ElementType
        let applicationObserver: ApplicationObserver<ObserverProvidingType>
        init(applicationObserver: ApplicationObserver<ObserverProvidingType>) {
            self.applicationObserver = applicationObserver
        }
        var focusedContainer: _Controller<ElementType>?
        var focusedController: _Controller<ElementType>?
        mutating func set(focusedContainerNode: Node<ElementType>?,
                          focusedControllerNode: Node<ElementType>?,
                          applicationController: _Controller<ElementType>?) {
            var focusedContainer: _Controller<ElementType>?
            if let focusedContainerNode = focusedContainerNode {
                do {
                    let eventHandler = try EventHandlerRegistrar.shared.eventHandler(node: focusedContainerNode,
                                                                                     applicationObserver: applicationObserver)
                    focusedContainer = (try eventHandler.makeController()) as? _Controller<ElementType>
                    focusedContainer?.applicationController = applicationController
                } catch {
                    fatalError()
                }
            }
            var focusedController: _Controller<ElementType>?
            if let focusedControllerNode = focusedControllerNode {
                do {
                    let eventHandler = try EventHandlerRegistrar.shared.eventHandler(node: focusedControllerNode,
                                                                                     applicationObserver: applicationObserver)
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
    private var focus: Focus<ObserverProvidingType>
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
    public let applicationObserver: ApplicationObserver<ObserverProvidingType>
    public func observerContext() throws -> (Controller<ElementType, Application>, ElementType, ApplicationObserver<ObserverProvidingType>) {
        guard let controller = _controller else {
            throw Application.Error.nilController
        }
        let element = _node._element
        return (controller, element, applicationObserver)
    }
    private var onFocusedUIElementChanged: SignalSubscription<(element: ElementType, info: ObserverInfo?)>?
    private var onWindowCreated: SignalSubscription<(element: ElementType, info: ObserverInfo?)>?
    private var onFocusedWindowChanged: SignalSubscription<(element: ElementType, info: ObserverInfo?)>?
    private mutating func registerObservers() throws {
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
    private mutating func unregisterObservers() {
        onWindowCreated?.cancel()
        onWindowCreated = nil
        onFocusedUIElementChanged?.cancel()
        onFocusedUIElementChanged = nil
        onFocusedWindowChanged?.cancel()
        onFocusedWindowChanged = nil
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
        } catch let error {
            print(error)
        }
        childrenDirty = true
    }
    public mutating func focusIn() -> String? {
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
        } else if let focusedElement = try? _node._element.focusedWindow() {
            focusChanged(window: focusedElement)
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
    public mutating func handleEvent(identifier: String, type: EventType) throws {
        try self.focus.focusedController?.eventHandler.handleEvent(identifier: identifier, type: type)
    }
}
