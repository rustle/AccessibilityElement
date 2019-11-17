//
//  ApplicationFocus.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Cocoa

public enum FocusRebuildStrategyError: Error {
    case unableToCompleteMove
    case invalidTarget
}

public typealias ControllerProvider<ElementType> = (Node<ElementType>) throws -> _Controller<ElementType> where ElementType: Element

public struct FocusRebuildTarget<ElementType: Element> {
    public internal(set) var container: Node<ElementType>?
    public internal(set) var target: Node<ElementType>?
}

public protocol FocusRebuildStrategy {
    associatedtype ElementType: Element
    func move(focus: inout ApplicationFocus<ElementType>.FocusState,
              to target: FocusRebuildTarget<ElementType>,
              controllerProvider: ControllerProvider<ElementType>) throws
}

public struct AnyFocusRebuildStrategy<ElementType: Element> {
    private class Container {
        func move(focus: inout ApplicationFocus<ElementType>.FocusState,
                  to target: FocusRebuildTarget<ElementType>,
                  controllerProvider: ControllerProvider<ElementType>) throws {
            throw FocusRebuildStrategyError.unableToCompleteMove
        }
    }
    private final class _Container<FocusRebuildStrategyType: FocusRebuildStrategy>: Container where FocusRebuildStrategyType.ElementType == ElementType {
        override func move(focus: inout ApplicationFocus<ElementType>.FocusState,
                           to target: FocusRebuildTarget<ElementType>,
                           controllerProvider: ControllerProvider<ElementType>) throws {
            try upstream.move(focus: &focus,
                              to: target,
                              controllerProvider: controllerProvider)
        }
        private let upstream: FocusRebuildStrategyType
        init(upstream: FocusRebuildStrategyType) {
            self.upstream = upstream
        }
    }
    private let upstream: Container
    init<FocusRebuildStrategyType: FocusRebuildStrategy>(upstream: FocusRebuildStrategyType) where FocusRebuildStrategyType.ElementType == ElementType {
        self.upstream = _Container(upstream: upstream)
    }
    public func move(focus: inout ApplicationFocus<ElementType>.FocusState,
                     to target: FocusRebuildTarget<ElementType>,
                     controllerProvider: ControllerProvider<ElementType>) throws {
        try upstream.move(focus: &focus,
                          to: target,
                          controllerProvider: controllerProvider)
    }
}

public extension FocusRebuildStrategy {
    func eraseToAnyFocusRebuildStrategy() -> AnyFocusRebuildStrategy<ElementType> {
        AnyFocusRebuildStrategy(upstream: self)
    }
}

public struct CompositeRebuildStrategy<ElementType: Element>: FocusRebuildStrategy {
    private struct CompositeEntry: FocusRebuildStrategy {
        let move: (inout ApplicationFocus<ElementType>.FocusState,
                   FocusRebuildTarget<ElementType>,
                   ControllerProvider<ElementType>) throws -> Void
        func move(focus: inout ApplicationFocus<ElementType>.FocusState,
                  to target: FocusRebuildTarget<ElementType>,
                  controllerProvider: ControllerProvider<ElementType>) throws {
            try move(&focus, target, controllerProvider)
        }
    }
    public func move(focus: inout ApplicationFocus<ElementType>.FocusState,
                     to target: FocusRebuildTarget<ElementType>,
                     controllerProvider: (Node<ElementType>) throws -> _Controller<ElementType>) throws {
        for strategy in strategies {
            do {
                try strategy.move(&focus, target, controllerProvider)
                return
            } catch {
                
            }
        }
        throw FocusRebuildStrategyError.unableToCompleteMove
    }
    private var strategies = [CompositeEntry]()
    public init() {
        
    }
    public mutating func append<StrategyType: FocusRebuildStrategy>(strategy: StrategyType) where StrategyType.ElementType == ElementType {
        strategies.append(CompositeEntry(move: strategy.move))
    }
}

