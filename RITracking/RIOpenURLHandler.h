//
//  RIOpenURLHandler.h
//  RITracking
//
//  Created by Martin Biermann on 15/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * RIOpenURLHandler allows to handle an Open URL (or deeplink)
 */
@interface RIOpenURLHandler : NSObject

/**
 *  Creat and initialize a `RIOpenURLHandler` object
 *
 *  @param handlerBlock A handler to be called on matching a deeplink URL.
 *  @param regex A regular expression to match.
 *  @param macros An array of macros.
 *
 *  @return The object created
 */
- (instancetype)initWithHandlerBlock:(void (^)(NSDictionary *))handlerBlock
                               regex:(NSRegularExpression *)regex
                              macros:(NSArray *)macros;

/**
 *  Handle an Open URL
 *
 *  @param url The URL to be handled
 */
- (void)handleOpenURL:(NSURL *)url;

@end
