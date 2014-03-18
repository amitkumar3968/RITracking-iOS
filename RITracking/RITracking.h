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

/**
 *  A method to track the display of a screen view to the user, given its name
 *
 *  @param NSString The screen's name.
 */
- (void)trackScreenWithName:(NSString *)name;

@end

@protocol RIExceptionTracking <NSObject>

/**
 *  A method to track an exception, given its name
 *
 *  @param NSString The exception that happed.
 */
- (void)trackExceptionWithName:(NSString *)name;

@end

@protocol RIOpenURLTracking <NSObject>

/**
 *  This method is implemented by the RIOpenURLTracking protocol and allow to track information
 *  about an open URL.
 *
 *  @param NSURL The URL opened.
 */
- (void)trackOpenURL:(NSURL *)url;

@optional

/** 
 *  Register a handler block to be called when the given pattern matches a deeplink URL.
 *
 *  The deepling URL pattern may contain capture directives of the format `{<name>}` where '<name>'
 *  is replaced with the actual property name to access the captured information.
 *  The handler block receives a dictionary hash containing key-value properties obtained from pattern
 *  capture directives and from the query string of the deeplink URL.
 *
 *  @param (void(^)(NSDictionary *)) A handler to be called on matching a deeplink URL.
 *  @param NSString A pattern of regex extended with capture directive syntax.
 */
- (void)registerHandler:(void(^)(NSDictionary *))handler forOpenURLPattern:(NSString *)pattern;

@end

@protocol RIEventTracking <NSObject>

/**
 * A method to track an event happening inside the application.
 *
 * The event may be triggered by the user and further information, such as category, action and
 * value are available.
 *
 * @param NSString Name of the event
 * @param NSNumber (optional) The value of the action
 * @param NSString (optional) An identifier for the user action
 * @param NSString (optional) An identifier for the category of the app the user is in
 * @param NSDictionary (optional) Additional data about the event
 */
- (void)trackEvent:(NSString *)event
             value:(NSNumber *)value
            action:(NSString *)action
          category:(NSString *)category
              data:(NSDictionary *)data;

@end

@interface RITrackingProduct : NSObject

@property NSString *identifier;
@property NSString *name;
@property NSNumber *quantity;
@property NSNumber *price;
@property NSString *currency;
@property NSString *category;

@end

@interface RITrackingTotal : NSObject

@property NSNumber *net;
@property NSNumber *tax;
@property NSNumber *shipping;
@property NSString *currency;

@end

@protocol RIEcommerceEventTracking <NSObject>

/**
 * The implementation to this protocol should maintain a state machine to collect cart information.
 * Adding/Removing to/from cart is forwarded to Ad-X and A4S (http://goo.gl/iSjKut) instantly.
 * A4S (http://goo.gl/iSjKut) and GA (http://goo.gl/k6iRRC) receive information on checkout.
 */

/**
 * This method with include any previous calls to trackAddToCartForProductWithID and trackRemoveFromCartForProductWithID.
 */
- (void)trackCheckoutWithTransactionId:(NSString *)id total:(RITrackingTotal *)total;

- (void)trackProductAddToCart:(RITrackingProduct *)product;

- (void)trackRemoveFromCartForProductWithID:(NSString *)id quantity:(NSNumber *)quantity;

@end

@protocol RITracker <NSObject>

/**
 *  The operation queue.
 */
@property NSOperationQueue *queue;

/**
 *  Lanched app with options
 *
 *  @param NSString The event's name.
 *  @param NSDictionary The launching options.
 */
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
 *  A flag to enable debug logging.
 */
@property (nonatomic) BOOL debug;

/**
 *  Load the configuration needed from a plist file in the given path and launching options
 *
 *  @param NSString Path to the configuration file (plist file).
 *  @param NSDictionary The launching options.
 */
- (void)startWithConfigurationFromPropertyListAtPath:(NSString *)path
                                       launchOptions:(NSDictionary *)launchOptions;

/**
 *  Creates and initializes an `RITracking`object
 *
 *  @return The newly-initialized object
 */
+ (instancetype)sharedInstance;

@end
