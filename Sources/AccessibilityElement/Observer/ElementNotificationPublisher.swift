//
//  ElementNotificationPublisher.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Cocoa
import Combine

public typealias ElementNotificationInfo = [String:Any]

public final class ElementNotificationPublisher<ElementType: Element>: Publisher {
    public typealias Output = (element: ElementType, info: ElementNotificationInfo?)
    public typealias Failure = ObserverError

    private final class Subscription<S: Subscriber>: Combine.Subscription where Failure == S.Failure, Output == S.Input {
        private(set) var subscriber: S?
        func request(_ demand: Subscribers.Demand) {
            guard let observer = observer else {
                return
            }
            do {
                token = try observer
                    .startObserving(element: element,
                                    notification: notification) { [weak self] element, info in
                    _ = self?.subscriber?.receive((element, info))
                }
            } catch let error as ObserverError {
                subscriber?.receive(completion: .failure(error))
                cancel()
            } catch {
                
            }
        }
        func cancel() {
            subscriber = nil
            if let token = token, let observer = observer {
                try? observer.stopObserving(token: token)
            }
            observer = nil
            token = nil
        }
        private let element: ElementType
        private let notification: NSAccessibility.Notification
        private weak var observer: ApplicationObserver<ElementType>?
        private var token: ApplicationObserver<ElementType>.Token?
        init(subscriber: S,
             element: ElementType,
             notification: NSAccessibility.Notification,
             observer: ApplicationObserver<ElementType>?) {
            self.subscriber = subscriber
            self.element = element
            self.notification = notification
            self.observer = observer
        }
    }

    public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        subscriber.receive(subscription: Subscription(subscriber: subscriber,
                                                      element: element,
                                                      notification: notification,
                                                      observer: observer))
    }

    private let element: ElementType
    private let notification: NSAccessibility.Notification
    private weak var observer: ApplicationObserver<ElementType>?
    init(element: ElementType,
         notification: NSAccessibility.Notification,
         observer: ApplicationObserver<ElementType>) {
        self.element = element
        self.notification = notification
        self.observer = observer
    }
}
