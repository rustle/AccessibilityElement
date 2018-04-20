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
    var handler: ((MockElement, NSAccessibilityNotificationName, [String : Any]?) -> Void)?
    init() {
        
    }
    func add(element: AnyElement, notification: NSAccessibilityNotificationName, handler: @escaping (AnyElement, NSAccessibilityNotificationName, [String : Any]?) -> Void) throws -> Int {
        self.handler = handler as (MockElement, NSAccessibilityNotificationName, [String : Any]?) -> Void
        return 2
    }
    
    func remove(element: AnyElement, notification: NSAccessibilityNotificationName, identifier: Int) throws {
        self.handler = nil
    }
    func fire(element: MockElement,
              notification: NSAccessibilityNotificationName,
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
    func testSignal() {
        do {
            let element = try MockElement.application(processIdentifier: 1)
            let observer = try observerManager?.registerObserver(application: element)
            let signal = try observer?.signal(element: element, notification: .focusedUIElementChanged)
            var fired = false
            let sub = signal?.subscribe { element, info in
                fired = true
            }
            provider?.fire(element: element, notification: .focusedUIElementChanged, info: nil)
            XCTAssertTrue(fired)
            sub?.cancel()
        } catch let error {
            XCTFail("\(error)")
        }
    }
    func testDisposeSignal() {
        do {
            let element = try MockElement.application(processIdentifier: 1)
            let observer = try observerManager!.registerObserver(application: element)
            let signal = try observer.signal(element: element, notification: .focusedUIElementChanged)
            let subscription = signal.subscribe { element, info in
                
            }
            XCTAssertNotNil(provider!.handler)
            subscription.cancel()
            XCTAssertTrue(provider!.handler == nil)
        } catch {
            XCTFail("\(error)")
        }
    }
}
