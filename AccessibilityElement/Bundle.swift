//
//  Bundle.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public func makeSystemApplicationController(processIdentifier: Int) throws -> AnyController {
    let uiElement = AXUIElement.application(processIdentifier: processIdentifier)
    let element = Element(element: uiElement)
    let node = DefaultHierarchy<Element>().buildHierarchy(from: element)
    let eventHandler: AnyEventHandler?
    let observerManager = ObserverManager(provider: SystemObserverProviding.provider())
    let applicationObserver = try observerManager.registerObserver(application: element)
    eventHandler = try? EventHandlerRegistrar.shared
        .eventHandler(node: node, applicationObserver: applicationObserver)
    return try eventHandler?.makeController() as! _Controller<Element>
}

public protocol AccessibilityBundle : class {
    // Return controller representing the application
    func load(processIdentifier: Int) throws -> AnyController
    init()
}
