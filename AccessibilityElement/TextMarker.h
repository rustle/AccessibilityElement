//
//  TextMarker.h
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

#import <Foundation/Foundation.h>

CFTypeRef __nullable accessibility_element_create_marker_range(CFTypeRef __nonnull start_marker, CFTypeRef __nonnull end_marker);
CFTypeRef __nullable accessibility_element_create_marker(NSData * __nonnull data);
CFTypeRef __nullable accessibility_element_copy_start_marker(CFTypeRef __nonnull range);
CFTypeRef __nullable accessibility_element_copy_end_marker(CFTypeRef __nonnull range);
CFTypeID accessibility_element_get_marker_type_id(void);
CFTypeID accessibility_element_get_marker_range_type_id(void);
