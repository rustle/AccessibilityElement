//
//  Output.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa

public class Output {
    public struct Options : OptionSet, Codable {
        public let rawValue: Int
        public static let interrupt = Options(rawValue: 1 << 0)
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    public struct Job : Codable {
        public var options: Options
        public var identifier: String
        public enum Payload : Codable {
            private enum PayloadType : Int, Codable {
                case pauseSpeech
                case continueSpeech
                case cancelSpeech
                case speech
                case sound
            }
            private enum PayloadCodingKeys : String, CodingKey {
                case type = "a"
                case speech = "b"
                case names = "c"
                case counts = "d"
                case cadences = "e"
            }
            case pauseSpeech
            case continueSpeech
            case cancelSpeech
            case speech(String)
            case sound([String], [Int], [TimeInterval])
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: PayloadCodingKeys.self)
                switch self {
                case .pauseSpeech:
                    try container.encode(PayloadType.pauseSpeech, forKey: .type)
                case .continueSpeech:
                    try container.encode(PayloadType.continueSpeech, forKey: .type)
                case .cancelSpeech:
                    try container.encode(PayloadType.cancelSpeech, forKey: .type)
                case .sound(let names, let counts, let cadences):
                    try container.encode(PayloadType.sound, forKey: .type)
                    try container.encode(names, forKey: .names)
                    try container.encode(counts, forKey: .counts)
                    try container.encode(cadences, forKey: .cadences)
                case .speech(let value):
                    try container.encode(PayloadType.speech, forKey: .type)
                    try container.encode(value, forKey: .speech)
                }
            }
            public init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: PayloadCodingKeys.self)
                switch try values.decode(PayloadType.self, forKey: .type) {
                case .pauseSpeech:
                    self = .pauseSpeech
                case .continueSpeech:
                    self = .continueSpeech
                case .cancelSpeech:
                    self = .cancelSpeech
                case .sound:
                    self = .sound(try values.decode([String].self, forKey: .names),
                                  try values.decode([Int].self, forKey: .counts),
                                  try values.decode([TimeInterval].self, forKey: .cadences))
                case .speech:
                    self = .speech(try values.decode(String.self, forKey: .speech))
                }
            }
        }
        public var payloads: [Payload]
        public init(options: Options,
                    identifier: String,
                    payloads: [Payload]) {
            self.options = options
            self.identifier = identifier
            self.payloads = payloads
        }
    }
    public init() {
        
    }
    private var sync = DispatchQueue(label: "Output.sync",
                                     qos: .userInitiated,
                                     attributes: [],
                                     autoreleaseFrequency: .workItem,
                                     target: .global())
    private class NamedOutputQueue : NSObject, NSSpeechSynthesizerDelegate {
        private let synthesizer = NSSpeechSynthesizer()
        private let identifier: String
        private let queue: DispatchQueue
        private var soundCache = [String:CompoundSound]()
        init(identifier: String) {
            self.identifier = identifier
            queue = DispatchQueue(label: "Output.\(identifier)",
                                  qos: .userInitiated,
                                  attributes: [],
                                  autoreleaseFrequency: .workItem,
                                  target: .global())
            synthesizer.rate = 300.0
            super.init()
            synthesizer.delegate = self
        }
        func submit(job: Job) {
            queue.async {
                for payload in job.payloads {
                    switch payload {
                    case .cancelSpeech:
                        self.synthesizer.stopSpeaking()
                    case .continueSpeech:
                        self.synthesizer.continueSpeaking()
                    case .pauseSpeech:
                        self.synthesizer.pauseSpeaking(at: .wordBoundary)
                    case .sound(let names, let counts, let cadences):
                        self.sound(names: names,
                                   counts: counts,
                                   cadences: cadences,
                                   options: job.options)
                    case .speech(let value):
                        self.speech(value: value,
                                    options: job.options)
                    }
                }
            }
        }
        private func sound(names: [String],
                           counts: [Int],
                           cadences: [TimeInterval],
                           options: Options) {
            if options.contains(.interrupt) {
                for sound in soundCache.values {
                    sound.stop()
                }
            }
            for ((name, count), cadence) in zip(zip(names, counts), cadences) {
                let sound: CompoundSound
                if let cachedSound = soundCache[name] {
                    sound = cachedSound
                } else {
                    guard let newSound = CompoundSound(resourceName: name, extension: "wav") else {
                        return
                    }
                    newSound.volume = 0.7
                    sound = newSound
                    soundCache[name] = newSound
                }
                try? sound.play(count: count,
                                cadence: cadence)
            }
        }
        private func speech(value: String, options: Options) {
            if options.contains(.interrupt) {
                synthesizer.stopSpeaking()
            }
            synthesizer.startSpeaking(performSubstitutions(value: value))
        }
        private static let substitutions: [Substitutions] = {
            return [
                AbbreviationExpansion(),
                PunctuationExpansion(),
            ]
        }()
        private func performSubstitutions(value: String) -> String {
            var value = value
            for substitution in NamedOutputQueue.substitutions {
                value = substitution.perform(value)
            }
            return value
        }
        #if false
        public func speechSynthesizer(_ sender: NSSpeechSynthesizer,
                                      didFinishSpeaking finishedSpeaking: Bool) {
            
        }
        public func speechSynthesizer(_ sender: NSSpeechSynthesizer,
                                      willSpeakWord characterRange: NSRange,
                                      of string: String) {
            
        }
        public func speechSynthesizer(_ sender: NSSpeechSynthesizer,
                                      willSpeakPhoneme phonemeOpcode: Int16) {
            
        }
        public func speechSynthesizer(_ sender: NSSpeechSynthesizer,
                                      didEncounterErrorAt characterIndex: Int,
                                      of string: String,
                                      message: String) {
            
        }
        public func speechSynthesizer(_ sender: NSSpeechSynthesizer,
                                      didEncounterSyncMessage message: String) {
            
        }
        #endif
    }
    private var queues = [String:NamedOutputQueue]()
    public func submit(job: Job) {
        let queue = sync.sync { () -> NamedOutputQueue in
            if let queue = queues[job.identifier] {
                return queue
            }
            let queue = NamedOutputQueue(identifier: job.identifier)
            queues[job.identifier] = queue
            return queue
        }
        queue.submit(job: job)
    }
}
