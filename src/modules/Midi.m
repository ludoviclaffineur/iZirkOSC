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
#import "Midi.h"

#import "Log.h"
#import "PdBase.h"
#include <mach/mach_time.h>
#import "iOSVersionDetection.h"
#import "Util.h"

// MIDI status bytes
enum MidiStatus {

	// channel voice messages
	MIDI_NOTE_OFF			= 0x80,
	MIDI_NOTE_ON			= 0x90,
	MIDI_CONTROL_CHANGE		= 0xB0,
	MIDI_PROGRAM_CHANGE		= 0xC0,
	MIDI_PITCH_BEND			= 0xE0,
	MIDI_AFTERTOUCH			= 0xD0,	// aka channel pressure
	MIDI_POLY_AFTERTOUCH	= 0xA0,	// aka key pressure

	// system messages
	MIDI_SYSEX				= 0xF0,
	MIDI_TIME_CODE			= 0xF1,
	MIDI_SONG_POS_POINTER	= 0xF2,
	MIDI_SONG_SELECT		= 0xF3,
	MIDI_TUNE_REQUEST		= 0xF6,
	MIDI_SYSEX_END			= 0xF7,
	MIDI_TIME_CLOCK			= 0xF8,
	MIDI_START				= 0xFA,
	MIDI_CONTINUE			= 0xFB,
	MIDI_STOP				= 0xFC,
	MIDI_ACTIVE_SENSING		= 0xFE,
	MIDI_SYSTEM_RESET		= 0xFF
};

// number range defines
// because it's sometimes hard to remember these  ...
#define MIDI_MIN_BEND		0
#define MIDI_MAX_BEND		16383

#pragma mark Util

// there is no conversion fucntion on iOS, so we make one here
// from https://developer.apple.com/library/mac/#qa/qa1398/_index.html
uint64_t absoluteToNanos(uint64_t time) {
	static struct mach_timebase_info timebaseInfo;
	if(timebaseInfo.denom == 0) { // only init once
		mach_timebase_info(&timebaseInfo);
	}
	return time * timebaseInfo.numer / timebaseInfo.denom;
}

@interface Midi () {
	
	unsigned long long lastTime;	// timestamp from last packet
	bool bFirstPacket;				// is this the first received packet?
	bool bContinueSysex;			// is this packet part of a sysex message?

	NSMutableData *messageIn, *messageOut;	// raw byte buffers
}

@property (nonatomic, strong) PGMidi *midi;

- (void)handleMessage:(NSData *)message withDelta:(double)deltatime;
- (void)sendMessage:(NSData *)message;
- (void)sendMessage:(NSData *)message toPort:(int)port;

@end

@implementation Midi

- (id)init {
	IF_IOS_HAS_COREMIDI (
		self = [super init];
		if(self) {
			PGMidi *pgmidi = [[PGMidi alloc] init];
			pgmidi.delegate = self;
			self.midi = pgmidi;
			
			lastTime = 0;
			bFirstPacket = true;
			bContinueSysex = false;
			messageIn = [[NSMutableData alloc] init];
			messageOut = [[NSMutableData alloc] init];
			
			self.bIgnoreSense = YES;
			self.bIgnoreSysex = NO;
			self.bIgnoreTiming = YES;
		}
		return self;
	)
	return nil;
}

- (void)enableNetwork:(bool)enabled {
	
}

#pragma mark Overridden Getters / Setters

- (void)setNetworkEnabled:(BOOL)networkEnabled {
	MIDINetworkSession* session = [MIDINetworkSession defaultSession];
    session.enabled = networkEnabled;
    session.connectionPolicy = MIDINetworkConnectionPolicy_Anyone;
	DDLogVerbose(@"Midi: networking session \"%@\" %@", session.networkName, networkEnabled ? @"enabled" : @"disabled");
}

- (BOOL)isNetworkEnabled {
	return [[MIDINetworkSession defaultSession] isEnabled];
}

- (void)setMidi:(PGMidi *)newMidi {

    self.midi.delegate = nil;
    for(PGMidiSource *source in self.midi.sources) {
		source.delegate = nil;
	}

    _midi = newMidi;

    self.midi.delegate = self;
    for(PGMidiSource *source in self.midi.sources) {
		source.delegate = self;
	}
}

