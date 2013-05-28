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
#import "Util.h"

#import "Log.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation Util

+ (float) degreeToRadian :(float) degree{
    return ((degree/360.0f)*2*3.1415);
}

+ (float) radianToDegree:(float) radian{
    return (radian/(2*3.1415)*360.0f);
}


#pragma mark Device

// from http://stackoverflow.com/questions/458304/how-can-i-programmatically-determine-if-my-app-is-running-in-the-iphone-simulato
+ (BOOL)isDeviceRunningInSimulator; {
	#if TARGET_IPHONE_SIMULATOR
		return YES;
	#elif TARGET_OS_IPHONE
		return NO;
	#else // unknown
		return NO;
	#endif
}

+ (BOOL)isDeviceATablet; {
	return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

#pragma mark App

+ (CGFloat) appWidth {
    return [UIScreen mainScreen].applicationFrame.size.width;
}

+ (CGFloat) appHeight {
    return [UIScreen mainScreen].applicationFrame.size.height;
}

+ (CGSize) appSize {
    return CGSizeMake(
		[UIScreen mainScreen].applicationFrame.size.width,
		[UIScreen mainScreen].applicationFrame.size.height);
}

+ (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    return address;
}




@end

#pragma mark Array

@implementation NSArray (EasyTypeCheckArray)

- (BOOL)isNumberAt:(int)index {
	return [[self objectAtIndex:index] isKindOfClass:[NSNumber class]];
}

- (BOOL)isStringAt:(int)index {
	return [[self objectAtIndex:index] isKindOfClass:[NSString class]];
}

@end

#pragma mark MutableString

@implementation NSMutableString (StringUtils)

- (void)setCharacter:(unichar)c atIndex:(unsigned)i {
	NSLog(@"setting %c at %d in \"%@\"", c, i, self);
	[self replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithCharacters:&c length:1]];
}



@end
