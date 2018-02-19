//
//  CompoundSound.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

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
    private func cleanup(sound: NSSound,
                         didFinishPlaying: Bool) {
        queue.async { _ in
            guard let index = self.inUse.index(of: sound) else {
                return
            }
            self.available.append(self.inUse.remove(at: index))
        }
    }
    private var inUse = [NSSound]()
    private var available = [NSSound]()
    private let queue = CancellableQueue(label: "CompoundSound",
                                         qos: .userInitiated,
                                         options: .serial)
    private var _volume: Float = 0.0
    private var volumeQueue = DispatchQueue(label: "CompoundSound.volume")
    public var volume: Float {
        get {
            return volumeQueue.sync {
                return _volume
            }
        }
        set {
            volumeQueue.sync {
                _volume = newValue
                queue.async { item in
                    for sound in self.available {
                        sound.volume = newValue
                    }
                    for sound in self.inUse {
                        sound.volume = newValue
                    }
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
            self?.cleanup(sound: sound, didFinishPlaying: didFinish)
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
        queue.async { workItem in
            if workItem.isCancelled {
                return
            }
            var sounds: [NSSound]
            if self.available.count < count {
                sounds = self.available
                self.available = []
            } else {
                sounds = Array(self.available[0..<count])
                self.available.removeSubrange(0..<count)
            }
            if workItem.isCancelled {
                self.available.append(contentsOf: sounds)
                return
            }
            if sounds.count < count {
                for _ in sounds.count..<count {
                    let copy = sound.copy() as! NSSound
                    copy.delegate = self.delegate
                    sounds.append(copy)
                }
            }
            self.inUse.append(contentsOf: sounds)
            if workItem.isCancelled {
                self.available.append(contentsOf: self.inUse)
                self.inUse.removeAll()
                return
            }
            for sound in sounds {
                if workItem.isCancelled {
                    self.available.append(contentsOf: self.inUse)
                    self.inUse.removeAll()
                    break
                }
                sound.play()
                usleep(useconds_t(cadence * TimeInterval(USEC_PER_SEC)))
            }
        }
    }
    public func stop() {
        queue.cancelAll()
        queue.async { _ in
            self.available.append(contentsOf: self.inUse)
            self.inUse.removeAll()
        }
    }
}
