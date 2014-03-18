//
//  RITrackerProxyTests.m
//  RITracking
//
//  Created by Martin Biermann on 10/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "RITracking.h"
#import "RIGoogleAnalyticsTracker.h"
#import "RIBugSenseTracker.h"
#import "MBBlockSwizzle.h"
#import "XCTestCase+AsyncTesting.h"
#import <BugSense-iOS/BugSenseController.h>
#import "GAI.h"
#import "GAITracker.h"
#import <objc/message.h>

@interface RITracking ()

@property NSArray *trackers;

+ (void)reset;

@end

@interface RITrackingConfiguration ()

+ (void)clear;

@end

@interface RITrackingTests : XCTestCase

@end

@implementation RITrackingTests

NSString *kTestTrackingConfigurationPropertyListFilePath;
NSDictionary *kTestTrackingConfigurationPropertyListDictionary;

- (void)setUp
{
    [super setUp];
    
    // Make sure there is no configuration or interface active
    [RITrackingConfiguration clear];
    [RITracking reset];
    
    // Generate random values used during test
    kTestTrackingConfigurationPropertyListFilePath = [[NSUUID UUID] UUIDString];
    
    kTestTrackingConfigurationPropertyListDictionary = @{
        kRIBugsenseAPIKey: [[NSUUID UUID] UUIDString],
        kRIGoogleAnalyticsTrackingID: [[NSUUID UUID] UUIDString]
    };
    
    // Enable debug mode to log additional information during test
    [RITracking sharedInstance].debug = YES;
}

- (void)tearDown
{
    [RITrackingConfiguration clear];
    [RITracking reset];
    [super tearDown];
}

- (void)testTrackEvent
{
    NSString * const kEventCategory = [[NSUUID UUID] UUIDString];
    NSString * const kEventAction = [[NSUUID UUID] UUIDString];
    NSString * const kEventLabel = [[NSUUID UUID] UUIDString];
    NSString * const kEvent = [[NSUUID UUID] UUIDString];
    
    MBSwizzleWithBlockAndRun(@"NSDictionary",
                             @selector(dictionaryWithContentsOfFile:),
                             YES,
                             ^NSDictionary*(Class c, NSString *filePath)
                             {
                                 return kTestTrackingConfigurationPropertyListDictionary;
                             }, ^{
                                 [[RITracking sharedInstance] startWithConfigurationFromPropertyListAtPath:@"foo"
                                                                                             launchOptions:nil];
                                 
                                 NSDictionary *dic = @{@"category": kEventCategory,
                                                       @"action": kEventAction,
                                                       @"label" : kEventLabel};
                                 
                                 [[RITracking sharedInstance] trackEvent:kEvent withInfo:dic];
                             });
}

- (void)testTrackingStartWithTrackerInitialisation
{
    NSDictionary *launchOptions = @{@"foo": @"bar"};
    
    NSUInteger const kBugsenseCalled = 1 << 0;
    NSUInteger const kGoogleAnalyticsCalled = 1 << 1;
    __block NSUInteger called = 0;
    
    void(^revertSwizzleGAAppLaunch)() =
    MBSwizzleWithBlock(NSStringFromClass(RIGoogleAnalyticsTracker.class),
                       @selector(applicationDidLaunchWithOptions:),
                       NO,
                       ^(NSDictionary *launchOptions)
    {
        called = called|kGoogleAnalyticsCalled;
    });
    
    void(^revertSwizzleBugsenseAppLaunch)() =
    MBSwizzleWithBlock(NSStringFromClass(RIBugSenseTracker.class),
                       @selector(applicationDidLaunchWithOptions:),
                       NO,
                       ^(NSDictionary *launchOptions)
    {
        called = called|kBugsenseCalled;
    });
    
    MBSwizzleWithBlockAndRun(@"NSDictionary",
                             @selector(dictionaryWithContentsOfFile:),
                             YES,
                             ^NSDictionary*(Class class, NSString *filePath)
    {
        return [NSDictionary dictionary];
    }, ^{
        [[RITracking sharedInstance] startWithConfigurationFromPropertyListAtPath:[[NSBundle mainBundle] pathForResource:@"RITracking_example" ofType:@"plist"]
                                                                    launchOptions:launchOptions];
        
        NSAssert((0 != (called & kBugsenseCalled)) && (0 != (called & kGoogleAnalyticsCalled)),
                 @"Bugsense and Google Analytics trackers should be called to initialise");
        revertSwizzleGAAppLaunch();
        revertSwizzleBugsenseAppLaunch();
    });
}


