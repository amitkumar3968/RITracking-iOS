//
//  RIGoogleAnalyticsTracker.m
//  RITracking
//
//  Created by Martin Biermann on 13/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

// Requires Frameworks:
//
// libGoogleAnalyticsServices.a
// AdSupport.framework
// CoreData.framework
// SystemConfiguration.framework
// libz.dylib

#import "RIGoogleAnalyticsTracker.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAILogger.h"

NSString * const kRIGoogleAnalyticsTrackingID = @"RIGoogleAnalyticsTrackingID";

@implementation RIGoogleAnalyticsTracker

@synthesize queue;

- (id)init
{
    RIDebugLog(@"Initializing Google Analytics tracker");
    
    if ((self = [super init])) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

#pragma mark - RITracker protocol

- (void)applicationDidLaunchWithOptions:(NSDictionary *)options
{
    RIDebugLog(@"Google Analytics tracker tracks application launch");
    
    NSString *trackingId = [RITrackingConfiguration valueForKey:kRIGoogleAnalyticsTrackingID];
    
    if (!trackingId) {
        RIRaiseError(@"Missing Google Analytics Tracking ID in tracking properties");
        return;
    }
    
    // Automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Dispatch tracking information every 5 seconds (default: 120)
    [GAI sharedInstance].dispatchInterval = 5;
    
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:trackingId];
    
    NSLog(@"Initialized Google Analytics %d", [GAI sharedInstance].trackUncaughtExceptions);
}

#pragma mark - RIExceptionTracking protocol

- (void)trackExceptionWithName:(NSString *)name
{
    RIDebugLog(@"Google Analytics tracker tracks exception with name '%@'", name);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (!tracker) {
        RIRaiseError(@"Missing default Google Analytics tracker");
        return;
    }
    
    NSDictionary *dict = [[GAIDictionaryBuilder createExceptionWithDescription:name
                                                                     withFatal:NO] build];
    
    [tracker send:dict];
}

#pragma mark - RIScreenTracking

-(void)trackScreenWithName:(NSString *)name
{
    RIDebugLog(@"Google Analytics - Tracking screen with name: %@", name);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (!tracker) {
        RIRaiseError(@"Missing default Google Analytics tracker");
        return;
    }
    
    [tracker set:kGAIScreenName value:name];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - RIEventTracking

-(void)trackEvent:(NSString *)event
            value:(NSNumber *)value
           action:(NSString *)action
         category:(NSString *)category
             data:(NSDictionary *)data
{
    RIDebugLog(@"Google Analytics - Tracking event: %@", event);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (!tracker) {
        RIRaiseError(@"Missing default Google Analytics tracker");
        return;
    }
    
    NSDictionary *dict = [[GAIDictionaryBuilder createEventWithCategory:category
                                                                 action:action
                                                                  label:event
                                                                  value:value] build];
    
    [tracker send:dict];
}

#pragma mark - RIEcommerceEventTracking

-(void)trackCheckoutWithTransactionId:(NSString *)idTransaction
                                total:(RITrackingTotal *)total
{
    RIDebugLog(@"Google Analytics - Tracking checkout with transaction id: %@", idTransaction);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (!tracker) {
        RIRaiseError(@"Missing default Google Analytics tracker");
        return;
    }
    
    NSDictionary *dict = [[GAIDictionaryBuilder createTransactionWithId:idTransaction
                                                            affiliation:nil
                                                                revenue:nil
                                                                    tax:total.tax
                                                               shipping:total.shipping
                                                           currencyCode:total.currency] build];
    
    [tracker send:dict];
}

-(void)trackProductAddToCart:(RITrackingProduct *)product
{

}

-(void)trackRemoveFromCartForProductWithID:(NSString *)idTransaction
                                  quantity:(NSNumber *)quantity
{
    
}

@end
