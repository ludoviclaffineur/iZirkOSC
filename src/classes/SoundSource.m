//
//  SoundSource.m
//  PdParty
//
//  Created by Lud's on 8/04/13.
//  Copyright (c) 2013 danomatika. All rights reserved.
//

#import "SoundSource.h"
#import "Util.h"
@implementation SoundSource
@synthesize radius;
@synthesize azimuth;
@synthesize azimuth_span;
@synthesize elevation_span;
@synthesize elevation;
@synthesize gain;
@synthesize channel;
@synthesize touch;
@synthesize lastSending;
-(id)init{
    self = [super init];
    gain = 1;
    azimuth = 0; //all in radian !!!
    azimuth_span = 0;
    elevation = 0;
    channel = 1;
    elevation_span = 0;
    lastSending = [NSDate date];
    radius = [Util appWidth]/2-40-2;
    return self;
}

-(void) setPositionHV: (CGPoint)p  {
    float dist= sqrt(p.x* p.x + p.y*p.y);
    if (fabs(dist)> radius){
        elevation = 0.0f;
    }
    else{
        elevation = acos(dist/radius) ;
    }
    azimuth = - (M_PI/2 + atan2(p.y,p.x));
    if(azimuth< -180){
        azimuth= 360 +azimuth;
    }
    
}

- (bool) containsPoint:(CGPoint) p{
    return (p.x< [self getPosX]+30 && p.x> [self getPosX]-30 && p.y< [self getPosY]+30 && p.y> [self getPosY]-30 );
}

- (float) getPosX{
    return (-radius * sinf(azimuth) * cosf(elevation));
}

- (float) getPosY{
    return (-radius * cosf(azimuth) * cosf(elevation));
}

@end
