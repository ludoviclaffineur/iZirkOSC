//
//  SoundSource.h
//  PdParty
//
//  Created by Lud's on 8/04/13.
//  Copyright (c) 2013 danomatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SoundSource : NSObject{
    int channel;
    float gain, azimuth, elevation, azimuth_span, elevation_span, radius;
    int touchId;
    NSDate *lastSending ;
}

- (bool) containsPoint :(CGPoint) p;
- (void) setPositionHV: (CGPoint)p;
- (float) getPosX;
- (float) getPosY;
@property (nonatomic, assign) int channel;
@property (nonatomic, assign) float gain;
@property (nonatomic, assign) float azimuth;
@property (nonatomic, assign) float elevation;
@property (nonatomic, assign) float azimuth_span;
@property (nonatomic, assign) float elevation_span;
@property (nonatomic, assign) float radius;
@property (nonatomic, assign) int touchId;
@property (nonatomic, retain) NSDate *lastSending ;
@end
