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

/**
 *  This protocol implements tracking to a given screen
 */
@protocol RIScreenTracking <NSObject>

/**
 *  Track the display of a presented screen view to the user, given its name
 *
 *  @param name The screen's name.
 */
- (void)trackScreenWithName:(NSString *)name;

@end

/**
 *  This protocol implements tracking to a exception that occurred
 */
@protocol RIExceptionTracking <NSObject>

/**
 *  Allow to track an exception, given its name
 *
 *  @param name The exception that happed.
 */
- (void)trackExceptionWithName:(NSString *)name;

@end

/**
 *  This protocol implements tracking to a open URL
 */
@protocol RIOpenURLTracking <NSObject>

/**
 *  Allow to tack an Open URL, given that URL
 *
 *  @param url The URL opened.
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
 *  @param handler A handler to be called on matching a deeplink URL.
 *  @param pattern A pattern of regex extended with capture directive syntax.
 */
- (void)registerHandler:(void(^)(NSDictionary *))handler forOpenURLPattern:(NSString *)pattern;

@end

/**
 *  This protocol implements tracking to an event
 */
@protocol RIEventTracking <NSObject>

/**
 * A method to track an event happening inside the application.
 *
 * The event may be triggered by the user and further information, such as category, action and
 * value are available.
 *
 * @param event Name of the event
 * @param value (optional) The value of the action
 * @param action (optional) An identifier for the user action
 * @param category (optional) An identifier for the category of the app the user is in
 * @param data (optional) Additional data about the event
 */
- (void)trackEvent:(NSString *)event
             value:(NSNumber *)value
            action:(NSString *)action
          category:(NSString *)category
              data:(NSDictionary *)data;

@end

/**
 *  Interface of the RITrackingProduct, that is the product used for the commerce tracking
 */
@interface RITrackingProduct : NSObject

/**
 *  Identifier of the product
 */
@property NSString *identifier;
/**
 *  Name of the product
 */
@property NSString *name;
/**
 *  Quantity of the product
 */
@property NSNumber *quantity;
/**
 *  Price of the product
 */
@property NSNumber *price;
/**
 *  Currency of the product price
 */
@property NSString *currency;
/**
 *  Category of the product
 */
@property NSString *category;

@end

/**
 *  Interface of the RITrackingTotal, used for the commerce tracking
 */
@interface RITrackingTotal : NSObject

/**
 *  Net of the order
 */
@property NSNumber *net;
/**
 *  Tax of the order
 */
@property NSNumber *tax;
/**
 *  Shipping price of the order
 */
@property NSNumber *shipping;
/**
 *  Currency of the order
 */
@property NSString *currency;

@end

/**
 *  This protocol implements tracking to the commerce transactions
 *
 *  The implementation to this protocol should maintain a state machine to collect cart information.
 *  Adding/Removing to/from cart is forwarded to Ad-X and A4S (http://goo.gl/iSjKut) instantly.
 *  A4S (http://goo.gl/iSjKut) and GA (http://goo.gl/k6iRRC) receive information on checkout.
 */
@protocol RIEcommerceEventTracking <NSObject>

/**
 *  This method with include any previous calls to trackAddToCartForProductWithID and
 *  trackRemoveFromCartForProductWithID.
 *
 *  @param idTrans The transaction ID
 *  @param total RITrackingProduct product
 */
- (void)trackCheckoutWithTransactionId:(NSString *)idTrans total:(RITrackingTotal *)total;

/**
 *  Track a product that was added to the cart
 *
 *  @param product The product added
 */
- (void)trackProductAddToCart:(RITrackingProduct *)product;

/**
 *  Track a product that was removed from the cart
 *
 *  @param idTrans The transaction ID
 *  @param quantity The quantity removed from the cart
 */
- (void)trackRemoveFromCartForProductWithID:(NSString *)idTrans quantity:(NSNumber *)quantity;

@end

/**
 *  RITracker protocol implements the initialization of the trackers
 */
@protocol RITracker <NSObject>

/**
 *  The operation queue.
 */
@property NSOperationQueue *queue;

/**
 *  Lanched app with options
 *
 *  @param options The launching options.
 */
- (void)applicationDidLaunchWithOptions:(NSDictionary *)options;

@end

/**
 *  Interface of the RITracking
 */
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
 *  @param path Path to the configuration file (plist file).
 *  @param launchOptions The launching options.
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
