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
#import "AppDelegate.h"

#import "Log.h"
#import "Util.h"
//#import "Widget.h"

@interface AppDelegate ()

// recursively copy dirs and patches in the resource patches dir to the
// Documents folder, removes/overwrites any currently existing dirs
- (void)copyResourcePatchesToDocuments;

// add subfolders in libs folder in resource patches dir to search path
- (void)addPatchLibSearchPaths;

@end

@implementation AppDelegate
@synthesize osc;
@synthesize motionManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
	
	if([Util isDeviceATablet]) {
	    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
	    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
	    splitViewController.delegate = (id)navigationController.topViewController;
		splitViewController.presentsWithGesture = NO; // disable swipe gesture for master view
	}
	
	// init logger
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	[DDLog addLogger:[[DDFileLogger alloc] init]];
	//ddLogLevel = [preferences logLevel];
	DDLogInfo(@"Log level: %d", ddLogLevel);
	
	DDLogInfo(@"App resolution: %d %d", (int)[Util appWidth], (int)[Util appHeight]);
	self.osc = [[Osc alloc] init];
	
	return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	
//	self.pureData.audioEnabled = NO;
	self.osc.listening = NO;
//	self.midi.networkEnabled = NO;
}



@end