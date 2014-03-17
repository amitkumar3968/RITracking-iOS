//
//  RIAppDelegateTests.m
//  RITracking
//
//  Created by Martin Biermann on 10/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RIAppDelegate.h"
#import <OCMock/OCMock.h>

NSString *kOpenURL = @"http://rocket-internet.de";
NSString *kSourceApp = @"foobar";

@interface RIAppDelegateTests : XCTestCase

@property RIAppDelegate *appDelegate;

@end

@implementation RIAppDelegateTests

- (void)setUp
{
    [super setUp];
    self.appDelegate = [[RIAppDelegate alloc] init];
}

- (void)tearDown
{
    self.appDelegate = nil;
    [super tearDown];
}

- (void)testAppDelegateOnHandleURLCallsTrackerProxy
{
//    UIApplication *app = [OCMockObject mockForClass:UIApplication.class];
//    NSURL *url = [NSURL URLWithString:kOpenURL];
//    id originalTracking = self.appDelegate.tracking;
//    id tracking = [OCMockObject mockForProtocol:@protocol(RITrackingProtocol)];
//    [[[tracking stub] andReturn:@YES] applicationShouldOpenForURL:url];
//    [[tracking expect] applicationShouldOpenForURL:url];
//    self.appDelegate.tracking = tracking;
//    [self.appDelegate application:app openURL:url sourceApplication:kSourceApp annotation:nil];
//    [(OCMockObject *)tracking verify];
//    self.appDelegate.tracking = originalTracking;
}

@end
