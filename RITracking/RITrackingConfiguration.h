//
//  RITrackingProperties.h
//  RITracking
//
//  Created by Martin Biermann on 14/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RITrackingConfiguration : NSObject

+ (id)valueForKey:(NSString *)key;

+ (BOOL)loadFromPropertyListAtPath:(NSString *)path;

@end
