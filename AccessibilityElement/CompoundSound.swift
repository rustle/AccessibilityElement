//
//  CompoundSound.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

extension DispatchWorkItem : Equatable {
    public static func ==(lhs: DispatchWorkItem, rhs: DispatchWorkItem) -> Bool {
        return lhs === rhs
    }
}

public class CompoundSound {
    private class Delegate : NSObject, NSSoundDelegate {
        var didFinish: ((NSSound, Bool) -> Void)?
        public func sound(_ sound: NSSound,
                          didFinishPlaying flag: Bool) {
            didFinish?(sound, flag)
        }
    }
    private let delegate = Delegate()
    private let sound: NSSound?
    private func callback(sound: NSSound,
                          didFinishPlaying: Bool) {
        queue.sync(flags: [.barrier]) {
            guard let index = inUse.index(of: sound) else {
                return
            }
            available.append(inUse.remove(at: index))
        }
    }
    private var inUse = [NSSound]()
    private var available = [NSSound]()
    private var workItems = [DispatchWorkItem]()
    private let queue = DispatchQueue(label: "CompoundSound",
                                      qos: .userInitiated,
                                      attributes: [.concurrent],
                                      autoreleaseFrequency: .workItem,
                                      target: .global())
    private var _volume: Float = 0.0
    public var volume: Float {
        get {
            return queue.sync(flags: [.barrier]) {
                return _volume
            }
        }
        set {
            queue.sync(flags: [.barrier]) {
                _volume = newValue
                for sound in available {
                    sound.volume = newValue
                }
                for sound in inUse {
                    sound.volume = newValue
                }
            }
        }
    }
    public convenience init?(resourceName: String,
                             `extension`: String) {
        guard let url = Bundle.main.url(forResource: resourceName,
                                        withExtension: `extension`) else {
            return nil
        }
        self.init(url: url)
    }
    public init(url: URL) {
        sound = NSSound(contentsOf: url,
                        byReference: true)
        if let sound = sound {
            sound.delegate = delegate
            available.append(sound)
            _volume = sound.volume
        } else {
            _volume = 0.0
        }
        delegate.didFinish = { [weak self] sound, didFinish in
            self?.callback(sound: sound, didFinishPlaying: didFinish)
        }
    }
    public enum Error : Swift.Error {
        case invalidSound
        case invalidCount(Int)
        case invalidCadence(TimeInterval)
    }
    public func play(count: Int = 1,
                     cadence: TimeInterval) throws {
        guard let sound = sound else {
            throw CompoundSound.Error.invalidSound
        }
        guard count > 0 else {
            throw CompoundSound.Error.invalidCount(count)
        }
        guard cadence > 0.0 else {
            throw CompoundSound.Error.invalidCadence(cadence)
        }
        var sounds: [NSSound] = queue.sync(flags: [.barrier]) {
            if available.count < count {
                let sounds = available
                available = []
                return sounds
            } else {
                let sounds = Array(available[0..<count])
                available.removeSubrange(0..<count)
                return sounds
            }
        }
        if sounds.count < count {
            for _ in sounds.count..<count {
                let copy = sound.copy() as! NSSound
                copy.delegate = delegate
                sounds.append(copy)
            }
        }
        queue.sync(flags: [.barrier]) {
            inUse.append(contentsOf: sounds)
        }
        weak var cancelToken: DispatchWorkItem? = nil
        let workItem = DispatchWorkItem {
            for sound in sounds {
                if let cancelToken = cancelToken, cancelToken.isCancelled {
                    break
                }
                sound.play()
                usleep(useconds_t(cadence * TimeInterval(USEC_PER_SEC)))
            }
        }
        workItem.notify(qos: .userInitiated, flags: [.barrier], queue: queue) {
            // Following self. uses are a retain cycle but they'll self resolve
            // when the block finishes
            self.queue.async(flags: [.barrier]) {
                guard let cancelToken = cancelToken else {
                    return
                }
                guard let index = self.workItems.index(of: cancelToken) else {
                    return
                }
                self.workItems.remove(at: index)
            }
        }
        cancelToken = workItem
        queue.sync(flags: [.barrier]) {
            workItems.append(workItem)
        }
        queue.async(execute: workItem)
    }
    public func stop() {
        
    }
}
