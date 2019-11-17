//
//  IntegerIndexSelectionChangeHandler.swift
//
//  Copyright © 2018-2019 Doug Russell. All rights reserved.
//

import Cocoa
import Combine

public class IntegerIndexSelectionChangeHandler<ElementType> : SelectionChangeHandler where ElementType : Element {
    public typealias IndexType = Int
    public let element: ElementType
    public let applicationObserver: ApplicationObserver<ElementType>
    public var previousSelection: Range<Position<IndexType>>?
    private var selectionChange: AnyCancellable? {
        didSet {
            oldValue?.cancel()
        }
    }
    public var output: (([Output.Job.Payload]) -> Void)?
    public required init(element: ElementType,
                         applicationObserver: ApplicationObserver<ElementType>) {
        self.element = element
        self.applicationObserver = applicationObserver
    }
    deinit {
        selectionChange?.cancel()
    }
    public func start() throws {
        selectionChange = try applicationObserver
            .publisher(element: element,
                       notification: .selectedTextChanged)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] element, info in
                guard let info = info else {
                        return
                }
                guard let selectionChange = try? SelectionChangeForIntegerIndexChangeNotification(info: info,
                                                                                                  element: element) else {
                    return
                }
                self?.handle(selectionChange: selectionChange)
            })
    }
    public func stop() {
        selectionChange?.cancel()
        selectionChange = nil
    }
}