public struct FullResetRebuildStrategy<ElementType: Element>: FocusRebuildStrategy {
    public func move(focus: inout ApplicationFocus<ElementType>.FocusState,
                     to target: FocusRebuildTarget<ElementType>,
                     controllerProvider: ControllerProvider<ElementType>) throws {
        throw FocusRebuildStrategyError.unableToCompleteMove
    }
    public init() {
        
    }
}

public struct ContainerResetRebuildStrategy<ElementType: Element>: FocusRebuildStrategy {
    public func move(focus: inout ApplicationFocus<ElementType>.FocusState,
                     to target: FocusRebuildTarget<ElementType>,
                     controllerProvider: ControllerProvider<ElementType>) throws {
        throw FocusRebuildStrategyError.unableToCompleteMove
    }
    public init() {
        
    }
}

public struct BasicRebuildStrategy<ElementType: Element>: FocusRebuildStrategy {
    public func move(focus: inout ApplicationFocus<ElementType>.FocusState,
                     to target: FocusRebuildTarget<ElementType>,
                     controllerProvider: ControllerProvider<ElementType>) throws {
        // This strategy won't (shouldn't) do any work to find something to focus on.
        // Create a new strategy to do that work and call through to this one if that
        // is desired.
        guard let focusTarget = target.target else {
            throw FocusRebuildStrategyError.invalidTarget
        }
        guard let focusContainer = focus.container else {
            throw FocusRebuildStrategyError.invalidTarget
        }
        // TODO: Do we need a force rebuild?
        // TODO: Do we need to also check container?
        // TODO: Do we need to validate full parent chain?
        if let currentFocusedController = focus.focused {
            if currentFocusedController.node == focusTarget {
                // Already focused on the right node
                return
            }
        }
        do {
            let ancestor = focusContainer.node
            var nodes = [Node<ElementType>]()
            var current: Node<ElementType>? = focusTarget
            while current != nil, current! != ancestor {
                do {
                    nodes.append(current!)
                    current = try current!.up()
                } catch {
                    current = nil
                }
            }
            nodes.reverse()
            var controller = focusContainer
            for node in nodes {
                // TODO: need to add dirty flag for children to _Controller
                if controller.childControllers.count == 0 {
                    controller._childControllers = try controller.childControllers(node: node)
                }
                guard let index = controller._childControllers.firstIndex(where: { $0.node == node }) else {
                    throw ApplicationFocus<ElementType>.Error.focusedElementNotInHierarchy
                }
                controller = controller._childControllers[index]
            }
            focus.focused = controller
        } catch let error {
            throw ApplicationFocus<ElementType>.Error.focusFailed(error)
        }
    }
    public init() {
        
    }
}

public struct FullRebuildStrategy<ElementType: Element>: FocusRebuildStrategy {
    public func move(focus: inout ApplicationFocus<ElementType>.FocusState,
                     to target: FocusRebuildTarget<ElementType>,
                     controllerProvider: ControllerProvider<ElementType>) throws {
        guard let container = target.container else {
            throw FocusRebuildStrategyError.unableToCompleteMove
        }
        do {
            focus.container = try controllerProvider(container)
            focus.container?.eventHandler.connect()
        } catch let error {
            throw ApplicationFocus<ElementType>.Error.focusFailed(error)
        }
        let strategy = SameContainerRebuildStrategy<ElementType>()
        try strategy.move(focus: &focus,
                          to: target,
                          controllerProvider: controllerProvider)
    }
    public init() {
        
    }
}

