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
#import "Osc.h"
#import "Log.h"
//#import "PureData.h"

@interface Osc () {
	OSCConnection *connection;
    PatchViewController* controller;
    NSDate* cadencing;
}
@end

@implementation Osc
@synthesize controller;
@synthesize listenPort;
@synthesize sendHost;
@synthesize sendPort;
@synthesize listening;


- (id)init {
	self = [super init];
	if(self) {
		connection = [[OSCConnection alloc] init];
		connection.delegate = self;
		connection.continuouslyReceivePackets = YES;
        self.sendHost = @"10.0.1.2";
		self.sendPort = 10116;
		self.listenPort = 10114;
		listening = NO;
		cadencing = [NSDate date];
		// do a bind at the beginning so sending works
		NSError *error;
		if(![connection bindToAddress:nil port:self.listenPort error:&error]) {
			DDLogError(@"OSC: Could not bind UDP connection: %@", error);
		}
		[connection disconnect];
	}
	return self;
}

#pragma OSCConnectionDelegate

- (void)oscConnection:(OSCConnection *)connection didReceivePacket:(OSCPacket *)packet {
    //NSLog(@"OSC message to port %@: %@", packet.address, [packet.arguments description]);

    
    if([packet.address isEqual: @"/pan/az"]){
        //NSLog(@"OSC message to port %@: %@", packet.address, [packet.arguments description]);
        int channel = [[packet.arguments objectAtIndex:0]intValue];
        int i=0;
        for(i=0;i<controller.domeView.mChannelCount;i++){
            SoundSource *s = [controller.domeView.sources objectAtIndex:i];
            if(channel == s.channel){
                break;
            }
        }
        if(i!=controller.domeView.mChannelCount){
            SoundSource *s = [controller.domeView.sources objectAtIndex:i];
            s.channel = channel;
            s.azimuth = [[packet.arguments objectAtIndex:1]floatValue];
            s.elevation= [[packet.arguments objectAtIndex:2]floatValue];
            s.azimuth_span = [[packet.arguments objectAtIndex:3]floatValue];
            s.elevation_span = [[packet.arguments objectAtIndex:4]floatValue];
            s.gain = [[packet.arguments objectAtIndex:5]floatValue];
            //NSLog(@"paket : %d", channel);
            if ([controller.redrawTime timeIntervalSinceNow]<-0.050f){
                [controller.domeView setNeedsDisplay];
                controller.redrawTime = [NSDate date];
                 
            }
             //NSLog(@"paket : %d", channel);
        }
        
       
    }
    else if([packet.address isEqual: @"/maxsource"]){ //define max source available maxsource , (channel)*maxsource
        NSLog(@"OSC message to port %@: %@", packet.address, [packet.arguments description]);
        int maxsource = [[packet.arguments objectAtIndex:0]intValue];
        if (maxsource>0 && maxsource<=8){
            controller.domeView.mChannelCount = maxsource;
            for (int i =0;i<maxsource;i++){
                SoundSource *s = [controller.domeView.sources objectAtIndex:i];
                s.channel = [[packet.arguments objectAtIndex:i+1]intValue];
            }
        }
        
    }
    else if([packet.address isEqual: @"/movementmode"]){ //define max source available maxsource , (channel)*maxsource
        NSLog(@"OSC message to port %@: %@", packet.address, [packet.arguments description]);
        int typemode = [[packet.arguments objectAtIndex:0]intValue];
        if (typemode >0 && typemode<7){
            controller.movementmode = typemode;
        }
        
        
    }
}

#pragma mark Send Events

- (BOOL) sendSource:(SoundSource*) s{
    
    double timeLastSending = [s.lastSending timeIntervalSinceNow];
    //double timeLastmessageSend = [cadencing timeIntervalSinceNow];
    
    
    // do stuff...
    if( timeLastSending < -0.05f) {
        //NSLog(@"t %f", timeLastmessageSend);
        s.lastSending = [NSDate date];
        cadencing = [NSDate date];
        OSCMutableMessage *message = [[OSCMutableMessage alloc] init];
        message.address = OSC_OSC_ADDR;
        [message addInt:s.channel];
        [message addFloat:s.azimuth];
        [message addFloat:s.elevation];
        [message addFloat:s.azimuth_span];
        [message addFloat:s.elevation_span];
        [message addFloat:s.gain];
        [connection sendPacket:message toHost:self.sendHost port:self.sendPort];
       //  NSLog(@"OSC message sent at %@ , %d", self.sendHost, s.channel);
        return YES;
    }
    return NO;

}

- (BOOL) beginTouch:(SoundSource *)s {
     NSLog(@"BEGINTOUCH , touch : %d, source %d", s.touchId, s.channel);
    OSCMutableMessage *message = [[OSCMutableMessage alloc]init];
    message.address = @"/begintouch";
    [message addInt:s.channel];
    [connection sendPacket:message toHost:self.sendHost port:self.sendPort];
    return YES;
}


- (BOOL) endTouch:(SoundSource *) s{
    NSLog(@"ENDTOUCH , touch : %d, source %d", s.touchId, s.channel);
    OSCMutableMessage *message = [[OSCMutableMessage alloc]init];
    message.address = @"/endtouch";
    [message addInt:s.channel];
    [connection sendPacket:message toHost:self.sendHost port:self.sendPort];
    return YES;
}

- (BOOL) beginAzimSpanMove:(SoundSource *)s{
    NSLog(@"beginAzimSpanMove , touch : %d, source %d", s.touchId, s.channel);
    OSCMutableMessage *message = [[OSCMutableMessage alloc]init];
    message.address = @"/beginAzimSpanMove";
    [message addInt:s.channel];
    [connection sendPacket:message toHost:self.sendHost port:self.sendPort];
    return YES;
}
- (BOOL) endAzimSpanMove:(SoundSource*)s{
    NSLog(@"endAzimSpanMove , touch : %d, source %d", s.touchId, s.channel);
    OSCMutableMessage *message = [[OSCMutableMessage alloc]init];
    message.address = @"/endAzimSpanMove";
    [message addInt:s.channel];
    [connection sendPacket:message toHost:self.sendHost port:self.sendPort];
    return YES;
}
- (BOOL) beginElevSpanMove:(SoundSource *)s{
    NSLog(@"beginElevSpanMove , touch : %d, source %d", s.touchId, s.channel);
    OSCMutableMessage *message = [[OSCMutableMessage alloc]init];
    message.address = @"/beginElevSpanMove";
    [message addInt:s.channel];
    [connection sendPacket:message toHost:self.sendHost port:self.sendPort];
    return YES;
}
- (BOOL) endElevSpanMove:(SoundSource*)s{
    NSLog(@"endElevSpanMove , touch : %d, source %d", s.touchId, s.channel);
    OSCMutableMessage *message = [[OSCMutableMessage alloc]init];
    message.address = @"/endElevSpanMove";
    [message addInt:s.channel];
    [connection sendPacket:message toHost:self.sendHost port:self.sendPort];
    return YES;
}

#pragma mark Overridden Getters / Setters

- (void)setListening:(BOOL)enable {
	if(enable == listening) {
		return;
	}
	
	if(enable) {
		NSError *error;
		if(![connection bindToAddress:nil port:self.listenPort error:&error]) {
			DDLogError(@"OSC: Could not bind UDP connection: %@", error);
			listening = NO;
			return;
		}
		DDLogVerbose(@"OSC: started listening on port %d", connection.localPort);
		[connection receivePacket];
		listening = YES;
	}
	else {
		DDLogVerbose(@"OSC: stopped listening on port %d", connection.localPort);
		[connection disconnect];
		listening = NO;
	}
}

@end
