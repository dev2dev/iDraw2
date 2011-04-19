//
//  PaintingView.m
//  iDraw2
//
//  Created by Chris Cheung on 18/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PaintingView.h"
//#import "Matrix.h"

//#import <stdlib.h>

//CLASS IMPLEMENTATIONS:

// A class extension to declare private methods

@interface PaintingView (private)
- (void)touchesHandler:(CGFloat)x:(CGFloat)y;
- (void)touchesMovedHandler:(CGFloat)x:(CGFloat)y;
- (void)drawInContext:(CGContextRef)context;
@end

@implementation PaintingView

@synthesize matrixRed=_matrixRed;
@synthesize matrixGreen=_matrixGreen;
@synthesize matrixBlue=_matrixBlue;
@synthesize redSelected;
@synthesize greenSelected;
@synthesize blueSelected;
@synthesize touchesMovedCount=_touchesMovedCount;


#pragma mark Initialize UIView
// initWithFrame never being called, if UI view was created in nib file
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor grayColor];        
    }
    return self;
}

// initialize method when using nib
- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
		self.clearsContextBeforeDrawing = YES;
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"whitebackground.jpg"]];
        
        // init matrix contents
        memset(matrixRed, 0, 64);
        memset(matrixGreen, 0, 64);
        memset(matrixBlue, 0, 64);
        [self setRedSelected:NO];
        [self setGreenSelected:NO];
        [self setBlueSelected:NO];
    }
    return self;
}


#pragma mark Draw Method
- (void)drawInContext:(CGContextRef)context{
    NSLog(@"drawInContext");
    // CGContextRef context = UIGraphicsGetCurrentContext();
	// Drawing with a white stroke color
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	// And draw with a blue fill color
	// Draw them with a 2.0 stroke width so they are a bit more visible.
	CGContextSetLineWidth(context, 2.0);
    
	// Fill rect convenience equivalent to AddEllipseInRect(); FillPath();
    for (int x = 0; x < 8; x++) {
        for (int y = 0; y < 8; y++) {
            CGContextSetRGBFillColor(context, matrixRed[x][y]?1.0:0.3, matrixGreen[x][y]?1.0:0.3, matrixBlue[x][y]?1.0:0.3, 1.0);
            CGContextFillEllipseInRect(context, CGRectMake(DOTOFFSETX + DOTINTERVAL * x ,DOTOFFSETY +  DOTINTERVAL * y, DOTRADIUS, DOTRADIUS));
        }
    }
}

#pragma mark Touch Event Handler
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesMoved");
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:[touch view]];
    NSLog(@"x=%f,y=%f",currentLocation.x,currentLocation.y);
    [self touchesMovedHandler:(double) currentLocation.x :(double) currentLocation.y];
    touchesMovedCount++;
    NSLog(@"NSNumber in moved %d", touchesMovedCount);
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesEnded");
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:[touch view]];
    if ([[touches anyObject] tapCount] == 4) {
        [self erase];
    }
    else if (touchesMovedCount != 0) {
        [self touchesMovedHandler:currentLocation.x :currentLocation.y];
    }
    else{
        NSLog(@"x=%f,y=%f",currentLocation.x,currentLocation.y);
        [self touchesHandler:currentLocation.x :currentLocation.y];
    }
    touchesMovedCount = 0;
    NSLog(@"NSNumber %d", touchesMovedCount);
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesCancelled");
}
- (void)touchesHandler:(CGFloat)x :(CGFloat)y{
    if((x > 32.0 && x < 287.0) && (y > 62.0 && y < 313.0)){
        double tempX = ((double)x - DOTOFFSETX) / DOTRADIUS;
        double tempY = ((double)y - DOTOFFSETY) / DOTRADIUS;
        int dotX = (int)tempX, dotY = (int)tempY;
        //NSLog(@"111 %d %d %d",[self getRedSelected]?1:0,[self getGreenSelected]?1:0,[self getBlueSelected]?1:0);
        if(tempX < (int)tempX+1){
            if((int)tempX+1 - tempX < 0.5)
                dotX = (int)tempX+1;
        }
        if (tempX > (int)tempX){
            if(tempX - (int) tempX < 0.5)
                dotX = (int)tempX;
        }
        
        if(tempY < (int)tempY+1){
            if((int)tempY+1 - tempY < 0.5)
                dotY = (int)tempY+1;
        }
        if (tempY > (int)tempY){
            if(tempY - (int) tempY < 0.5)
                dotY = (int)tempY;
        }
        switch (dotX) {
            case 0:
                dotX;
                break;
            case 9:
                dotX = 7;
            default:
                dotX--;
                break;
        }
        switch (dotY) {
            case 0:
                dotY;
                break;
            case 9:
                dotY = 7;
            default:
                dotY--;
                break;
        }
        NSLog(@"x=%f, y=%f, tx=%f, ty=%f, dx=%d, dy=%d\n",x, y, tempX,tempY,dotX,dotY);  
        if([self getRedSelected]){
            if (matrixRed[dotX][dotY]) {
                matrixRed[dotX][dotY] = NO;
            }
            else
            matrixRed[dotX][dotY] = YES;
        }
        else
            matrixRed[dotX][dotY] = NO;
        if([self getGreenSelected]){
            if (matrixGreen[dotX][dotY]) {
                matrixGreen[dotX][dotY] = NO;
            }
            else
            matrixGreen[dotX][dotY] = YES;
        }
        else
            matrixGreen[dotX][dotY] = NO;
        if([self getBlueSelected]){
            if (matrixBlue[dotX][dotY]) {
                matrixBlue[dotX][dotY] = NO;
            }
            else
            matrixBlue[dotX][dotY] = YES;
        }
        else
            matrixBlue[dotX][dotY] = NO;
    }
}

