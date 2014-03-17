//
//  MBBlockSwizzle.h
//  RITracking
//
//  Created by Martin Biermann on 15/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBBlockSwizzle : NSObject

/**
 * A block type definition for blocks that contain logic to revert a swizzled method's
 * implementation to it's original implementation.
 */
typedef void(^MBSwizzleRevertBlock)();

/**
 * A function to swizzle a method of a class or instance with given implementation block.
 * Note: Due to an observation, this function uses the classes name, to pick up the current
 * class in the runtime via NSClassFromString. Otherwise, another class reference would be
 * used, which leads to unpredictable behavior.
 * @param className Name of the class of the method to be swizzled.
 * @param selector Method selector definition to identify method on the class definitions.
 * @param isClassMethod Boolean flag to indicate the method is a class or instance method.
 * @param block Block to contain the implementation to be executed by the method.
 * @return TMMethodSwizzleRevertBlock Block to contain logic to revert the swizzle.
 */
MBSwizzleRevertBlock MBSwizzleWithBlock(
NSString *className, SEL selector, BOOL isClassMethod, id block
);

/**
 * A function to swizzle a method of a class or instance with given implementation block
 * and run a given block. After the block execution the swizzle is reverted.
 * Note: Due to an observation, this function uses the classes name, to pick up the current
 * class in the runtime via NSClassFromString. Otherwise, another class reference would be
 * used, which leads to unpredictable behavior.
 * @param className Name of the class of the method to be swizzled.
 * @param selector Method selector definition to identify method on the class definitions.
 * @param isClassMethod Boolean flag to indicate the method is a class or instance method.
 * @param imp Block to contain the implementation to be executed by the method.
 * @param run Block to contain logic to be executed when the swizzle was executed.
 */
void MBSwizzleWithBlockAndRun(
NSString *className, SEL selector, BOOL isClassMethod, id imp, void(^run)()
);


@end
