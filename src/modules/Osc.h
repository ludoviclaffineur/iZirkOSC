/*
 * Copyright (c) 2013 Dan Wilcox <danomatika@gmail.com>
 *
 * BSD Simplified License.
 * For information on usage and redistribution, and for a DISCLAIMER OF ALL
 * WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 *
 * See https://github.com/danomatika/PdParty for documentation
 *
 */
#import "CocoaOSC.h"
#import "SoundSource.h"
#import "PatchViewController.h"


#define OSC_OSC_ADDR	@"/pan/az"

@interface Osc : NSObject <OSCConnectionDelegate>

@property (nonatomic, assign, getter=isListening) BOOL listening;
@property (nonatomic, strong) NSString *sendHost; // do not set when listening
@property (nonatomic) int sendPort; // do not set when listening
@property (nonatomic) int listenPort;
@property (nonatomic, retain) PatchViewController* controller;

#pragma mark Send Events

- (BOOL) sendSource:(SoundSource*) s;
- (BOOL) beginTouch:(SoundSource *)s;
- (BOOL) endTouch:(SoundSource *)s;

- (BOOL) beginAzimSpanMove:(SoundSource *)s;
- (BOOL) moveAzimSpan:(SoundSource *)s;
- (BOOL) endAzimSpanMove:(SoundSource*)s;

- (BOOL) beginElevSpanMove:(SoundSource *)s;
- (BOOL) moveElevSpan:(SoundSource *)s;
- (BOOL) endElevSpanMove:(SoundSource*)s;

@end
