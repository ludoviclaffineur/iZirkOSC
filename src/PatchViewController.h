/*
 * Copyright (c) 2013 Dan Wilcox <danomatika@gmail.com>
 * Copyright 2013 Ludovic Laffineur ludovic.laffineur@gmail.com 
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

@class Util;

//! DetailViewController for domeView
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
