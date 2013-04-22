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
#import "PatchViewController.h"

#import "Log.h"
#import "Util.h"
//#import "Gui.h"
#import "PdParser.h"
#import "PdFile.h"
#import "KeyGrabber.h"
#import "AppDelegate.h"

#define ACCEL_UPDATE_HZ	60.0

@interface PatchViewController () {

	NSMutableDictionary *activeTouches; // for persistent ids
	CMMotionManager *motionManager; // for accel data
	Osc *osc; // to send osc
    

	BOOL hasReshaped; // has the gui been reshaped?
}
@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@end

@implementation PatchViewController
@synthesize domeView;
@synthesize redrawTime;

- (void)awakeFromNib {
	self.sceneType = SceneTypeEmpty;
	activeTouches = [[NSMutableDictionary alloc] init];
	hasReshaped = NO;
	[super awakeFromNib];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.domeView = [[DomeView alloc] initWithFrame:CGRectMake(20.0, 20.0, [Util appWidth]-40.0, [Util appWidth]-40.0)];
    self.domeView.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:255];
    [self.view addSubview:self.domeView];
    self.domeView.multipleTouchEnabled = YES;
    redrawTime = [NSDate date];
	AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];

	osc = app.osc;
    osc.controller = self;
    
}

- (void)viewDidLayoutSubviews {
	
	//self.gui.bounds = self.view.bounds;
	
	// do animations if gui has already been setup once
	// http://www.techotopia.com/index.php/Basic_iOS_4_iPhone_Animation_using_Core_Animation
	if(hasReshaped) {
		[UIView beginAnimations:nil context:nil];
	}
//	[self.gui reshapeWidgets];
	if(hasReshaped) {
		[UIView commitAnimations];
	}
	else {
		hasReshaped = YES;
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Overridden Getters / Setters

- (void)setPatch:(NSString*)newPatch {
}

#pragma mark Util

+ (int)orientationInDegrees:(UIInterfaceOrientation)orientation {
	switch(orientation) {
		case UIInterfaceOrientationPortrait:
			return 0;
		case UIInterfaceOrientationPortraitUpsideDown:
			return 180;
		case UIInterfaceOrientationLandscapeLeft:
			return 90;
		case UIInterfaceOrientationLandscapeRight:
			return -90;
	}
}

#pragma mark Overridden Getters / Setters

- (void)setEnableAccelerometer:(BOOL)enableAccelerometer {
	
}

#pragma mark Touches

// persistent touch ids from ofxIPhone:
// https://github.com/openframeworks/openFrameworks/blob/master/addons/ofxiPhone/src/core/ofxiOSEAGLView.mm
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {	
	 NSSet *myTouches = [event touchesForView:self.domeView];
	for(UITouch *touch in myTouches) {
		CGPoint touchPosition = [touch locationInView:(self.domeView)];
        for (int i=0;i<domeView.mChannelCount; i++){
            SoundSource *s = [domeView.sources objectAtIndex:i];
            CGPoint relativePoint =  CGPointMake( touchPosition.x- domeView.mCentre.x ,   touchPosition.y- domeView.mCentre.y) ;
            //NSLog(@"Source angle %f,%f", s.azimuth,s.elevation);
            //NSLog(@"Source Postion %f,%f", [s getPosX],[s getPosY]);
            if([s containsPoint:relativePoint] && s.touch==nil){
               // NSLog(@"YOU GET IT");
                [s setPositionHV:relativePoint];
                s.touch = touch;
                [self.domeView setNeedsDisplay];
                break;
            }
        }
        
       
     
//		DDLogVerbose(@"touch %d: down %.4f %.4f", touchId+1, pos.x, pos.y);
		/*[PureData sendTouch:RJ_TOUCH_DOWN forId:touchId atX:pos.x andY:pos.y];
		if(osc.isListening) {
			[osc sendTouch:RJ_TOUCH_DOWN forId:touchId atX:pos.x andY:pos.y];
		}*/
	}
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	NSSet *myTouches = [event touchesForView:self.domeView];
    //NSLog(@"Touch Count %d",myTouches.count);
	for(UITouch *touch in myTouches) {
		CGPoint touchPosition = [touch locationInView:(self.domeView)];
        //NSLog(@"Position doigt  : %f,%f", touchPosition.x,touchPosition.y);
		for (int i=0;i<domeView.mChannelCount; i++){
            SoundSource *s = [domeView.sources objectAtIndex:i];
            if(touch == s.touch){
                CGPoint relativePoint =  CGPointMake( touchPosition.x- domeView.mCentre.x ,   touchPosition.y- domeView.mCentre.y) ;
                [s setPositionHV:relativePoint];
                if([osc isListening]){
                    if ([osc sendSource:s] && [redrawTime timeIntervalSinceNow]<-0.050f) {
                        [self.domeView setNeedsDisplay];
                        redrawTime = [NSDate date];
                    }
                    //NSLog(@"sending OSC");
                }
                
                
            }
            

        }
        //		DDLogVerbose(@"touch %d: down %.4f %.4f", touchId+1, pos.x, pos.y);
		/*[PureData sendTouch:RJ_TOUCH_DOWN forId:touchId atX:pos.x andY:pos.y];
         if(osc.isListening) {
         [osc sendTouch:RJ_TOUCH_DOWN forId:touchId atX:pos.x andY:pos.y];
         }*/
	}
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

	NSSet *myTouches = [event touchesForView:self.domeView];
   // NSLog(@"Touch Count %d",myTouches.count);
	for(UITouch *touch in myTouches) {
		CGPoint touchPosition = [touch locationInView:(self.domeView)];
        //NSLog(@"Position doigt  : %f,%f", touchPosition.x,touchPosition.y);
		for (int i=0;i<domeView.mChannelCount; i++){
            SoundSource *s = [domeView.sources objectAtIndex:i];
            if(touch == s.touch){
                s.touch=nil;
            }
            //NSLog(@"Source angle %f,%f", s.azimuth,s.elevation);
            //NSLog(@"Source Postion %f,%f", [s getPosX],[s getPosY]);
            
        }
        //		DDLogVerbose(@"touch %d: down %.4f %.4f", touchId+1, pos.x, pos.y);
		/*[PureData sendTouch:RJ_TOUCH_DOWN forId:touchId atX:pos.x andY:pos.y];
         if(osc.isListening) {
         [osc sendTouch:RJ_TOUCH_DOWN forId:touchId atX:pos.x andY:pos.y];
         }*/
	}}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesEnded:touches withEvent:event];
}




#pragma mark KeyGrabberDelegate

- (void)keyPressed:(int)key {
	//[PureData sendKey:key];
}

#pragma mark UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {

	if([Util isDeviceATablet]) {
		barButtonItem.title = NSLocalizedString(@"Settings", @"Settings");
	}
    
	[self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

// hide master view controller by default on all orientations
- (BOOL)splitViewController:(UISplitViewController *)splitController shouldHideViewController:(UIViewController *)viewController inOrientation:(UIInterfaceOrientation)orientation {
	return YES;
}

@end
