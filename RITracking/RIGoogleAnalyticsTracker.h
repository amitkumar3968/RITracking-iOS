//
//  RIGoogleAnalyticsTracker.h
//  RITracking
//
//  Created by Martin Biermann on 13/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RITracking.h"

extern NSString * const kRIGoogleAnalyticsTrackingID;

@interface RIGoogleAnalyticsTracker : NSObject
<
    RITracker,
    RIEventTracking,
    RIExceptionTracking,
    RIScreenTracking
>

@end
