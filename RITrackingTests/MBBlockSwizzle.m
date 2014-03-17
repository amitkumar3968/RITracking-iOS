//
//  MBBlockSwizzle.m
//  RITracking
//
//  Created by Martin Biermann on 15/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

#import "MBBlockSwizzle.h"

#import <objc/message.h>

@implementation MBBlockSwizzle

MBSwizzleRevertBlock MBSwizzleWithBlock(
NSString *className, SEL selector, BOOL isClassMethod, id block
) {
    Class class = NSClassFromString(className);
    Method method = nil;
    if (isClassMethod) {
        method = class_getClassMethod(class, selector);
    } else {
        method = class_getInstanceMethod(class, selector);
    }
    IMP origImp = method_getImplementation(method);
    IMP testImp = imp_implementationWithBlock(block);
    method_setImplementation(method, testImp);
    return ^{ method_setImplementation(method, origImp); };
};

void MBSwizzleWithBlockAndRun(
NSString *className, SEL selector, BOOL isClassMethod, id imp, void(^run)()
) {
    MBSwizzleRevertBlock revert = nil;
    revert = MBSwizzleWithBlock(className, selector, isClassMethod, imp);
    run();
    revert();
};

@end