#pragma mark PGMidiDelegate

- (void)midi:(PGMidi *)midi sourceAdded:(PGMidiSource *)source {
	source.delegate = self;
	DDLogVerbose(@"Midi: source added: %@", source.name);
}

- (void)midi:(PGMidi *)midi sourceRemoved:(PGMidiSource *)source {
	DDLogVerbose(@"Midi: source removed: %@", source.name);
}

- (void)midi:(PGMidi *)midi destinationAdded:(PGMidiDestination *)destination {
	DDLogVerbose(@"Midi: destination added: %@", destination.name);
}

- (void)midi:(PGMidi *)midi destinationRemoved:(PGMidiDestination *)destination {
	DDLogVerbose(@"Midi: destination removed: %@", destination.name);
}

#pragma mark PGMidiSourceDelegate

// adapted from ofxMidi iOS & RTMidi CoreMidi message parsing
- (void)midiSource:(PGMidiSource *)input midiReceived:(const MIDIPacketList *)packetList {

    const MIDIPacket * packet = &packetList->packet[0];
	unsigned char statusByte;
	unsigned short nBytes, curByte, msgSize;
	unsigned long long time;
	double delta = 0.0;

    for(int i = 0; i < packetList->numPackets; ++i) {
       
		nBytes = packet->length;
		if(nBytes == 0)
			continue;

		// calc time stamp
		time = 0;
		if(bFirstPacket) {
			bFirstPacket = false;
		}
		else {
			time = packet->timeStamp;
			if(time == 0) { // this happens when receiving asynchronous sysex messages
				time = mach_absolute_time();
			}
			time -= lastTime;

			// set the delta time between individual messages
			if(!bContinueSysex) {
				delta = absoluteToNanos(time) * 0.000001; // convert to ms
			}
		}
		lastTime = packet->timeStamp;
		if(lastTime == 0 ) { // this happens when receiving asynchronous sysex messages
		  lastTime = mach_absolute_time();
		}

		// handle segmented sysex messages
		curByte = 0;
		if(bContinueSysex) {

			// copy the packet if not ignoring
			if(!self.bIgnoreSysex) {
				for(int i = 0; i < nBytes; ++i) {
					[messageIn appendBytes:&packet->data[i] length:1];
				}
			}
			bContinueSysex = packet->data[nBytes-1] != MIDI_SYSEX_END; // look for stop

			if(!bContinueSysex) {
				// send message if sysex message complete
				if(messageIn.length > 0) {
					[self handleMessage:messageIn withDelta:delta];
				}
				[messageIn setLength:0];
			}
		}
		else { // not sysex, parse bytes

			while(curByte < nBytes) {
				msgSize = 0;

				// next byte in the packet should be a status byte
				statusByte = packet->data[curByte];
				if(!statusByte & MIDI_NOTE_ON)
					break;

				// determine number of bytes in midi message
				if(statusByte < MIDI_PROGRAM_CHANGE)
					msgSize = 3;
				else if(statusByte < MIDI_PITCH_BEND)
					msgSize = 2;
				else if(statusByte < MIDI_SYSEX)
					msgSize = 3;
				else if(statusByte == MIDI_SYSEX) {

					if(self.bIgnoreSysex) {
						msgSize = 0;
						curByte = nBytes;
					}
					else {
						msgSize = nBytes - curByte;
					}
					bContinueSysex = packet->data[nBytes-1] != MIDI_SYSEX_END;
				}
				else if(statusByte == MIDI_TIME_CODE) {

					if(self.bIgnoreTiming) {
						msgSize = 0;
						curByte += 2;
					}
					else {
						msgSize = 2;
					}
				}
				else if(statusByte == MIDI_SONG_POS_POINTER)
					msgSize = 3;
				else if(statusByte == MIDI_SONG_SELECT)
					msgSize = 2;
				else if(statusByte == MIDI_TIME_CLOCK && self.bIgnoreTiming) {
					// ignoring ...
					msgSize = 0;
					curByte += 1;
				}
				else if(statusByte == MIDI_ACTIVE_SENSING && self.bIgnoreSense) { // active sense message
					// ignoring ...
					msgSize = 0;
					curByte += 1;
				}
				else {
					msgSize = 1;
				}

				// copy packet
				if(msgSize) {

					[messageIn appendBytes:&packet->data[curByte] length:curByte+msgSize];

					if(!bContinueSysex) {
						// send message if sysex message complete
						if(messageIn.length > 0) {
							[self handleMessage:messageIn withDelta:delta];
						}
						[messageIn setLength:0];
					}
					curByte += msgSize;
				}
			}
		}
		packet = MIDIPacketNext(packet);
    }
}

