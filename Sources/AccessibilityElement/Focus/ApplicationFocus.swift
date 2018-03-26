//
//  ApplicationFocus.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa

public enum FocusRebuildStrategyError : Error {
    case unableToCompleteMove
    case invalidTarget
}

public typealias ControllerProvider<ObserverProvidingType> = (Node<ObserverProvidingType.ElementType>) throws -> _Controller<ObserverProvidingType.ElementType> where ObserverProvidingType : ObserverProviding

public struct FocusRebuildTarget<ElementType> where ElementType : _Element {
    public internal(set) var container: Node<ElementType>?
    public internal(set) var target: Node<ElementType>?
}

public protocol FocusRebuildStrategy {
    associatedtype ObserverProvidingType where ObserverProvidingType : ObserverProviding
    func move(focus: inout ApplicationFocus<ObserverProvidingType>.FocusState,
              to target: FocusRebuildTarget<ObserverProvidingType.ElementType>,
              controllerProvider: ControllerProvider<ObserverProvidingType>) throws
}

public struct CompositeRebuildStrategy<ObserverProvidingType> : FocusRebuildStrategy
    where ObserverProvidingType : ObserverProviding {
    private struct CompositeEntry<ObserverProvidingType> : FocusRebuildStrategy
        where ObserverProvidingType : ObserverProviding {
        typealias ElementType = ObserverProvidingType.ElementType
        let move: (inout ApplicationFocus<ObserverProvidingType>.FocusState,
                   FocusRebuildTarget<ElementType>,
                   ControllerProvider<ObserverProvidingType>) throws -> Void
        func move(focus: inout ApplicationFocus<ObserverProvidingType>.FocusState,
                  to target: FocusRebuildTarget<ElementType>,
                  controllerProvider: ControllerProvider<ObserverProvidingType>) throws {
            try move(&focus, target, controllerProvider)
        }
    }
    public typealias ElementType = ObserverProvidingType.ElementType
    public func move(focus: inout ApplicationFocus<ObserverProvidingType>.FocusState,
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
    private var strategies = [CompositeEntry<ObserverProvidingType>]()
    public init() {
        
    }
    public mutating func append<StrategyType : FocusRebuildStrategy>(strategy: StrategyType)
            where StrategyType.ObserverProvidingType == ObserverProvidingType {
        strategies.append(CompositeEntry(move: strategy.move))
    }
}

public struct FullResetRebuildStrategy<ObserverProvidingType> : FocusRebuildStrategy
    where ObserverProvidingType : ObserverProviding {
    public typealias ElementType = ObserverProvidingType.ElementType
    public func move(focus: inout ApplicationFocus<ObserverProvidingType>.FocusState,
                     to target: FocusRebuildTarget<ElementType>,
                     controllerProvider: ControllerProvider<ObserverProvidingType>) throws {
        throw FocusRebuildStrategyError.unableToCompleteMove
    }
    public init() {
        
    }
}

public struct ContainerResetRebuildStrategy<ObserverProvidingType> : FocusRebuildStrategy
    where ObserverProvidingType : ObserverProviding {
    public typealias ElementType = ObserverProvidingType.ElementType
    public func move(focus: inout ApplicationFocus<ObserverProvidingType>.FocusState,
                     to target: FocusRebuildTarget<ElementType>,
                     controllerProvider: ControllerProvider<ObserverProvidingType>) throws {
        throw FocusRebuildStrategyError.unableToCompleteMove
    }
    public init() {
        
    }
}

public struct BasicRebuildStrategy<ObserverProvidingType> : FocusRebuildStrategy
    where ObserverProvidingType : ObserverProviding {
    public typealias ElementType = ObserverProvidingType.ElementType
    public func move(focus: inout ApplicationFocus<ObserverProvidingType>.FocusState,
                     to target: FocusRebuildTarget<ElementType>,
                     controllerProvider: ControllerProvider<ObserverProvidingType>) throws {
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
                guard let index = controller._childControllers.index(where: { return $0.node == node }) else {
                    throw ApplicationFocus<ObserverProvidingType>.Error.focusedElementNotInHierarchy
                }
                controller = controller._childControllers[index]
            }
            focus.focused = controller
        } catch let error {
            throw ApplicationFocus<ObserverProvidingType>.Error.focusFailed(error)
        }
    }
    public init() {
        
    }
}

