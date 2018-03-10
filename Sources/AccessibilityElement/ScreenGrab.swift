//
//  ScreenGrab.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

public struct ScreenGrab {
    private enum Error : Swift.Error {
        case unpackFailure
    }
    private static func unpack(processIdentifier: ProcessIdentifier, windowInfo: [String:Any]) throws -> CGRect {
        guard let pid = windowInfo[kCGWindowOwnerPID as String] as? ProcessIdentifier, pid == processIdentifier else {
            throw ScreenGrab.Error.unpackFailure
        }
        guard let frameDictionary = windowInfo[kCGWindowBounds as String] as? [String:Any] else {
            throw ScreenGrab.Error.unpackFailure
        }
        guard let frame = CGRect(dictionaryRepresentation: frameDictionary as CFDictionary) else {
            throw ScreenGrab.Error.unpackFailure
        }
        return frame
    }
    public static func windowID(element: Element) -> CGWindowID? {
        guard let window = try? element.topLevelElement(), window.isWindow else {
            return nil
        }
        guard let list = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String:Any]] else {
            return nil
        }
        let processIdentifier = element.processIdentifier
        guard processIdentifier > 0 else {
            return nil
        }
        guard let windowFrame = try? window.frame() else {
            return nil
        }
        let windowRect = CGRect(x: windowFrame.origin.x, y: windowFrame.origin.y, width: windowFrame.size.width, height: windowFrame.size.height)
        for windowInfo in list {
            do {
                let frame = try unpack(processIdentifier: processIdentifier, windowInfo: windowInfo)
                if frame == windowRect {
                    if let id = windowInfo[kCGWindowNumber as String] as? Int {
                        return CGWindowID(id)
                    }
                    return nil
                }
            } catch {
                continue
            }
        }
        return nil
    }
    let windowID: CGWindowID
    public init(windowID: CGWindowID) {
        self.windowID = windowID
    }
    public func grab(screenBounds: Frame) -> CGImage? {
        let rect = CGRect(x: CGFloat(screenBounds.origin.x),
                          y: CGFloat(screenBounds.origin.y),
                          width: CGFloat(screenBounds.size.width),
                          height: CGFloat(screenBounds.size.height))
        return CGWindowListCreateImage(rect, [.optionAll], windowID, CGWindowImageOption.bestResolution)
    }
}
