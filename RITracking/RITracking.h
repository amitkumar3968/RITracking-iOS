//
//  RITracking.h
//  RITracking
//
//  Created by Martin Biermann on 10/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

#ifdef DEBUG
#define RIRaiseError(fmt, ...) \
NSAssert(NO, @"%@", [NSString stringWithFormat:(fmt), ##__VA_ARGS__]); \
NSLog((@"Func: %s, Line: %d, %@"), __PRETTY_FUNCTION__, __LINE__, \
[NSString stringWithFormat:(fmt), ##__VA_ARGS__]);
#else
#define RIRaiseError(fmt, ...) \
NSLog((@"Func: %s, Line: %d, %@"), __PRETTY_FUNCTION__, __LINE__, \
[NSString stringWithFormat:(fmt), ##__VA_ARGS__]);
#endif

#ifdef DEBUG
#define RIDebugLog(fmt, ...) \
if ([RITracking sharedInstance].debug) NSLog(@"RITracking: %@",[NSString stringWithFormat:(fmt), ##__VA_ARGS__]);
#else
#define RIDebugLog(fmt, ...) return;
#endif

#import <Foundation/Foundation.h>
#import "RITrackingConfiguration.h"

@protocol RIScreenTracking <NSObject>

- (void)trackScreenWithName:(NSString *)name;

@end

@protocol RIExceptionTracking <NSObject>

- (void)trackExceptionWithName:(NSString *)name;

@end

@protocol RIOpenURLTracking <NSObject>

/**
 
 */
- (void)trackOpenURL:(NSURL *)url;

@optional
/** Register a handler block to be called when the given pattern matches a deeplink URL. 
 
 The deepling URL pattern may contain capture directives of the format `{<name>}` where '<name>' 
 is replaced with the actual property name to access the captured information. 
 The handler block receives a dictionary hash containing key-value properties obtained from pattern
 capture directives and from the query string of the deeplink URL.
 
 @param (void(^)(NSDictionary *)) A handler to be called on matching a deeplink URL.
 @param NSString A pattern of regex extended with capture directive syntax.
 */
- (void)registerHandler:(void(^)(NSDictionary *))handler forOpenURLPattern:(NSString *)pattern;

@end

@protocol RIEventTracking <NSObject>

- (void)trackEvent:(NSString *)event withInfo:(NSDictionary *)info;

@end

@protocol RITracker <NSObject>

@property NSOperationQueue *queue;

- (void)applicationDidLaunchWithOptions:(NSDictionary *)options;

@end

@interface RITracking : NSObject
<
    RIEventTracking,
    RIScreenTracking,
    RIExceptionTracking,
    RIOpenURLTracking
>

/** 
 A flag to enable debug logging.
 */
@property (nonatomic) BOOL debug;

- (void)startWithConfigurationFromPropertyListAtPath:(NSString *)path
                                       launchOptions:(NSDictionary *)launchOptions;

+ (instancetype)sharedInstance;

@end
