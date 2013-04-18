//
//  DomeView.h
//  PdParty
//
//  Created by Lud's on 8/04/13.
//  Copyright (c) 2013 danomatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundSource.h"
static const float kMarksAngles[] =
{
	22.5, 90 - 22.5, 90 + 22.5, 180 - 22.5, 180 + 22.5, 270 - 22.5, 270 + 22.5, 360 - 22.5
};

static const int kNumMarks = sizeof(kMarksAngles)/sizeof(kMarksAngles[0]);
@interface DomeView : UIView{
    Rect	mDomeFrame, mFullFrame;
	float	mActiveWidth;
	BOOL	mMouseDown;
    
    // Attribute copies
    Point     mSourcePoint;
    
    //PolarAngles mSourceHeading;
   
     NSMutableArray *sources;
	int mChannelCount;

	
	//NSImage   * mBackgroundCache;
    
    // Math
    float   mRadius;
    CGPoint mCentre;
}

@property (assign,nonatomic) int mChannelCount;
@property (assign,nonatomic) float mRadius;
@property (nonatomic,retain) NSMutableArray *sources;
@property (assign, readwrite) CGPoint  mCentre;


@end
