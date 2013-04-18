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
#import "StartViewController.h"

//#import "WebServer.h"
#import "AppDelegate.h"

@interface StartViewController () {
	NSTimer *serverInfoTimer;
}

// timer function to update the server footer info
- (void)updateServerInfo:(NSTimer*)theTimer;

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSLog(@"viewDidLoad");
}

- (void)viewWillAppear:(BOOL)animated {
	
	AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	if(app.osc.isListening) {
		self.oscLabel.text = [NSString stringWithFormat:@"OSC: %@", app.osc.sendHost];
	}
	else {
		self.oscLabel.text = @"OSC: Disabled";
	}
	NSLog(@"viewWillAppear");
	
	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
//  Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
//	[self.server stop];
//	[self setServerPortLabel:nil];
	[super viewDidUnload];
}


- (void)updateServerInfo:(NSTimer*)theTimer {
	// reloading the table view loads the footer text
	[self.tableView reloadData];
}

#pragma mark UITableViewController

// http://stackoverflow.com/questions/1547497/change-uitableview-section-header-footer-while-running-the-app?rq=1
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	
			return nil;
	
}

@end
