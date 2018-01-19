//
//  TextMarker.m
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

#import "TextMarker.h"
#import <dlfcn.h>

typedef CFTypeRef AXTextMarkerRangeRef;
typedef CFTypeRef AXTextMarkerRef;

CFTypeRef accessibility_element_create_marker_range(CFTypeRef startMarker, CFTypeRef endMarker)
{
    static AXTextMarkerRangeRef (*TextMarkerRangeCreate)(CFAllocatorRef, AXTextMarkerRef startMarker, AXTextMarkerRef endMarker) = NULL;
    static bool initialized = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TextMarkerRangeCreate = dlsym(RTLD_DEFAULT, "AXTextMarkerRangeCreate");
        initialized = (TextMarkerRangeCreate != NULL);
    });
    if (!initialized)
    {
        return NULL;
    }
    return TextMarkerRangeCreate(kCFAllocatorDefault, startMarker, endMarker);
}

CFTypeRef accessibility_element_create_marker(NSData *data)
{
    static AXTextMarkerRef (*TextMarkerCreate)(CFAllocatorRef, const uint8_t* bytes, CFIndex length) = NULL;
    static bool initialized = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TextMarkerCreate = dlsym(RTLD_DEFAULT, "AXTextMarkerCreate");
        initialized = (TextMarkerCreate != NULL);
    });
    if (!initialized)
    {
        return NULL;
    }
    return TextMarkerCreate(kCFAllocatorDefault, data.bytes, data.length);
}

CFTypeRef accessibility_element_copy_start_marker(CFTypeRef range)
{
    static AXTextMarkerRef (*TextMarkerRangeCopyStartMarker)(AXTextMarkerRangeRef) = NULL;
    static bool initialized = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TextMarkerRangeCopyStartMarker = dlsym(RTLD_DEFAULT, "AXTextMarkerRangeCopyStartMarker");
        initialized = (TextMarkerRangeCopyStartMarker != NULL);
    });
    if (!initialized)
    {
        return NULL;
    }
    return TextMarkerRangeCopyStartMarker(range);
}

CFTypeRef accessibility_element_copy_end_marker(CFTypeRef range)
{
    static AXTextMarkerRef (*TextMarkerRangeCopyEndMarker)(AXTextMarkerRangeRef) = NULL;
    static bool initialized = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TextMarkerRangeCopyEndMarker = dlsym(RTLD_DEFAULT, "AXTextMarkerRangeCopyEndMarker");
        initialized = (TextMarkerRangeCopyEndMarker != NULL);
    });
    if (!initialized)
    {
        return NULL;
    }
    return TextMarkerRangeCopyEndMarker(range);
}

CFTypeID accessibility_element_get_marker_type_id(void)
{
    static CFTypeID (*TextMarkerGetTypeID)(void) = NULL;
    static bool initialized = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TextMarkerGetTypeID = dlsym(RTLD_DEFAULT, "AXTextMarkerGetTypeID");
        initialized = (TextMarkerGetTypeID != NULL);
    });
    if (!initialized)
    {
        return 0;
    }
    return TextMarkerGetTypeID();
}

CFTypeID accessibility_element_get_marker_range_type_id(void)
{
    static CFTypeID (*TextMarkerRangeGetTypeID)(void) = NULL;
    static bool initialized = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TextMarkerRangeGetTypeID = dlsym(RTLD_DEFAULT, "AXTextMarkerRangeGetTypeID");
        initialized = (TextMarkerRangeGetTypeID != NULL);
    });
    if (!initialized)
    {
        return 0;
    }
    return TextMarkerRangeGetTypeID();
}
