//
//  IntegerIndexSelectionChangeHandler.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa
import Signals

public class IntegerIndexSelectionChangeHandler<ObserverProvidingType> : SelectionChangeHandler where ObserverProvidingType : ObserverProviding {
    public typealias ElementType = ObserverProvidingType.ElementType
    public typealias IndexType = Int
    public let element: ElementType
    public let applicationObserver: ApplicationObserver<ObserverProvidingType>
    public var previousSelection: Range<Position<IndexType>>?
    private var selectionChangeSubscription: SignalSubscription<(element: ElementType, info: ObserverInfo?)>?
    public var output: (([Output.Job.Payload]) -> Void)?
    public required init(element: ElementType, applicationObserver: ApplicationObserver<ObserverProvidingType>) {
        self.element = element
        self.applicationObserver = applicationObserver
    }
    public func start() throws {
        guard selectionChangeSubscription == nil else {
            return
        }
        let signal = try applicationObserver.signal(element: element, notification: .selectedTextChanged)
        selectionChangeSubscription = signal.subscribe { [weak self] element, info in
            guard let info = info else {
                return
            }
            do {
                guard let selectionChange = try SelectionChangeForIntegerIndexChangeNotification(info: info, element: element) else {
                    return
                }
                self?.handle(selectionChange: selectionChange)
            } catch {
                
            }
        }
    }
    public func stop() {
        selectionChangeSubscription?.cancel()
        selectionChangeSubscription = nil
    }
}
