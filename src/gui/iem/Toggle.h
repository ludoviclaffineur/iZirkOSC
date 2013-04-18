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
#import "IEMWidget.h"

@class Gui;

@interface Toggle : IEMWidget

@property (assign) float toggleValue; // remember non zero value when off

+ (id)toggleFromAtomLine:(NSArray *)line withGui:(Gui *)gui;

- (void)toggle;

@end
