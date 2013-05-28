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
#import <CoreMotion/CoreMotion.h>

//#import "PureData.h"
//#import "Midi.h"
#import "Osc.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
//! The window
@property (strong, nonatomic) UIWindow *window;
//! Access to the osc server and sender.
@property (nonatomic, strong) Osc *osc;

@end
