//
//  Application.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import os.log

// TODO: Convert this to a value type
public final class Application<ElementType> : EventHandler where ElementType : _Element {
    public var describerRequests: [DescriberRequest] {
        return []
    }
    public var output: ((String) -> Void)?
    public weak var _controller: Controller<ElementType, Application<ElementType>>?
    public let _node: Node<ElementType>
    public init(node: Node<ElementType>) {
        _node = node
    }
    private var observer: ApplicationObserver?
    private enum Error : Swift.Error {
        case invalidElement
        case containerSearchFailed
    }
    // MARK: Window State
    private var childrenDirty = false
    private func rebuildChildrenIfNeeded() {
        guard let controller = _controller else {
            return
        }
        if childrenDirty {
            controller.childControllers = try? controller.childControllers(node: _node)
            childrenDirty = false
        }
    }
    private var windowCreatedToken: ApplicationObserver.Token?
    private var windowTokenMap = [Element:ApplicationObserver.Token]()
    private func destroyed(window: Element) {
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
    private func created(window: Element) {
        childrenDirty = true
        guard let observer = self.observer else {
            return
        }
        do {
            windowTokenMap[window] = try observer.startObserving(element: window, notification: .uiElementDestroyed) { [weak self] window, _, _ in
                self?.destroyed(window: window)
            }
        } catch {}
    }
    // MARK: Focused UI Element
    private var focusedUIElementToken: ApplicationObserver.Token?
    private struct Focus<ElementType> where ElementType : _Element {
        var focusedContainer: _Controller<ElementType>?
        var focusedController: _Controller<ElementType>?
        mutating func set(focusedContainerNode: Node<ElementType>?,
                          focusedControllerNode: Node<ElementType>?) {
            os_log("focus")
            var focusedContainer: _Controller<ElementType>?
            if let focusedContainerNode = focusedContainerNode {
                do {
                    let eventHandler = try EventHandlerRegistrar.shared.eventHandler(node: focusedContainerNode)
                    focusedContainer = (try eventHandler.makeController()) as? _Controller<ElementType>
                } catch {
                    fatalError()
                }
            }
            var focusedController: _Controller<ElementType>?
            if let focusedControllerNode = focusedControllerNode {
                do {
                    let eventHandler = try EventHandlerRegistrar.shared.eventHandler(node: focusedControllerNode)
                    focusedController = (try eventHandler.makeController()) as? _Controller<ElementType>
                } catch {
                    fatalError()
                }
            }
            // TODO: re-use controllers already in place if possible
            // TODO: connect/disconection up the chain
            self.focusedContainer?.eventHandler.disconnect()
            self.focusedController?.eventHandler.disconnect()
            self.focusedContainer = focusedContainer
            self.focusedController = focusedController
            self.focusedContainer?.eventHandler.connect()
            self.focusedController?.eventHandler.connect()
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
    private func focusChanged(element: ElementType) {
        do {
            let container = try findContainer(element: element)
            var focusedNode: Node<ElementType>? = Node(element: element, role: .include)
            let node = hierarchy.buildHierarchy(from: container,
                                                targeting: &focusedNode)
            focus.set(focusedContainerNode: node,
                      focusedControllerNode: focusedNode)
            if let echo = focus.focusedController?.eventHandler.focusIn(), echo.count > 0 {
                output?(echo)
            }
        } catch {
            let node = Node(element: element, role: .include)
            focus.set(focusedContainerNode: nil,
                      focusedControllerNode: node)
            if let echo = focus.focusedController?.eventHandler.focusIn(), echo.count > 0 {
                output?(echo)
            }
        }
    }
    // MARK: Observers
    private func registerObservers() throws {
        guard let element = _node._element as? Element else {
            throw Application.Error.invalidElement
        }
        let observer = try ObserverManager.shared.registerObserver(application: element)
        self.observer = observer
        windowCreatedToken = try observer.startObserving(element: element, notification: .windowCreated) { [weak self] window, _, _ in
            self?.created(window: window)
        }
        focusedUIElementToken = try observer.startObserving(element: element, notification: .focusedUIElementChanged) { [weak self] element, _, _ in
            if let element = element as? ElementType {
                self?.focusChanged(element: element)
            }
        }
    }
    // MARK: -
    public var isFocused: Bool = false
    public func connect() {
        do {
            try registerObservers()
        } catch let error {
            os_log("%@.%@() observer error %@", String(describing: type(of: self)), #function, error.localizedDescription)
        }
        childrenDirty = true
    }
    public func focusIn() -> String? {
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
    public func focusOut() -> String? {
        isFocused = false
        return nil
    }
    public func disconnect() {
        
    }
}
