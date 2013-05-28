/*
 * Copyright (c) 2013 Dan Wilcox <danomatika@gmail.com>
 * Copyright 2013 Ludovic Laffineur ludovic.laffineur@gmail.com 
 * BSD Simplified License.
 * For information on usage and redistribution, and for a DISCLAIMER OF ALL
 * WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 *
 * See https://github.com/danomatika/PdParty for documentation
 *
 */
#import <Foundation/Foundation.h>

@interface Util : NSObject

#pragma mark Device

//! returns YES if we are running in the simulator?
+ (BOOL)isDeviceRunningInSimulator;

//! Returns YES if this device is an ipad?
+ (BOOL)isDeviceATablet;
//! Returns the current IP Address and error if they is'nt
+ (NSString *)getIPAddress;
//! converts radian to degree
+ (float) radianToDegree:(float) radian;
//! converts degree to racian
+ (float) degreeToRadian:(float) degree;

#pragma mark App

//! application pixel width
+ (CGFloat) appWidth;
//! application pixel height
+ (CGFloat) appHeight;
//! application size
+ (CGSize) appSize;


@end

#pragma mark Array

@interface NSArray (EasyTypeCheckArray)

// check object type at array pos
- (BOOL)isNumberAt:(int)index;
- (BOOL)isStringAt:(int)index;

@end

#pragma mark String

@interface NSMutableString (CharSetString)

- (void)setCharacter:(unichar)c atIndex:(unsigned)i;

@end
