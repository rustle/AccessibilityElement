//
//  ObserverTests.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import XCTest
@testable import AccessibilityElement

class MockObserverProviding : ObserverProviding {
    static func provider() -> ((ProcessIdentifier) throws -> MockObserverProviding) {
        return { _ in
            MockObserverProviding()
        }
    }
    typealias ElementType = MockElement
    var handler: ((MockElement, NSAccessibility.Notification, [String : Any]?) -> Void)?
    init() {
        
    }
    func add(element: AnyElement, notification: NSAccessibility.Notification, handler: @escaping (AnyElement, NSAccessibility.Notification, [String : Any]?) -> Void) throws -> Int {
        self.handler = handler as (MockElement, NSAccessibility.Notification, [String : Any]?) -> Void
        return 2
    }
    
    func remove(element: AnyElement, notification: NSAccessibility.Notification, identifier: Int) throws {
        self.handler = nil
    }
    func fire(element: MockElement,
              notification: NSAccessibility.Notification,
              info: [String : Any]?) {
        self.handler?(element, notification, info)
    }
}

class ObserverTests: XCTestCase {
    var provider: MockObserverProviding?
    var observerManager: ObserverManager<MockElement>?
    override func setUp() {
        super.setUp()
        let provider = MockObserverProviding()
        self.provider = provider
        self.observerManager = ObserverManager(provider: { _ in
            return provider
        })
    }
    func testRegister() {
        do {
            _ = try observerManager?.registerObserver(application: MockElement.application(processIdentifier: 1))
        } catch let error {
            XCTFail("\(error)")
        }
    }
    func testPublisher() {
        do {
            let element = try MockElement.application(processIdentifier: 1)
            let observer = try observerManager?.registerObserver(application: element)
            let publisher = try observer?.publisher(element: element,
                                                    notification: .focusedUIElementChanged)
            var fired = false
            let cancellable = publisher?.sink(receiveCompletion: { _ in
                
            }, receiveValue: { _, _ in
                fired = true
            })
            provider?.fire(element: element, notification: .focusedUIElementChanged, info: nil)
            XCTAssertTrue(fired)
            cancellable?.cancel()
        } catch let error {
            XCTFail("\(error)")
        }
    }
    func testPublisherCancel() {
        do {
            let element = try MockElement.application(processIdentifier: 1)
            let observer = try observerManager?.registerObserver(application: element)
            let publisher = try observer?.publisher(element: element,
                                                    notification: .focusedUIElementChanged)
            let cancellable = publisher?.sink(receiveCompletion: { _ in
                
            }, receiveValue: { _, _ in
                
            })
            XCTAssertNotNil(provider!.handler)
            cancellable?.cancel()
            XCTAssertTrue(provider!.handler == nil)
        } catch {
            XCTFail("\(error)")
        }
    }
}
