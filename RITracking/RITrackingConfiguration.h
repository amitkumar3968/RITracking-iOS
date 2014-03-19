//
//  RITrackingProperties.h
//  RITracking
//
//  Created by Martin Biermann on 14/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  RITrackingConfiguration has the configuration for RITracking
 */
@interface RITrackingConfiguration : NSObject

/**
 *  Searchs a value for a given key and return that value
 *
 *  @param key The key to search
 *
 *  @return Returns the value for the given key
 */
+ (id)valueForKey:(NSString *)key;

/**
 *  Loads a property list located in the given path
 *
 *  @param path The path where is the configuration file
 *
 *  @return True in case of sucess, false in case of error
 */
+ (BOOL)loadFromPropertyListAtPath:(NSString *)path;

@end
