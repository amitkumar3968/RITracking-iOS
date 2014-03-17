//
//  RITracking.m
//  RITracking
//
//  Created by Martin Biermann on 10/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

#import "RITracking.h"
#import "RIGoogleAnalyticsTracker.h"
#import "RIBugSenseTracker.h"
#import "RIOpenURLHandler.h"

@interface RITracking ()

@property NSArray *trackers;
@property NSMutableArray *handlers;

@end

@implementation RITracking

static RITracking *sharedInstance;
static dispatch_once_t sharedInstanceToken;

+ (instancetype)sharedInstance
{
    dispatch_once(&sharedInstanceToken, ^{
        sharedInstance = [[RITracking alloc] init];
    });
    return sharedInstance;
}

- (instancetype)initWithTrackers:(NSArray *)trackers
{
    if ((self = [super init])) {
        self.handlers = [NSMutableArray array];
    }
    return self;
}

- (void)setDebug:(BOOL)debug
{
    _debug = debug;
    NSLog(@"RITracking: Debug mode %@", debug ? @"ON" : @"OFF");
}

- (void)startWithConfigurationFromPropertyListAtPath:(NSString *)path
                                       launchOptions:(NSDictionary *)launchOptions
{
    RIDebugLog(@"Starting initialisation with launch options '%@' and property list at path '%@'",
               launchOptions, path);
    BOOL loaded = [RITrackingConfiguration loadFromPropertyListAtPath:path];
    if (!loaded) {
        RIRaiseError(@"Unexpected error occurred when loading tracking configuration from property "
                     @"list file at path '%@'", path);
        return;
    }
    
    RIGoogleAnalyticsTracker *googleAnalyticsTracker = [[RIGoogleAnalyticsTracker alloc] init];
    RIBugSenseTracker *bugsenseTracker = [[RIBugSenseTracker alloc] init];
    self.trackers = @[googleAnalyticsTracker, bugsenseTracker];
    
    for (id tracker in self.trackers) {
        [((id<RITracker>)tracker).queue addOperationWithBlock:^{
            [(id<RITracker>)tracker applicationDidLaunchWithOptions:launchOptions];
        }];
    }
}

#pragma mark - RIEventTracking protocol

- (void)trackEvent:(NSString *)event withInfo:(NSDictionary *)info
{
    RIDebugLog(@"Tracking event '%@' with info '%@'", event, info);
    if (!self.trackers) {
        RIRaiseError(@"Invalid call with non-existent trackers. Initialisation may have failed.");
        return;
    }
    for (id tracker in self.trackers) {
        if ([tracker conformsToProtocol:@protocol(RIEventTracking)]) {
            [((id<RITracker>)tracker).queue addOperationWithBlock:^{
                [(id<RIEventTracking>)tracker trackEvent:event withInfo:info];
            }];
        }
    }
}

#pragma mark - RIExceptionTracking protocol

- (void)trackExceptionWithName:(NSString *)name
{
    RIDebugLog(@"Tracking exception with name '%@'", name);
    if (!self.trackers) {
        RIRaiseError(@"Invalid call with non-existent trackers. Initialisation may have failed.");
        return;
    }
    for (id tracker in self.trackers) {
        if ([tracker conformsToProtocol:@protocol(RIExceptionTracking)]) {
            [((id<RITracker>)tracker).queue addOperationWithBlock:^{
                [(id<RIExceptionTracking>)tracker trackExceptionWithName:name];
            }];
        }
    }
}

#pragma mark - RIOpenURLTracking protocol

- (void)registerHandler:(void (^)(NSDictionary *))handlerBlock forOpenURLPattern:(NSString *)pattern
{
    RIDebugLog(@"Registering handler for deeplink URL match pattern '%@'", pattern);
    NSError *error;
    NSArray *matches;
    NSMutableArray *macros = [NSMutableArray array];
    while (YES) {
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"\\{([^\\}]+)\\}"
                                      options:0
                                      error:&error];
        if (error) {
            RIRaiseError(@"Unexpected error when registering open URL handler "
                         @"for pattern '%@': %@", pattern, error);
            return;
        }
        
        matches = [regex matchesInString:pattern
                                 options:0
                                   range:NSMakeRange(0, pattern.length)];
        if (0 == matches.count) break;
        NSRange macroRange = [matches[0] rangeAtIndex:1];
        NSRange range = [matches[0] rangeAtIndex:0];
        NSString *macro = [pattern substringWithRange:macroRange];
        [macros addObject:macro];
        pattern = [pattern stringByReplacingCharactersInRange:range withString:@"(.*)"];
    }
    RIDebugLog(@"Deeplink handler pattern captures macros '%@'", macros);
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:&error];
    if (error) {
        RIRaiseError(@"Unexpected error when creating regular expression with pattern '%@'",
                     pattern);
        return;
    }
    
    RIOpenURLHandler *handler = [[RIOpenURLHandler alloc] initWithHandlerBlock:handlerBlock
                                                                         regex:regex
                                                                        macros:macros];
    [self.handlers addObject:handler];
}

- (void)trackOpenURL:(NSURL *)url
{
    RIDebugLog(@"Tracking deepling with URL '%@'", url);
    if (!self.trackers) {
        RIRaiseError(@"Invalid call with non-existent trackers. Tracking initialisation was either "
                     @"missing or has probably failed.");
        return;
    }
    for (RIOpenURLHandler *handler in self.handlers) {
        [handler handleOpenURL:url];
    }
    
    for (id tracker in self.trackers) {
        if ([tracker conformsToProtocol:@protocol(RIOpenURLTracking)]) {
            [((id<RITracker>)tracker).queue addOperationWithBlock:^{
                [(id<RIOpenURLTracking>)tracker trackOpenURL:url];
            }];
        }
    }
}

#pragma mark - Hidden test helpers

+ (void)reset
{
    sharedInstance = nil;
    sharedInstanceToken = 0;
}

@end
