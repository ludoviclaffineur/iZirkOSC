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

@class Osc;

// start page view
@interface OscViewController : UITableViewController

//! Switch button
@property (nonatomic, weak) IBOutlet UISwitch *connectionEnabledSwitch;
//! Textfield to host address
@property (nonatomic, weak) IBOutlet UITextField *hostTextField;
//! Textfield for the outgoing port
@property (nonatomic, weak) IBOutlet UITextField *outgoingPortTextField;
//! Textfield for the incomming port
@property (nonatomic, weak) IBOutlet UITextField *incomingPortTextField;
//! Label of the ip address ip
@property (nonatomic, weak) IBOutlet UILabel *localHostLabel;

//! Called you swipe the switch button 
- (IBAction)enableOscConnection:(id)sender;
//! Called when you set the host
- (IBAction)setHost:(id)sender;
//! Called when you set the outgoing port
- (IBAction)setOutgoingPort:(id)sender;
//! Called when you set the incoming port
- (IBAction)setIncomingPort:(id)sender;

@end