- (void)touchesMovedHandler:(CGFloat)x :(CGFloat)y{
    if((x > 32.0 && x < 287.0) && (y > 62.0 && y < 313.0)){
        
        // Adjust touch coordinate
        double tempX = ((double)x - DOTOFFSETX) / DOTRADIUS;
        double tempY = ((double)y - DOTOFFSETY) / DOTRADIUS;
        int dotX = (int)tempX, dotY = (int)tempY;
        //NSLog(@"111 %d %d %d",[self getRedSelected]?1:0,[self getGreenSelected]?1:0,[self getBlueSelected]?1:0);
        if(tempX < (int)tempX+1){
            if((int)tempX+1 - tempX < 0.5)
                dotX = (int)tempX+1;
        }
        if (tempX > (int)tempX){
            if(tempX - (int) tempX < 0.5)
                dotX = (int)tempX;
        }
        
        if(tempY < (int)tempY+1){
            if((int)tempY+1 - tempY < 0.5)
                dotY = (int)tempY+1;
        }
        if (tempY > (int)tempY){
            if(tempY - (int) tempY < 0.5)
                dotY = (int)tempY;
        }
        switch (dotX) {
            case 0:
                dotX;
                break;
            case 9:
                dotX = 7;
            default:
                dotX--;
                break;
        }
        switch (dotY) {
            case 0:
                dotY;
                break;
            case 9:
                dotY = 7;
            default:
                dotY--;
                break;
        }
        NSLog(@"x=%f, y=%f, tx=%f, ty=%f, dx=%d, dy=%d\n",x, y, tempX,tempY,dotX,dotY);  
        
        // map adjusted coordinates to matrix
        if([self getRedSelected])
            matrixRed[dotX][dotY] = YES;
        else
            matrixRed[dotX][dotY] = NO;
        if([self getGreenSelected])
            matrixGreen[dotX][dotY] = YES;
        else
            matrixGreen[dotX][dotY] = NO;
        if([self getBlueSelected])
            matrixBlue[dotX][dotY] = YES;
        else
            matrixBlue[dotX][dotY] = NO;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)erase{
    NSLog(@"Triple Tap");
    memset(matrixRed, 0, 64);
    memset(matrixGreen, 0, 64);
    memset(matrixBlue, 0, 64);
}

- (void)dealloc
{
    [super dealloc];
}



- (void)setBrushColorWithRed:(BOOL)red green:(BOOL)green blue:(BOOL)blue{
    NSLog(@"setBrushColorWithRed");
//    NSLog(@"setBrushColorWithRed red = %d, green = %d, blue = %d",redSelected?1:0,greenSelected?1:0,blueSelected?1:0);
    NSNumber *redTemp = [NSNumber numberWithBool:red];
    NSNumber *greenTemp = [NSNumber numberWithBool:green];
    NSNumber *blueTemp = [NSNumber numberWithBool:blue];
    [self setRedSelected:redTemp];
    [self setGreenSelected:greenTemp];
    [self setBlueSelected:blueTemp];
    NSLog(@"setBrushColorWithRed %d %d %d",[self getRedSelected]?1:0,[self getGreenSelected]?1:0,[self getBlueSelected]?1:0);
    [redTemp release];
    [greenTemp release];
    [blueTemp release];
}


- (void)setRedSelected:(NSNumber *)red{
    redSelected = [NSNumber numberWithBool:NO];
    redSelected = red;
}

- (void)setGreenSelected:(NSNumber *)green{
    greenSelected = [NSNumber numberWithBool:NO];
    greenSelected = green;
}

- (void)setBlueSelected:(NSNumber *)blue{
    blueSelected = [NSNumber numberWithBool:NO];
    blueSelected = blue;
}

- (BOOL)getRedSelected{
    return [redSelected boolValue];
}

- (BOOL)getGreenSelected{
    return [greenSelected boolValue];
}

- (BOOL)getBlueSelected{
    return [blueSelected boolValue];
}

@end
