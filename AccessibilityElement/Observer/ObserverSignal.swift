//
//  ObserverSignal.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import Signals

public typealias ObserverInfo = [String:Any]

public final class ObserverSignal<ObserverProvidingType> where ObserverProvidingType : ObserverProviding {
    public typealias SignalData = (element: ObserverProvidingType.ElementType, info: ObserverInfo?)
    private weak var observer: ApplicationObserver<ObserverProvidingType>?
    private let element: ObserverProvidingType.ElementType
    private let notification: NSAccessibilityNotificationName
    private let signal = Signal<(element: ObserverProvidingType.ElementType, info: ObserverInfo?)>()
    private var token: ApplicationObserver<ObserverProvidingType>.Token?
    private var count = 0
    func increment() throws {
        count += 1
        if count == 1 {
            token = try observer?.startObserving(element: element, notification: notification) { element, info -> Void in
                self.signal=>(element, info)
            }
        }
    }
    func decrement() throws {
        count -= 1
        if count == 0 {
            if let token = token {
                try observer?.stopObserving(token: token)
                self.token = nil
            }
        }
    }
    init(element: ObserverProvidingType.ElementType,
         notification: NSAccessibilityNotificationName,
         observer: ApplicationObserver<ObserverProvidingType>) {
        self.element = element
        self.notification = notification
        self.observer = observer
    }
    @discardableResult
    public func subscribe(callback: @escaping ((element: ObserverProvidingType.ElementType, info: ObserverInfo?)) -> Void) -> SignalSubscription<(element: ObserverProvidingType.ElementType, info: ObserverInfo?)> {
        try? increment()
        return signal.subscribe(with: self, callback: callback)
    }
    @discardableResult
    public func subscribe(with observer: AnyObject, callback: @escaping ((element: ObserverProvidingType.ElementType, info: ObserverInfo?)) -> Void) -> SignalSubscription<(element: ObserverProvidingType.ElementType, info: ObserverInfo?)> {
        try? increment()
        return signal.subscribe(with: observer, callback: callback)
    }
}
