//
//  Output.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa

public class Output {
    public struct Options: OptionSet, Codable {
        public let rawValue: Int
        public static let interrupt = Options(rawValue: 1 << 0)
        public static let punctuation = Options(rawValue: 1 << 1)
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    public struct Job: Codable {
        public var options: Options
        public var identifier: String
        public enum Payload: Codable {
            private enum PayloadType: Int, Codable {
                case pauseSpeech
                case continueSpeech
                case cancelSpeech
                case speech
                case sound
            }
            private enum PayloadCodingKeys: String, CodingKey {
                case type = "a"
                case speech = "b"
                case options = "c"
                case names = "d"
                case counts = "e"
                case cadences = "f"
            }
            case pauseSpeech
            case continueSpeech
            case cancelSpeech
            case speech(String, Options?)
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
                case .speech(let value, let options):
                    try container.encode(PayloadType.speech, forKey: .type)
                    try container.encode(value, forKey: .speech)
                    try container.encodeIfPresent(options?.rawValue, forKey: .options)
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
                    let options: Options?
                    if let rawValue = try values.decodeIfPresent(Int.self, forKey: .options) {
                        options = Options(rawValue: rawValue)
                    } else {
                        options = nil
                    }
                    self = .speech(try values.decode(String.self, forKey: .speech), options)
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
    private class NamedOutputQueue: NSObject, NSSpeechSynthesizerDelegate {
        private let synthesizer = NSSpeechSynthesizer()
        private let identifier: String
        private let queue: CancellableQueue
        private var soundCache = [String:CompoundSound]()
        init(identifier: String) {
            self.identifier = identifier
            queue = CancellableQueue(label: "Output.\(identifier)")
            synthesizer.rate = 300.0
            super.init()
            synthesizer.delegate = self
        }
        func cancelSpeech() {
            queue.cancelAll()
            synthesizer.stopSpeaking()
        }
        func submit(job: Job) {
            if job.options.contains(.interrupt) {
                queue.cancelAll()
                synthesizer.stopSpeaking()
            }
            queue.async {
                for payload in job.payloads {
                    if $0.isCancelled {
                        break
                    }
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
                    case .speech(let value, let options):
                        self.speech(value: value,
                                    options: options ?? job.options)
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
                    newSound.volume = 0.4
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
            synthesizer.startSpeaking(performSubstitutions(value: value, options: options))
        }
        private func substitutions(options: Options) -> [Substitutions] {
            var substitutions = [Substitutions]()
            if options.contains(.punctuation) {
                substitutions.append(PunctuationExpansion())
            }
            return substitutions
        }
        private func performSubstitutions(value: String, options: Options) -> String {
            var value = value
            for substitution in substitutions(options: options) {
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
        let cancel = job.options.contains(.interrupt)
        let queue = sync.sync { () -> NamedOutputQueue in
            if cancel {
                for queue in queues.values {
                    queue.cancelSpeech()
                }
            }
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
