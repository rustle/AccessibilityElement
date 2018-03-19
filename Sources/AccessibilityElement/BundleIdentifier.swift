//
//  BundleIdentifier.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct BundleIdentifier : RawRepresentable {
    public static let spotlight: BundleIdentifier = "com.apple.spotlight"
    public static let console: BundleIdentifier = "com.apple.console"
    public static let safari: BundleIdentifier = "com.apple.safari"
    public static let terminal: BundleIdentifier = "com.apple.terminal"
    public static let sublimeText3: BundleIdentifier = "com.sublimetext.3"
    public static let webkitDatabase: BundleIdentifier = "com.apple.webkit.databases"
    public static let webkitContent: BundleIdentifier = "com.apple.webkit.webcontent"
    public static let webkitNetworking: BundleIdentifier = "com.apple.webkit.networking"
    public static let lateragent: BundleIdentifier = "com.apple.lateragent"
    public static let loginWindow: BundleIdentifier = "com.apple.loginwindow"
    public static let viewBridgeAuxiliary: BundleIdentifier = "com.apple.viewbridgeauxiliary"
    public static let cloudphotosd: BundleIdentifier = "com.apple.cloudphotosd"
    public static let osdUIHelper: BundleIdentifier = "com.apple.osduihelper"
    public static let talAgent: BundleIdentifier = "com.apple.talagent"
    public static let coreservicesUIAgent: BundleIdentifier = "com.apple.coreservices.uiagent"
    public static let coreLocationAgent: BundleIdentifier = "com.apple.corelocationagent"
    public static let powerchime: BundleIdentifier = "com.apple.powerchime"
    public static let coreSimulatorService: BundleIdentifier = "com.apple.coresimulator.coresimulatorservice"
    public static let airplayUIAgent: BundleIdentifier = "com.apple.airplayuiagent"
    public static let storeUID: BundleIdentifier = "com.apple.storeuid"
    public static let pressAndHold: BundleIdentifier = "com.apple.pressandhold"
    public static let localAuthenticationUIAgent: BundleIdentifier = "com.apple.localauthentication.uiagent"
    public static let wifiAgent: BundleIdentifier = "com.apple.wifi.wifiagent"
    public static let nbAgent: BundleIdentifier = "com.apple.nbagent"
    public typealias RawValue = String
    public var rawValue: RawValue
    public init?(rawValue: RawValue) {
        self.init(value: rawValue)
    }
    public init(value: String) {
        self.rawValue = value.lowercased()
    }
}

extension BundleIdentifier : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: StringLiteralType) {
        self.init(value: value)
    }
}

extension BundleIdentifier : Hashable {
    public var hashValue: Int {
        return rawValue.hashValue
    }
    public static func ==(lhs: BundleIdentifier, rhs: BundleIdentifier) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    public static func ==(lhs: BundleIdentifier, rhs: String) -> Bool {
        return lhs.rawValue == rhs
    }
    public static func ==(lhs: String, rhs: BundleIdentifier) -> Bool {
        return lhs == rhs.rawValue
    }
}
