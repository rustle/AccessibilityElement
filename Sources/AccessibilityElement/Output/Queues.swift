//
//  Queues.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

fileprivate protocol WorkImplementation {
    func async(qos: DispatchQoS,
               flags: DispatchWorkItemFlags,
               execute workItem: DispatchWorkItem)
}

public protocol CancellableItem {
    var isCancelled: Bool { get }
}

extension DispatchWorkItem: CancellableItem {}

public class CancellableQueue {
    public func async(qos: DispatchQoS = .`default`,
                      flags: DispatchWorkItemFlags = [],
                      execute work: @escaping (CancellableItem) -> Void) {
        var cancellable: Unmanaged<DispatchWorkItem>!
        let item = DispatchWorkItem(qos: qos,
                                    flags: flags) {
            work(cancellable.takeUnretainedValue())
        }
        cancellable = Unmanaged.passUnretained(item)
        itemsQueue.sync {
            items.append(item)
        }
        item.notify(qos: .`default`,
                    flags: [],
                    queue: itemsQueue) { [weak item] in
            guard let item = item else {
                return
            }
            guard let index = self.items.index(identity: item) else {
                return
            }
            self.items.remove(at: index)
        }
        scheduler.async(qos: qos,
                        flags: flags,
                        execute: item)
    }
    public enum Options {
        case serial
        case concurrent(Int)
    }
    public init(label: String,
                qos: DispatchQoS = .`default`,
                options: Options = .serial) {
        switch options {
        case .serial:
            scheduler = SerialWorkImplementation(label: label,
                                                 qos: qos)
        case .concurrent(let count):
            scheduler = ConcurrentWorkImplementation(label: label,
                                                     qos: qos,
                                                     count: count)
        }
    }
    public func cancelAll() {
        itemsQueue.sync {
            items.forEach { $0.cancel() }
            items.removeAll()
        }
    }
    private let scheduler: WorkImplementation
    private let itemsQueue = DispatchQueue(label: "Work.Items")
    private var items = [DispatchWorkItem]()
    private struct ConcurrentWorkImplementation: WorkImplementation {
        private let queue: BoundedQueue
        init(label: String,
             qos: DispatchQoS,
             count: Int) {
            queue = BoundedQueue(label: label,
                                 qos: qos,
                                 count: count,
                                 autoreleaseFrequency: .workItem)
        }
        func async(qos: DispatchQoS,
                   flags: DispatchWorkItemFlags,
                   execute workItem: DispatchWorkItem) {
            queue.async(qos: qos,
                        flags: flags) {
                if !workItem.isCancelled {
                    workItem.perform()
                }
            }
        }
    }
    private struct SerialWorkImplementation: WorkImplementation {
        private let queue: DispatchQueue
        init(label: String,
             qos: DispatchQoS) {
            queue = DispatchQueue(label: label,
                                  qos: qos,
                                  attributes: [],
                                  autoreleaseFrequency: .workItem,
                                  target: .global())
        }
        func async(qos: DispatchQoS,
                   flags: DispatchWorkItemFlags,
                   execute workItem: DispatchWorkItem) {
            queue.async(group: nil,
                        qos: qos,
                        flags: flags) {
                if !workItem.isCancelled {
                    workItem.perform()
                }
            }
        }
    }
}

public class BoundedQueue {
    private let group = DispatchGroup()
    private let semaphore: DispatchSemaphore
    private let work: DispatchQueue
    private let waiting: DispatchQueue
    public convenience init(label: String,
                            count: Int) {
        self.init(label: label,
                  qos: .`default`,
                  count: count,
                  autoreleaseFrequency: .workItem)
    }
    public init(label: String,
                qos: DispatchQoS,
                count: Int,
                autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency) {
        work = DispatchQueue(label: label,
                             qos: qos,
                             attributes: [.concurrent],
                             autoreleaseFrequency: autoreleaseFrequency,
                             target: nil)
        waiting = DispatchQueue(label: "\(label).waiting",
            qos: qos,
            attributes: [],
            autoreleaseFrequency: .workItem,
            target: work)
        semaphore = DispatchSemaphore(value: count)
    }
    public func async(execute work: @escaping () -> Void) {
        async(qos: .`default`,
              flags: [],
              execute: work)
    }
    public func async(qos: DispatchQoS,
                      flags: DispatchWorkItemFlags,
                      execute work: @escaping () -> Void) {
        group.enter()
        waiting.async {
            self.semaphore.wait()
            self.work.async(qos: qos,
                            flags: flags) {
                work()
                self.semaphore.signal()
                self.group.leave()
            }
        }
    }
    public func sync<T>(execute work: () throws -> T) rethrows -> T {
        group.enter()
        return try waiting.sync {
            semaphore.wait()
            return try self.work.sync {
                let result = try work()
                semaphore.signal()
                group.leave()
                return result
            }
        }
    }
}
