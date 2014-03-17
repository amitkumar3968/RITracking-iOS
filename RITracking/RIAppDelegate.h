//
//  RIAppDelegate.h
//  RITracking
//
//  Created by Martin Biermann on 10/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

#import <UIKit/UIKit.h>

/** The RIAppDelegate class provides an application delegate with preset tracking of user sessions 
 and deeplinks.
 
 This class should be inherited by custom application delegates.
 */
@interface RIAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
