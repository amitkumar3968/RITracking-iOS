//
//  RIOpenURLHandler.h
//  RITracking
//
//  Created by Martin Biermann on 15/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIOpenURLHandler : NSObject

- (instancetype)initWithHandlerBlock:(void (^)(NSDictionary *))handlerBlock
                               regex:(NSRegularExpression *)regex
                              macros:(NSArray *)macros;

- (void)handleOpenURL:(NSURL *)url;

@end
