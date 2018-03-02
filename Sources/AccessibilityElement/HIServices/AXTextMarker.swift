//
//  AXTextMarker.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Cocoa
import Darwin

fileprivate class _TextMarker {
    typealias TextMarkerRangeCreate = @convention(c) (CFAllocator?, AXTextMarker, AXTextMarker) -> Unmanaged<AXTextMarkerRange>
    private static var RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)!
    static var textMarkerRange: TextMarkerRangeCreate = {
        let symbol = dlsym(RTLD_DEFAULT, "AXTextMarkerRangeCreate")
        return unsafeBitCast(symbol, to: TextMarkerRangeCreate.self)
    }()
    typealias TextMarkerCreate = @convention(c) (CFAllocator?, UnsafeRawPointer) -> Unmanaged<AXTextMarkerRange>
    static var textMarker: TextMarkerCreate = {
        let symbol = dlsym(RTLD_DEFAULT, "AXTextMarkerCreate")
        return unsafeBitCast(symbol, to: TextMarkerCreate.self)
    }()
    typealias TextMarkerGetTypeID = @convention(c) () -> CFTypeID
    static var textMarkerTypeID: CFTypeID = {
        let symbol = dlsym(RTLD_DEFAULT, "AXTextMarkerGetTypeID")
        let typeID = unsafeBitCast(symbol, to: TextMarkerGetTypeID.self)
        return typeID()
    }()
    static var textMarkerRangeTypeID: CFTypeID = {
        let symbol = dlsym(RTLD_DEFAULT, "AXTextMarkerRangeGetTypeID")
        let typeID = unsafeBitCast(symbol, to: TextMarkerGetTypeID.self)
        return typeID()
    }()
    typealias TextMarkerRangeCopyMarker = @convention(c) (AXTextMarkerRange) -> Unmanaged<AXTextMarker>
    static var textMarkerRangeCopyStartMarker: TextMarkerRangeCopyMarker = {
        let symbol = dlsym(RTLD_DEFAULT, "AXTextMarkerRangeCopyStartMarker")
        return unsafeBitCast(symbol, to: TextMarkerRangeCopyMarker.self)
    }()
    static var textMarkerRangeCopyEndMarker: TextMarkerRangeCopyMarker = {
        let symbol = dlsym(RTLD_DEFAULT, "AXTextMarkerRangeCopyEndMarker")
        return unsafeBitCast(symbol, to: TextMarkerRangeCopyMarker.self)
    }()
}

func accessibility_element_create_marker_range(_ start_marker: AXTextMarker, _ end_marker: AXTextMarker) -> AXTextMarkerRange {
    return _TextMarker.textMarkerRange(nil, start_marker, end_marker).takeRetainedValue()
}

func accessibility_element_create_marker(_ data: Data) -> AXTextMarker {
    var data = data
    return withUnsafeBytes(of: &data) { buffer in
        return _TextMarker.textMarker(nil, buffer.baseAddress!).takeRetainedValue()
    }
}

func accessibility_element_get_marker_type_id() -> CFTypeID {
    return _TextMarker.textMarkerTypeID
}

func accessibility_element_get_marker_range_type_id() -> CFTypeID {
    return _TextMarker.textMarkerRangeTypeID
}

func accessibility_element_copy_start_marker(_ range: AXTextMarkerRange) -> AXTextMarker {
    return _TextMarker.textMarkerRangeCopyStartMarker(range).takeRetainedValue()
}

func accessibility_element_copy_end_marker(_ range: AXTextMarkerRange) -> AXTextMarker {
    return _TextMarker.textMarkerRangeCopyEndMarker(range).takeRetainedValue()
}
