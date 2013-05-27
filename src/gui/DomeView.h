//
//  DomeView.h
//  PdParty
//
//  Created by Lud's on 8/04/13.
//  Copyright (c) 2013 UdeM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundSource.h"
static const float kMarksAngles[] =
{
	22.5, 90 - 22.5, 90 + 22.5, 180 - 22.5, 180 + 22.5, 270 - 22.5, 270 + 22.5, 360 - 22.5
};

static const int kNumMarks = sizeof(kMarksAngles)/sizeof(kMarksAngles[0]);
@interface DomeView : UIView{
    //! dome frame
    Rect	mDomeFrame;
    //! width active
	float	mActiveWidth;
    //! 
    //Point     mSourcePoint;
    //! Sources array
     NSMutableArray *sources;
    //! NbrSource - Number of active channels 
	int mChannelCount;


	//NSImage   * mBackgroundCache;

    // Math
    //! Radius in pixels
    float   mRadius;
    //! position of the center
    CGPoint mCentre;
}

@property (assign,nonatomic) int mChannelCount;
@property (assign,nonatomic) float mRadius;
@property (nonatomic,retain) NSMutableArray *sources;
@property (assign, readwrite) CGPoint  mCentre;


@end
