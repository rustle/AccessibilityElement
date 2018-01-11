//
//  Application.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import os.log

public class Application<ElementType> : Specialization where ElementType : _AccessibilityElement {
    public var describerRequests: [DescriberRequest] {
        return []
    }
    public weak var controller: Controller<ElementType>?
    public init(controller: Controller<ElementType>) {
        self.controller = controller
    }
    private var observer: ApplicationObserver?
    private enum Error : Swift.Error {
        case invalidElement
        case containerSearchFailed
    }
    // MARK: Window State
    private var childrenDirty = false
    private func rebuildChildrenIfNeeded() {
        guard let controller = controller else {
            return
        }
        if childrenDirty {
            controller.childControllers = controller.childControllers(node: controller.node)
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
    private var focusedContainer: Controller<Element>?
    private var focusedController: Controller<Element>?
    private let hierarchy = DefaultHierarchy<Element>()
    private func findContainer(element: Element) throws -> Element {
        var current: Element? = element
        while current != nil {
            if hierarchy.classify(current!) == .container {
                return current!
            }
            current = try? current!.parent()
        }
        throw Application.Error.containerSearchFailed
    }
    private func focusChanged(element: Element) {
        do {
            let container = try findContainer(element: element)
            var focusedNode: Node<Element>? = Node(element: element, role: .include)
            let node = hierarchy.buildHierarchy(from: container, targeting: &focusedNode)
            focusedContainer = Controller(node: node)
            focusedController = Controller(node: focusedNode ?? node)
            if let echo = focusedController?.focusIn(), echo.count > 0 {
                controller?.output?(echo)
            }
        } catch {
            focusedContainer = nil
            let node = Node(element: element, role: .include)
            focusedController = Controller(node: node)
            if let echo = focusedController?.focusIn(), echo.count > 0 {
                controller?.output?(echo)
            }
        }
    }
    // MARK: Observers
    private func registerObservers() throws {
        guard let element = self.controller?.node.element as? Element else {
            throw Application.Error.invalidElement
        }
        let observer = try ObserverManager.shared.registerObserver(application: element)
        self.observer = observer
        windowCreatedToken = try observer.startObserving(element: element, notification: .windowCreated) { [weak self] window, _, _ in
            self?.created(window: window)
        }
        focusedUIElementToken = try observer.startObserving(element: element, notification: .focusedUIElementChanged) { [weak self] element, _, _ in
            self?.focusChanged(element: element)
        }
    }
    // MARK: -
    public var isFocused: Bool = false
    public func connect() -> String? {
        do {
            try registerObservers()
        } catch let error {
            os_log("%@.%@() observer error %@", String(describing: type(of: self)), #function, error.localizedDescription)
        }
        childrenDirty = true
        return nil
    }
    public func focusIn() -> String? {
        if isFocused {
            return nil
        }
        isFocused = true
        rebuildChildrenIfNeeded()
        guard let title = try? controller?.node.element.title() else {
            return "unknown application"
        }
        return title
    }
    public func focusOut() -> String? {
        isFocused = false
        return nil
    }
}
