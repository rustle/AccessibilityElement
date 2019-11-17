//
//  FocusedUIElementChangedHandler.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa

// TODO: This is a direct extraction of logic from Application and needs more design work

public enum FocusedUIElementChangedHandlerError : Error {
    case containerSearchFailed
}

public protocol FocusedUIElementChangedHandler {
    func findContainer<ElementType, HierarchyType>(element: ElementType,
                                                   hierarchy: HierarchyType) throws -> ElementType where HierarchyType : Hierarchy, HierarchyType.ElementType == ElementType
    func focusChanged<ElementType, HierarchyType>(element: ElementType,
                                                  hierarchy: HierarchyType,
                                                  focus: ApplicationFocus<ElementType>,
                                                  applicationController: _Controller<ElementType>) -> String? where HierarchyType : Hierarchy, HierarchyType.ElementType == ElementType 
}

public extension FocusedUIElementChangedHandler {
    func findContainer<ElementType, HierarchyType>(element: ElementType,
                                                   hierarchy: HierarchyType) throws -> ElementType where HierarchyType : Hierarchy, HierarchyType.ElementType == ElementType {
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
        throw FocusedUIElementChangedHandlerError.containerSearchFailed
    }
    func focusChanged<ElementType, HierarchyType>(element: ElementType,
                                                  hierarchy: HierarchyType,
                                                  focus: ApplicationFocus<ElementType>,
                                                  applicationController: _Controller<ElementType>) -> String? where HierarchyType : Hierarchy, HierarchyType.ElementType == ElementType {
        do {
            let container = try findContainer(element: element,
                                              hierarchy: hierarchy)
            var focusedNode: Node<ElementType>? = Node(element: element,
                                                       role: .include)
            let node = hierarchy.buildHierarchy(from: container,
                                                targeting: &focusedNode)
            try focus.set(focusedContainerNode: node,
                          focusedControllerNode: focusedNode,
                          applicationController: applicationController)
            return focus.state.focused?.eventHandler.focusIn()
        } catch {
            do {
                let node = Node(element: element,
                                role: .include)
                try focus.set(focusedContainerNode: nil,
                              focusedControllerNode: node,
                              applicationController: applicationController)
                return focus.state.focused?.eventHandler.focusIn()
            } catch { }
        }
        return nil
    }
}

public struct DefaultFocusedUIElementChangedHandler : FocusedUIElementChangedHandler {
    init() {
        
    }
}
