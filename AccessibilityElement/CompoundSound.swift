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
    public func play(count: Int = 1,
                     cadence: TimeInterval) throws {
        guard let sound = sound else {
            return
        }
        guard count > 0 else {
            return
        }
        guard cadence > 0.0 else {
            return
        }
        // TODO: break critical sections up into: 1. get sounds from available, 2. make new sounds as needed, 3. add sounds to in use
        let sounds: [NSSound] = queue.sync(flags: [.barrier]) {
            if available.count < count {
                for _ in available.count..<count {
                    let copy = sound.copy() as! NSSound
                    copy.delegate = delegate
                    available.append(copy)
                }
            }
            var sounds = [NSSound]()
            for _ in 0..<count {
                let last = available.removeLast()
                inUse.append(last)
                sounds.append(last)
            }
            return sounds
        }
        queue.async {
            for sound in sounds {
                sound.play()
                usleep(useconds_t(cadence * TimeInterval(USEC_PER_SEC)))
            }
        }
    }
}
