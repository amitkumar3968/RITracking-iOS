//
//  RIBugSenseTracker.h
//  RITracking
//
//  Created by Martin Biermann on 13/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RITracking.h"

extern NSString * const kRIBugsenseAPIKey;

/**
 *  Convenience controller to proxy tracking information to BugSense
 */
@interface RIBugSenseTracker : NSObject
<
    RITracker,
    RIExceptionTracking
>

@end
