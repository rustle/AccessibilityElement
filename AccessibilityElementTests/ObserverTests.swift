//
//  ObserverTests.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import XCTest
@testable import AccessibilityElement

class MockObserverProviding : ObserverProviding {
    static func provider() -> ((Int) throws -> MockObserverProviding) {
        return { _ in
            MockObserverProviding()
        }
    }
    typealias ElementType = MockElement
    private var handler: ((MockElement, NSAccessibilityNotificationName, [String : Any]?) -> Void)?
    init() {
        
    }
    func add(element: MockElement,
                      notification: NSAccessibilityNotificationName,
                      handler: @escaping (MockElement, NSAccessibilityNotificationName, [String : Any]?) -> Void) throws -> Int {
        self.handler = handler
        return 2
    }
    func remove(element: MockElement,
                         notification: NSAccessibilityNotificationName,
                         identifier: Int) throws {
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
    var observerManager: ObserverManager<MockObserverProviding>?
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
            let element = MockElement.application(processIdentifier: 1)
            let observer = try observerManager?.registerObserver(application: element)
            let signal = try observer?.signal(element: element, notification: .focusedUIElementChanged)
            var fired = false
            signal?.subscribe { element, info in
                fired = true
            }
            provider?.fire(element: element, notification: .focusedUIElementChanged, info: nil)
            XCTAssertTrue(fired)
        } catch let error {
            XCTFail("\(error)")
        }
    }
}
