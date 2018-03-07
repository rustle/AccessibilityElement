//
//  ObserverSignal.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa
import Signals

public typealias ObserverInfo = [String:Any]

public final class ObserverSignal<ObserverProvidingType> : AnySignal where ObserverProvidingType : ObserverProviding {
    public typealias T = (element: ObserverProvidingType.ElementType, info: ObserverInfo?)
    private weak var observer: ApplicationObserver<ObserverProvidingType>?
    private let element: ObserverProvidingType.ElementType
    private let notification: NSAccessibilityNotificationName
    private var token: ApplicationObserver<ObserverProvidingType>.Token?
    init(element: ObserverProvidingType.ElementType,
         notification: NSAccessibilityNotificationName,
         observer: ApplicationObserver<ObserverProvidingType>) {
        self.element = element
        self.notification = notification
        self.observer = observer
    }
    public var subscriptions = [Subscription<T>]()
    public func append(subscription: Subscription<T>) {
        if subscriptions.count == 0 {
            startObserving()
        }
        subscription.dispose { [weak self] in
            self?.flush()
        }
        subscriptions.append(subscription)
    }
    public func flush() {
        subscriptions = subscriptions.filter {
            return $0.handler != nil
        }
        if subscriptions.count == 0 {
            stopObserving()
        }
    }
    public func removeAll() {
        subscriptions.removeAll()
        stopObserving()
    }
    private func startObserving() {
        do {
            token = try observer?.startObserving(element: element, notification: notification) { element, info -> Void in
                self.fire((element, info))
            }
        } catch {
            
        }
    }
    private func stopObserving() {
        do {
            if let token = token {
                try observer?.stopObserving(token: token)
                self.token = nil
            }
        } catch {
            
        }
    }
}