public struct FullRebuildStrategy<ObserverProvidingType> : FocusRebuildStrategy
    where ObserverProvidingType : ObserverProviding {
    public typealias ElementType = ObserverProvidingType.ElementType
    public func move(focus: inout ApplicationFocus<ObserverProvidingType>.FocusState,
                     to target: FocusRebuildTarget<ElementType>,
                     controllerProvider: ControllerProvider<ObserverProvidingType>) throws {
        guard let container = target.container else {
            throw FocusRebuildStrategyError.unableToCompleteMove
        }
        do {
            focus.container = try controllerProvider(container)
            focus.container?.eventHandler.connect()
        } catch let error {
            throw ApplicationFocus<ObserverProvidingType>.Error.focusFailed(error)
        }
        let strategy = SameContainerRebuildStrategy<ObserverProvidingType>()
        try strategy.move(focus: &focus,
                          to: target,
                          controllerProvider: controllerProvider)
    }
    public init() {
        
    }
}

public struct SameContainerRebuildStrategy<ObserverProvidingType> : FocusRebuildStrategy
    where ObserverProvidingType : ObserverProviding {
    public typealias ElementType = ObserverProvidingType.ElementType
    public func move(focus: inout ApplicationFocus<ObserverProvidingType>.FocusState,
                     to target: FocusRebuildTarget<ElementType>,
                     controllerProvider: ControllerProvider<ObserverProvidingType>) throws {
        // One day swift will get generalized existentials and the
        // try strategy.move(focus:to:controllerProvider:)
        // calls can be consolidated
        if let _ = target.target {
            let strategy = BasicRebuildStrategy<ObserverProvidingType>()
            try strategy.move(focus: &focus,
                              to: target,
                              controllerProvider: controllerProvider)
        } else if let _ = target.container {
            let strategy = ContainerResetRebuildStrategy<ObserverProvidingType>()
            try strategy.move(focus: &focus,
                              to: target,
                              controllerProvider: controllerProvider)
        } else {
            let strategy = FullResetRebuildStrategy<ObserverProvidingType>()
            try strategy.move(focus: &focus,
                              to: target,
                              controllerProvider: controllerProvider)
        }
    }
    public init() {
        
    }
}

public class ApplicationFocus<ObserverProvidingType>
    where ObserverProvidingType : ObserverProviding {
    public typealias ElementType = ObserverProvidingType.ElementType
    public enum Error : Swift.Error {
        case focusFailed(Swift.Error)
        case typeMismatch
        case focusedElementNotInHierarchy
    }
    public let applicationObserver: ApplicationObserver<ObserverProvidingType>
    public init(applicationObserver: ApplicationObserver<ObserverProvidingType>) {
        self.applicationObserver = applicationObserver
    }
    public struct FocusState {
        public internal(set) var container: _Controller<ElementType>?
        public internal(set) var focused: _Controller<ElementType>?
    }
    public private(set) var state = FocusState()
    private static func controllerProvider(target: Node<ElementType>,
                                           applicationController: _Controller<ElementType>,
                                           applicationObserver: ApplicationObserver<ObserverProvidingType>) throws -> _Controller<ElementType> {
        let shared = try EventHandlerRegistrar<ObserverProvidingType>.shared()
        let eventHandler = try shared.eventHandler(node: target,
                                                   applicationObserver: applicationObserver)
        let controller = (try eventHandler.makeController()) as! _Controller<ElementType>
        controller._applicationController = applicationController
        return controller
    }
    private func reset(applicationController: _Controller<ElementType>) throws {
        let strategy = FullResetRebuildStrategy<ObserverProvidingType>()
        try strategy.move(focus: &state,
                          to: FocusRebuildTarget()) { target in
            return try ApplicationFocus<ObserverProvidingType>
                .controllerProvider(target: target,
                                    applicationController: applicationController,
                                    applicationObserver: applicationObserver)
        }
    }
    private func fullRebuild(target: FocusRebuildTarget<ElementType>,
                             applicationController: _Controller<ElementType>) throws {
        let strategy = FullRebuildStrategy<ObserverProvidingType>()
        try strategy.move(focus: &state,
                          to: target) { target in
            return try ApplicationFocus<ObserverProvidingType>
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
            let strategy = SameContainerRebuildStrategy<ObserverProvidingType>()
            try strategy.move(focus: &state,
                              to: FocusRebuildTarget(container: updatedFocusedContainerNode,
                                                     target: focusedControllerNode)) { target in
                return try ApplicationFocus<ObserverProvidingType>
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
