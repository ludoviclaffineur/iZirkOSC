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
#import <UIKit/UIKit.h>

#import "KeyGrabber.h"
#import "DomeView.h"
#import "Util.h"
// what kind of scene are we running?
typedef enum {
	SceneTypeEmpty,	// nothing loaded
	SceneTypePatch, // basic pd patch
	SceneTypeRj,	// RjDj scene (folder with .rj ext & _main.pd)
	SceneTypeDroid,	// DroidParty scene (folder with droidparty_main.pd)
	SceneTypeParty	// PdParty scene (folder with _main.pd)
} SceneType;

@class Util;

// DetailViewController for patches/scenes
@interface PatchViewController : UIViewController <UISplitViewControllerDelegate, UIAccelerometerDelegate, KeyGrabberDelegate>{
    DomeView *domeView;
    NSDate *redrawTime;
    int movementmode; //1->6

}
//! Called when a slider value changed
- (IBAction)SliderValueChanged:(id)sender;
//! Called when a touch is release outside a slider
- (IBAction)SliderTouchUpOutside:(id)sender;
//! Called when a touch is release inside a slider
- (IBAction)SliderTouchUpInsider:(id)sender;
//! Called when a slider is touched
- (IBAction)SliderTouched:(id)sender;

//! Elevation span slider
@property (weak, nonatomic) IBOutlet UISlider *ElevSpanSlider;
//! Azimuth span slider
@property (weak, nonatomic) IBOutlet UISlider *AzimSpanSlider;

//! movement mode type (constrain mode)
@property(nonatomic, assign) int movementmode;
//! link to the domeview
@property(nonatomic, retain) DomeView *domeView;
//! the last time it was redrawn
@property(nonatomic, retain)  NSDate *redrawTime;



@end
