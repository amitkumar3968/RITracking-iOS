//
//  RIAppDelegate.m
//  RITracking
//
//  Created by Martin Biermann on 10/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

#import "RIAppDelegate.h"

@implementation RIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [RITracking sharedInstance].debug = YES;
    
    NSString *trackingConfigFilePath = [[NSBundle mainBundle] pathForResource:@"RITracking_example"
                                                                       ofType:@"plist"];
    
    [[RITracking sharedInstance] startWithConfigurationFromPropertyListAtPath:trackingConfigFilePath
                                                                launchOptions:launchOptions];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    [[RITracking sharedInstance] trackOpenURL:url];
    return YES;
}

@end
