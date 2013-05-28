//
//  SoundSource.h
//  PdParty
//
//  Created by Lud's on 8/04/13.
//  Copyright 2013 Ludovic Laffineur ludovic.laffineur@gmail.com 
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//! Properties of a source
@interface SoundSource : NSObject{
    int channel;
    //! Source gain
    float gain;
    float azimuth;
    float elevation;
    float azimuth_span;
    float elevation_span;
    float radius;
    int touchId;
    NSDate *lastSending ;
}

//! Returns YES if it contains the point p
- (bool) containsPoint :(CGPoint) p;
//! set the HV position (XY)
- (void) setPositionHV: (CGPoint)p;
//! Set the Azimuth span
- (void) setAzimuthSpan:(float) f;
//! Get Azimuth spans
- (float) getAzimuthSpan;
//! Set the Azimuth span
- (void) setElevationSpan:(float) f;
//! Get Azimuth spans
- (float) getElevationSpan;
//! returns the X postion
- (float) getPosX;
//! returns the Y postion
- (float) getPosY;

//! Source channel id send to Zirkonium
@property (nonatomic, assign) int channel;
//! Source gain
@property (nonatomic, assign) float gain;
//! source azimuth
@property (nonatomic, assign) float azimuth;
//! source Elevation
@property (nonatomic, assign) float elevation;
//! Source azimuth span
@property (nonatomic, assign) float azimuth_span;
//! source Elevation span
@property (nonatomic, assign) float elevation_span;
//! source radius
@property (nonatomic, assign) float radius;
//! source touchid -1 if it's not touched
@property (nonatomic, assign) int touchId;
//! last time she was sen
@property (nonatomic, retain) NSDate *lastSending ;
@end