- (void)testTrackingConfigurationLoadingFromPropertyListFile
{
    NSAssert([RITrackingConfiguration valueForKey:kRIGoogleAnalyticsTrackingID] == nil,
             @"Initial value of kRIGoogleAnalyticsTrackingID should be nil");
    NSAssert([RITrackingConfiguration valueForKey:kRIBugsenseAPIKey] == nil,
             @"Initial value of kRIBugsenseAPIKey should be nil");
    MBSwizzleWithBlockAndRun(@"NSDictionary",
                             @selector(dictionaryWithContentsOfFile:),
                             YES,
                             ^NSDictionary*(Class c, NSString *filePath)
    {
        if ([filePath isEqualToString:kTestTrackingConfigurationPropertyListFilePath]) {
            return kTestTrackingConfigurationPropertyListDictionary;
        }
        return nil;
    }, ^{
        [[RITracking sharedInstance]
         startWithConfigurationFromPropertyListAtPath:kTestTrackingConfigurationPropertyListFilePath
         launchOptions:nil];
        NSAssert([[RITrackingConfiguration valueForKey:kRIGoogleAnalyticsTrackingID]
                  isEqualToString:[kTestTrackingConfigurationPropertyListDictionary
                                   objectForKey:kRIGoogleAnalyticsTrackingID]],
                 @"Value of kRIGoogleAnalyticsTrackingID should equal mock value");
        NSAssert([[RITrackingConfiguration valueForKey:kRIBugsenseAPIKey]
                  isEqualToString:[kTestTrackingConfigurationPropertyListDictionary
                                   objectForKey:kRIBugsenseAPIKey]],
                 @"Initial value of kRIBugsenseAPIKey should equal mock value");
    });
}

- (void)testTrackException
{
    // Generate a random exception name
    NSString * const kExceptionName = [[NSUUID UUID] UUIDString];
    
    // Create some bitmap flags
    NSUInteger const kBugsenseCalled = 1 << 0;
    NSUInteger const kGoogleAnalyticsCalled = 1 << 1;
    __block NSUInteger called = 0;
    
    // Mock Bugsense controller to track being called
    MBSwizzleRevertBlock revertBugsense =
    MBSwizzleWithBlock(@"BugSenseController",
                       @selector(logException:withExtraData:),
                       YES,
                       ^BOOL(BugSenseController *ctrl,
                             NSException *exception,
                             NSDictionary *extraData)
    {
        called |= kBugsenseCalled;
        return YES;
    });
    
    // Mock original Google Analytics tracker to validate call of internal Google Analytics tracker
    id googleAnalyticsTrackerMock = [OCMockObject mockForProtocol:@protocol(GAITracker)];
    [[googleAnalyticsTrackerMock expect] send:[OCMArg checkWithBlock:^BOOL(NSDictionary *dict) {
        called |= kGoogleAnalyticsCalled;
        NSString *paramAssertMsg = @"Unexpected value of Google Analytics sending dictionary "
        @"parameter '%@'";
        NSAssert([dict[@"&exf"] isKindOfClass:NSNull.class], paramAssertMsg, @"&exf");
        NSAssert([dict[@"&t"] isEqualToString:@"exception"], paramAssertMsg, @"&t");
        NSAssert([dict[@"&exd"] isEqualToString:kExceptionName], paramAssertMsg, @"&exd");
        return YES;
    }]];
    // Mock Google Analytics interface to return mock tracker
    id googleAnalyticsAPIMock = [OCMockObject niceMockForClass:GAI.class];
    [[[googleAnalyticsAPIMock expect] andReturn:googleAnalyticsTrackerMock] defaultTracker];
    // Mock Google Analytics interface to return mock interface that returns mock tracker
    MBSwizzleRevertBlock revertGoogleAnalyticsTracker =
    MBSwizzleWithBlock(@"GAI", @selector(sharedInstance), YES, ^{
        return googleAnalyticsAPIMock;
    });
    
    // Mock the property list loading to return random configuration data
    MBSwizzleWithBlockAndRun(@"NSDictionary",
                             @selector(dictionaryWithContentsOfFile:),
                             YES,
                             ^NSDictionary*(Class class, NSString *filePath)
    {
        return kTestTrackingConfigurationPropertyListDictionary;
    }, ^{
        // Initialise tracking interface with test random configuration
        [[RITracking sharedInstance] startWithConfigurationFromPropertyListAtPath:@"foo"
                                                                    launchOptions:nil];
        // Trigger exceptin tracking with random exception name
        [[RITracking sharedInstance] trackExceptionWithName:kExceptionName];
        // Wait a second to wait for async exception tracking on Bugsense and Google Analytics
        [self waitForTimeout:2];
        // Verify both Bugsense and Google Analytics trackers got called to track exception
        NSAssert((0 != (called & kBugsenseCalled) && 0 != (called & kGoogleAnalyticsCalled)),
                 @"Bugsense and Google Analytics trackers should be called to log exception");
        // Revert swizzle mocks
        revertBugsense();
        revertGoogleAnalyticsTracker();
    });
}

