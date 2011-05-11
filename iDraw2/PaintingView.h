//
//  PaintingView.h
//  iDraw2
//
//  Created by Chris Cheung on 18/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncUdpSocket.h"
#import "AppController.h"
#import <QuartzCore/QuartzCore.h> 

//CONSTANT

#define DOTRADIUS 30.0
#define DOTOFFSETX 30.0
#define DOTOFFSETY 60.0
#define DOTINTERVAL 32.0
#define DOTMAXHEIGHT 8
#define DOTMAXWIDTH 8

#define kPaletteHeight			30
#define kPaletteSize			5
#define kMinEraseInterval		0.1

// Padding for margins
#define kLeftMargin				10.0
#define kTopMargin				60.0
#define kRightMargin			10.0

//CLASS INTERFACES:

@interface PaintingView : UIView <NSNetServiceDelegate, NSNetServiceBrowserDelegate> 
{
@private
    BOOL matrixRed[8][8];
    BOOL matrixGreen[8][8];
    BOOL matrixBlue[8][8];
    BOOL needsErase;
    NSNumber *redSelected;
    NSNumber *greenSelected;
    NSNumber *blueSelected;
    
    NSInteger touchesMovedCount;
    AsyncUdpSocket *udpSocket;
    NSNetServiceBrowser *serviceBrowser;
    NSMutableArray *netServices; 
    
    NSString *mcuAddress;
    int mcuPort;
}

@property (readwrite) BOOL matrixRed;
@property (readwrite) BOOL matrixGreen;
@property (readwrite) BOOL matrixBlue;

@property (nonatomic, retain) NSNumber *redSelected;
@property (nonatomic, retain) NSNumber *greenSelected;
@property (nonatomic, retain) NSNumber *blueSelected;

@property (nonatomic, retain) NSNumber *touchesMovedCount;


// As a matter of convinience we'll do all of our drawing here in subclasses of QuartzView.
- (void)erase;
- (void)setBrushColorWithRed:(BOOL)red green:(BOOL)green blue:(BOOL)blue;

- (void)setRedSelected:(NSNumber *)red;
- (void)setGreenSelected:(NSNumber *)green;
- (void)setBlueSelected:(NSNumber *)blue;

- (BOOL)getRedSelected;
- (BOOL)getGreenSelected;
- (BOOL)getBlueSelected;

@end