#pragma mark Sending

- (void)sendNoteOn:(int)channel pitch:(int)pitch velocity:(int)velocity {
	DDLogVerbose(@"Midi: Sending Note %d %d %d", channel, pitch, velocity);
	[messageOut setLength:3];
	unsigned char *bytes = (unsigned char*)[messageOut bytes];
	bytes[0] = MIDI_NOTE_ON+channel;
	bytes[1] = pitch;
	bytes[2] = velocity;
	[self sendMessage:messageOut];
}

- (void)sendControlChange:(int)channel controller:(int)controller value:(int)value {
	DDLogVerbose(@"Midi: Sending Control %d %d %d", channel, controller, value);
	[messageOut setLength:3];
	unsigned char *bytes = (unsigned char*)[messageOut bytes];
	bytes[0] = MIDI_CONTROL_CHANGE+channel;
	bytes[1] = controller;
	bytes[2] = value;
	[self sendMessage:messageOut];
}

- (void)sendProgramChange:(int)channel value:(int)value {
	DDLogVerbose(@"Midi: Sending Program %d %d", channel, value);
	[messageOut setLength:2];
	unsigned char *bytes = (unsigned char*)[messageOut bytes];
	bytes[0] = MIDI_PROGRAM_CHANGE+channel;
	bytes[1] = value;
	[self sendMessage:messageOut];
}

- (void)sendPitchBend:(int)channel value:(int)value {
	DDLogVerbose(@"Midi: Sending PitchBend %d %d", channel, value);
	[messageOut setLength:3];
	unsigned char *bytes = (unsigned char*)[messageOut bytes];
	bytes[0] = MIDI_PITCH_BEND+channel;
	bytes[1] = value & 0x7F; // lsb 7bit
	bytes[2] = (value >> 7) & 0x7F; // msb 7bit
	[self sendMessage:messageOut];
}

- (void)sendAftertouch:(int)channel value:(int)value {
	DDLogVerbose(@"Midi: Sending Aftertouch %d %d", channel, value);
	[messageOut setLength:2];
	unsigned char *bytes = (unsigned char*)[messageOut bytes];
	bytes[0] = MIDI_AFTERTOUCH+channel;
	bytes[1] = value;
	[self sendMessage:messageOut];
}

- (void)sendPolyAftertouch:(int)channel pitch:(int)pitch value:(int)value {
	DDLogVerbose(@"Midi: Sending PolyAftertouch %d %d %d", channel, pitch, value);
	[messageOut setLength:3];
	unsigned char *bytes = (unsigned char*)[messageOut bytes];
	bytes[0] = MIDI_POLY_AFTERTOUCH+channel;
	bytes[1] = pitch;
	bytes[2] = value;
	[self sendMessage:messageOut];
}

- (void)sendMidiByte:(int)port byte:(int)byte {
	DDLogVerbose(@"Midi: Sending Sysex byte %02X to %d", byte, port);
	[messageOut setLength:1];
	unsigned char *bytes = (unsigned char*)[messageOut bytes];
	bytes[0] = byte;
	[self sendMessage: messageOut toPort:port];
}

- (void)sendSysex:(int)port byte:(int)byte {
	DDLogVerbose(@"Midi: Sending Midi byte %02X to %d", byte, port);
	[messageOut setLength:1];
	unsigned char *bytes = (unsigned char*)[messageOut bytes];
	bytes[0] = byte;
	[self sendMessage:messageOut toPort:port];
}

