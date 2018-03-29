//
//  Bundle.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public func makeSystemApplicationController(processIdentifier: ProcessIdentifier) throws -> AnyController {
    let uiElement = AXUIElement.application(processIdentifier: processIdentifier)
    let element = Element(element: uiElement)
    var ignored: Node<Element>? = nil
    let node = DefaultHierarchy<Element>().buildHierarchy(from: element, targeting: &ignored)
    let eventHandler: AnyEventHandler?
    let observerManager = ObserverManager<Element>(provider: SystemObserverProviding.provider())
    let applicationObserver = try observerManager.registerObserver(application: element)
    let shared = try EventHandlerRegistrar<Element>.shared()
    eventHandler = try? shared.eventHandler(node: node, applicationObserver: applicationObserver)
    return try eventHandler?.makeController() as! _Controller<Element>
}

public protocol AccessibilityBundle : class {
    /// Return controller representing the application
    func load(processIdentifier: ProcessIdentifier) throws -> AnyController
    init()
}
