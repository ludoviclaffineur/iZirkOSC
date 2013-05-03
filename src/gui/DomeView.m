//
//  DomeView.m
//  PdParty
//
//  Created by Lud's on 8/04/13.
//  Copyright (c) 2013 danomatika. All rights reserved.
//

#import "DomeView.h"
#import "Util.h"

@implementation DomeView
@synthesize mCentre;
@synthesize mChannelCount;
@synthesize sources;
@synthesize mRadius;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mChannelCount = 8;
        mCentre = CGPointMake(([Util appWidth]-40)/2, ([Util appWidth]-40)/2);
        NSLog(@"position in domeview, %f, %f" , mCentre.x, mCentre.y);
        mRadius = (([Util appWidth]/2-40-2));
        sources = [[NSMutableArray alloc]init];
        for (int i=0; i<8; i++) {
            [sources addObject:[[SoundSource alloc]init]];
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect {

    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(contextRef,2);
    CGContextSetRGBStrokeColor(contextRef, 0.0, 0.0, 255.0, 1.0);
    CGContextAddArc(contextRef,mCentre.x, mCentre.y,mRadius,0,2*3.1415926535898,1);
    CGContextDrawPath(contextRef,kCGPathStroke);
    [self drawCrosshairs];
    [self drawSourcePoint];
}

-(void) drawCrosshairs
{
    // Create an oval shape to draw.

    for (int i=0; i< kNumMarks; i++) {
        UIBezierPath *aPath = [UIBezierPath bezierPath];

        float fraction = 0.9f;
		float angle = kMarksAngles[i] * (M_PI * 2 / 360.);
        float axis_x = cos(angle);
        float axis_y = sin(angle);
        [aPath moveToPoint:CGPointMake(mCentre.x + axis_x * mRadius, mCentre.y + axis_y * mRadius)];

        // Draw the lines.
        [aPath addLineToPoint:CGPointMake(mCentre.x + axis_x * mRadius*fraction, mCentre.y + axis_y * mRadius*fraction)];

        // Set the render colors.
        [[UIColor blueColor] setStroke];

        CGContextRef aRef = UIGraphicsGetCurrentContext();

        aPath.lineWidth = 1.0;

        [aPath fill];
        [aPath stroke];
    }

    UIBezierPath * xAxis = [UIBezierPath bezierPath];
    UIBezierPath * yAxis = [UIBezierPath bezierPath];

    [xAxis moveToPoint:CGPointMake(mCentre.x- mRadius, mCentre.y)];
    [xAxis addLineToPoint:CGPointMake(mCentre.x+ mRadius, mCentre.y)];
    xAxis.lineWidth=1.0;
    [xAxis stroke];

    [yAxis moveToPoint:CGPointMake(mCentre.x, mCentre.y- mRadius)];
    [yAxis addLineToPoint:CGPointMake(mCentre.x, mCentre.y + mRadius)];
    yAxis.lineWidth=1.0;
    [yAxis stroke];

    // Restore the graphics state before drawing any other content.
    //CGContextRestoreGState(aRef);
}

-(void) drawSourcePoint
{
	for (int i = 0; i < mChannelCount; i++)
	{
        SoundSource *s = [sources objectAtIndex:i];
        CGPoint dome;
        UILabel *number= [[UILabel alloc]init];

        number.text = [NSString stringWithFormat:@"%d", i+1];
        dome.x = s.azimuth;
        dome.y = s.elevation;
        CGPoint screen = [self domeToScreen:dome];
        UIBezierPath *Path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(mCentre.x + screen.x-20, mCentre.y + screen.y - 20, 40, 40)];

        Path.lineWidth = 2;
        [[UIColor redColor] setStroke];
        [Path stroke];
        NSString *description = [[NSNumber numberWithInt:s.channel] stringValue];
        CGSize descriptionSize = [description sizeWithFont:[UIFont systemFontOfSize:20] ];

        [description drawInRect:CGRectMake(mCentre.x + screen.x-5 , mCentre.y -10 + screen.y , descriptionSize.width, descriptionSize.height) withFont:[UIFont systemFontOfSize:20]];

	}
}


#pragma mark conversion

-(CGPoint) domeToScreen:(CGPoint) d{
    CGPoint p;
    p.x = -mRadius * sinf(d.x) * cosf(d.y);
    p.y = -mRadius * cosf(d.x) * cosf(d.y);
    return p;
}





@end