#pragma mark Private

- (void)handleMessage:(NSData *)message withDelta:(double)deltatime {

	const unsigned char *bytes = (const unsigned char*)[message bytes];
	int statusByte = bytes[0];
	int channel = 1;

	if(bytes[0] >= MIDI_SYSEX) {
		statusByte = bytes[0] & 0xFF;
	} else {
		statusByte = bytes[0] & 0xF0;
		channel = (int) (bytes[0] & 0x0F);
	}
	
	#ifdef DEBUG
		[Util logData:message withHeader:@"Midi: Received "];
	#endif
	
	switch(statusByte) {
		case MIDI_NOTE_ON :
		case MIDI_NOTE_OFF:
			[PdBase sendNoteOn:channel pitch:bytes[1] velocity:bytes[2]];
			DDLogVerbose(@"Midi: Received Note %d %d %d", channel, bytes[1], bytes[2]);
			break;
		case MIDI_CONTROL_CHANGE: {
			[PdBase sendControlChange:channel controller:bytes[1] value:bytes[2]];
			DDLogVerbose(@"Midi: Received Control %d %d %d", channel, bytes[1], bytes[2]);
			break;
		}
		case MIDI_PROGRAM_CHANGE:
			[PdBase sendProgramChange:channel value:bytes[1]];
			DDLogVerbose(@"Midi: Received Program %d %d", channel, bytes[1]);
			break;
		case MIDI_PITCH_BEND: {
			int value = (bytes[2] << 7) + bytes[1]; // msb + lsb
			[PdBase sendPitchBend:channel value:value];
			DDLogVerbose(@"Midi: Received PitchBend %d %d", channel, value);
			break;
		}
		case MIDI_AFTERTOUCH:
			[PdBase sendAftertouch:channel value:bytes[1]];
			DDLogVerbose(@"Midi: Received Aftertouch %d %d", channel, bytes[1]);
			break;
		case MIDI_POLY_AFTERTOUCH:
			[PdBase sendPolyAftertouch:channel pitch:bytes[1] value:bytes[2]];
			DDLogVerbose(@"Midi: Received PolyAftertouch %d %d %d", channel, bytes[1], bytes[2]);
			break;
		case MIDI_SYSEX:
			for(int i = 0; i < message.length; ++i) {
				[PdBase sendSysex:channel byte:bytes[i]];
			}
			DDLogVerbose(@"Midi: Received %d Sysex bytes to %d", message.length, channel);
			break;
		default:
//			for(int i = 0; i < message.length; ++i) {
//				[PdBase sendMidiByte:channel byte:bytes[i]];
//			}
//			DDLogVerbose(@"Midi: Received %d Raw bytes to %d", message.length, channel);
			break;
	}
}

// adapted from PGMidi sendBytes
- (void)sendMessage:(NSData *)message {
	
	#ifdef DEBUG
		[Util logData:message withHeader:@"Midi: Sending "];
	#endif

    Byte packetBuffer[message.length+100];
    MIDIPacketList *packetList = (MIDIPacketList*)packetBuffer;
    MIDIPacket *packet = MIDIPacketListInit(packetList);
	
    packet = MIDIPacketListAdd(packetList, sizeof(packetBuffer), packet, 0, message.length, message.bytes);

	for(PGMidiDestination *destination in self.midi.destinations) {
		[destination sendPacketList:packetList];
	}
}

- (void)sendMessage:(NSData *)message toPort:(int)port {

	#ifdef DEBUG
		[Util logData:message withHeader:@"Midi: Sending "];
	#endif

	Byte packetBuffer[message.length];
    MIDIPacketList *packetList = (MIDIPacketList*)packetBuffer;
    MIDIPacket *packet = MIDIPacketListInit(packetList);

    packet = MIDIPacketListAdd(packetList, sizeof(packetBuffer), packet, 0, message.length, message.bytes);
	
	PGMidiDestination *destination = [self.midi.destinations objectAtIndex:port];
	if(destination) {
		[destination sendPacketList:packetList];
	}
	else {
		DDLogWarn(@"Midi: cannot send message, port %d not found", port);
	}
}

@end
