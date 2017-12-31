//
//  MonotonicCounter.m
//
//  Copyright © 2017 Doug Russell. All rights reserved.
//

#import "MonotonicCounter.h"
#import <stdatomic.h>

static atomic_int_fast64_t counter = ATOMIC_VAR_INIT(1234);
NSInteger monotonic_counter(void) {
    NSInteger const value = (NSInteger)atomic_fetch_add(&counter, 1);
    if (value < 0) {
        abort();
    }
    return value;
}