public struct SameContainerRebuildStrategy<ElementType: Element>: FocusRebuildStrategy {
    public func move(focus: inout ApplicationFocus<ElementType>.FocusState,
                     to target: FocusRebuildTarget<ElementType>,
                     controllerProvider: ControllerProvider<ElementType>) throws {
        let strategy: AnyFocusRebuildStrategy<ElementType>
        if let _ = target.target {
            strategy = BasicRebuildStrategy<ElementType>()
                .eraseToAnyFocusRebuildStrategy()
        } else if let _ = target.container {
            strategy = ContainerResetRebuildStrategy<ElementType>()
                .eraseToAnyFocusRebuildStrategy()
        } else {
            strategy = FullResetRebuildStrategy<ElementType>()
                .eraseToAnyFocusRebuildStrategy()
        }
        try strategy.move(focus: &focus,
        to: target,
        controllerProvider: controllerProvider)
    }
    public init() {
        
    }
}

public class ApplicationFocus<ElementType: Element> {
    public enum Error: Swift.Error {
        case focusFailed(Swift.Error)
        case typeMismatch
        case focusedElementNotInHierarchy
    }
    public let applicationObserver: ApplicationObserver<ElementType>
    public init(applicationObserver: ApplicationObserver<ElementType>) {
        self.applicationObserver = applicationObserver
    }
    public struct FocusState {
        public internal(set) var container: _Controller<ElementType>?
        public internal(set) var focused: _Controller<ElementType>?
    }
    public private(set) var state = FocusState()
    private static func controllerProvider(target: Node<ElementType>,
                                           applicationController: _Controller<ElementType>,
                                           applicationObserver: ApplicationObserver<ElementType>) throws -> _Controller<ElementType> {
        let shared = try EventHandlerRegistrar<ElementType>.shared()
        let eventHandler = try shared.eventHandler(node: target,
                                                   applicationObserver: applicationObserver)
        let controller = (try eventHandler.makeController()) as! _Controller<ElementType>
        controller._applicationController = applicationController
        return controller
    }
    private func reset(applicationController: _Controller<ElementType>) throws {
        let strategy = FullResetRebuildStrategy<ElementType>()
        try strategy.move(focus: &state,
                          to: FocusRebuildTarget()) { target in
            return try ApplicationFocus<ElementType>
                .controllerProvider(target: target,
                                    applicationController: applicationController,
                                    applicationObserver: applicationObserver)
        }
    }
    private func fullRebuild(target: FocusRebuildTarget<ElementType>,
                             applicationController: _Controller<ElementType>) throws {
        let strategy = FullRebuildStrategy<ElementType>()
        try strategy.move(focus: &state,
                          to: target) { target in
            return try ApplicationFocus<ElementType>
                .controllerProvider(target: target,
                                    applicationController: applicationController,
                                    applicationObserver: applicationObserver)
        }
    }
    public func set(focusedContainerNode: Node<ElementType>?,
                    focusedControllerNode: Node<ElementType>?,
                    applicationController: _Controller<ElementType>) throws {
        guard let updatedFocusedContainerNode = focusedContainerNode else {
            try reset(applicationController: applicationController)
            return
        }
        guard let currentFocusedContainerController = state.container else {
            try fullRebuild(target: FocusRebuildTarget(container: updatedFocusedContainerNode,
                                                       target: focusedControllerNode),
                            applicationController: applicationController)
            return
        }
        guard currentFocusedContainerController.node == updatedFocusedContainerNode else {
            try fullRebuild(target: FocusRebuildTarget(container: updatedFocusedContainerNode,
                                                       target: focusedControllerNode),
                            applicationController: applicationController)
            return
        }
        do {
            let strategy = SameContainerRebuildStrategy<ElementType>()
            try strategy.move(focus: &state,
                              to: FocusRebuildTarget(container: updatedFocusedContainerNode,
                                                     target: focusedControllerNode)) { target in
                return try ApplicationFocus<ElementType>
                    .controllerProvider(target: target,
                                        applicationController: applicationController,
                                        applicationObserver: applicationObserver)
            }
        } catch {
            try fullRebuild(target: FocusRebuildTarget(container: updatedFocusedContainerNode,
                                                       target: focusedControllerNode),
                            applicationController: applicationController)
        }
    }
}