- (void)testTrackingOnEvalOpenURLWithMatchCallsCorrespondingRegisteredHandler
{
    NSString * const kCountryCode = [[NSUUID UUID] UUIDString];
    NSString * const kCategory = [[NSUUID UUID] UUIDString];
    NSDictionary *queryParameters = @{
        [[NSUUID UUID] UUIDString]: [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString]: [[NSUUID UUID] UUIDString]
    };
    MBSwizzleWithBlockAndRun(@"NSDictionary",
                             @selector(dictionaryWithContentsOfFile:),
                             YES,
                             ^NSDictionary*(Class c, NSString *filePath)
    {
        return kTestTrackingConfigurationPropertyListDictionary;
    }, ^{
        [[RITracking sharedInstance] startWithConfigurationFromPropertyListAtPath:@"foo"
                                                                    launchOptions:nil];
        [[RITracking sharedInstance] registerHandler:^(NSDictionary *params) {
            NSMutableDictionary *expectedParams = [queryParameters mutableCopy];
            expectedParams[@"country"] = kCountryCode;
            expectedParams[@"category"] = kCategory;
            for (NSString *key in expectedParams) {
                NSAssert([params[key] isEqualToString:expectedParams[key]],
                         @"Expected %@ parameter to be captured from open URL", key);
            }
        } forOpenURLPattern:@".*/{country}/c/{category}\\.html.*"];
        [[RITracking sharedInstance] registerHandler:^(NSDictionary *params) {
            NSAssert(NO, @"Unexpected call of non-matching registered open URL handler");
        } forOpenURLPattern:[[NSUUID UUID] UUIDString]];
        NSString *urlString = [NSString stringWithFormat:
                               @"foobar://com.foobar/%@/c/%@.html?%@=%@&%@=%@",
                               kCountryCode,
                               kCategory,
                               queryParameters.allKeys[0],
                               queryParameters.allValues[0],
                               queryParameters.allKeys[1],
                               queryParameters.allValues[1]
                               ];
        [[RITracking sharedInstance] trackOpenURL:[NSURL URLWithString:urlString]];
    });
}

- (void)testTrackingOnEvalOpenURLWithoutQueryStringWithMatchCallsRegisteredHandler
{
    NSString * const kProductSKU = [[NSUUID UUID] UUIDString];
    NSString * const kCountryCode = [[NSUUID UUID] UUIDString];
    MBSwizzleWithBlockAndRun(@"NSDictionary",
                             @selector(dictionaryWithContentsOfFile:),
                             YES,
                             ^NSDictionary*(Class c, NSString *filePath)
    {
        return kTestTrackingConfigurationPropertyListDictionary;
    }, ^{
        [[RITracking sharedInstance] startWithConfigurationFromPropertyListAtPath:@"foo"
                                                                    launchOptions:nil];
        [[RITracking sharedInstance] registerHandler:^(NSDictionary *params) {
            NSLog(@"Parameters %@", params);
            NSAssert([params[@"country"] isEqualToString:kCountryCode], @"Expected country parameter "
                     @"to be captured from open URL");
            NSAssert([params[@"sku"] isEqualToString:kProductSKU], @"Expected sku parameter to be "
                     @"captured from open URL");
        } forOpenURLPattern:@".*/{country}/d/{sku}.*"];
        NSString *urlString =
        [NSString stringWithFormat:@"foobar://com.foobar/%@/d/%@", kCountryCode, kProductSKU];
        [[RITracking sharedInstance] trackOpenURL:[NSURL URLWithString:urlString]];
    });
}

- (void)testGoogleAnalyticsTrackerInitialization
{
    id trackerMock = [OCMockObject mockForProtocol:@protocol(GAITracker)];
    NSString * const kTestRIGoogleAnalyticsTrackingID = [[NSUUID UUID] UUIDString];
    void(^revertSwizzledTrackingConfig)() = MBSwizzleWithBlock(@"RITrackingConfiguration",
                                                         @selector(valueForKey:),
                                                         YES,
                                                         ^id(id config, NSString *key)
    {
        if ([key isEqualToString:kRIGoogleAnalyticsTrackingID]) {
            return kTestRIGoogleAnalyticsTrackingID;
        }
        return @"";
    });
    
    void(^revertSwizzledGAInstance)() =
    MBSwizzleWithBlock(@"GAI",
                       @selector(trackerWithTrackingId:),
                       NO,
                       ^id<GAITracker>(id gai, NSString *trackerId)
    {
        return trackerMock;
    });
    
    MBSwizzleWithBlockAndRun(@"NSDictionary",
                             @selector(dictionaryWithContentsOfFile:),
                             YES,
                             ^NSDictionary*(Class c, NSString *filePath)
    {
        return @{};
    }, ^{
        [[RITracking sharedInstance] startWithConfigurationFromPropertyListAtPath:[[NSBundle mainBundle] pathForResource:@"RITracking_example" ofType:@"plist"]
                                                                    launchOptions:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSAssert((BOOL)((GAI *)[GAI sharedInstance]).trackUncaughtExceptions, @"Google Analytics "
//                     @"tracker should be initialised to track uncaught exceptions");
//            NSAssert([GAI sharedInstance].dispatchInterval == 5, @"Google Analytics tracker"
//                     @"should be initialized with dispatch interval of 5 seconds");
            [self notify:XCTAsyncTestCaseStatusSucceeded];
            revertSwizzledTrackingConfig();
            revertSwizzledGAInstance();
        });
        
        [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:5];
    });
    
}

@end
