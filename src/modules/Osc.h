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
//! Returns YES if the server is listenning
@property (nonatomic, assign, getter=isListening) BOOL listening;
//! String address to send to.
@property (nonatomic, strong) NSString *sendHost; // do not set when listening
//! Port to send to
@property (nonatomic) int sendPort; // do not set when listening
//! Port listenning
@property (nonatomic) int listenPort;
//! Link to controller
@property (nonatomic, retain) PatchViewController* controller;

#pragma mark Send Events

//! Try to send the source attributes to the distant host
- (BOOL) sendSource:(SoundSource*) s;
//! Try to send the begin touch to the distant host. You have to send this message before you send the source.
- (BOOL) beginTouch:(SoundSource *)s;
//! Try to send the end touch to the distant host. You have to send this message after you sent the source.
- (BOOL) endTouch:(SoundSource *)s;

//! Try to send the begin azimuth span move to the distant host. You have to send this message before you send the moveAzimSpan.
- (BOOL) beginAzimSpanMove:(SoundSource *)s;
//! Try to send the new azimuth span move to the distant host.
- (BOOL) moveAzimSpan:(SoundSource *)s;
//! Try to send the end azimuth move to the distant host. You have to send this message after you sent the moveAzimSpan. 
- (BOOL) endAzimSpanMove:(SoundSource*)s;

//! Try to send the begin elevation span move to the distant host. You have to send this message before you send the moveElevSpan.
- (BOOL) beginElevSpanMove:(SoundSource *)s;
//! Try to send the new elevation span move to the distant host.
- (BOOL) moveElevSpan:(SoundSource *)s;
//! Try to send the end elevation span move to the distant host. You have to send this message after you sent the moveElevSpan. 
- (BOOL) endElevSpanMove:(SoundSource*)s;

@end
