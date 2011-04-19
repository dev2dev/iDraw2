//
//  iDraw2AppDelegate.m
//  iDraw2
//
//  Created by Chris Cheung on 18/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "PaintingView.h"
#import "SoundEffect.h"

//CONSTANTS:

#define kPaletteHeight			30
#define kPaletteSize			5
#define kMinEraseInterval		0.1

// Padding for margins
#define kLeftMargin				10.0
#define kTopMargin				10.0
#define kRightMargin			10.0


//CLASS IMPLEMENTATIONS:
@implementation AppController

@synthesize window;
@synthesize drawingView;


- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
	// Create a segmented control so that the user can choose the brush color.
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"Red.png"],
                                             [UIImage imageNamed:@"Yellow.png"],
                                             [UIImage imageNamed:@"Green.png"],
                                             [UIImage imageNamed:@"Blue.png"],
                                             [UIImage imageNamed:@"Cyan.png"],
                                             [UIImage imageNamed:@"Purple.png"],
                                             [UIImage imageNamed:@"White.png"],
                                             nil]];
	
	// Compute a rectangle that is positioned correctly for the segmented control you'll use as a brush color palette
	CGRect frame = CGRectMake(rect.origin.x + kLeftMargin, rect.size.height - kPaletteHeight - kTopMargin, rect.size.width - (kLeftMargin + kRightMargin), kPaletteHeight);
	segmentedControl.frame = frame;
	// When the user chooses a color, the method changeBrushColor: is called.
	[segmentedControl addTarget:self action:@selector(changeBrushColor:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	// Make sure the color of the color complements the black background
	segmentedControl.tintColor = [UIColor darkGrayColor];
	// Set the third color (index values start at 0)
	segmentedControl.selectedSegmentIndex = 3;
	
	// Add the control to the window
	[window addSubview:segmentedControl];
	// Now that the control is added, you can release it
	[segmentedControl release];
    [drawingView setBrushColorWithRed:NO green:NO blue:YES];
	// Look in the Info.plist file and you'll see the status bar is hidden
	// Set the style to black so it matches the background of the application
	[application setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
	// Now show the status bar, but animate to the style.
	[application setStatusBarHidden:NO withAnimation:YES];
	
	// Load the sounds
	NSBundle *mainBundle = [NSBundle mainBundle];	
	erasingSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Erase" ofType:@"caf"]];
	selectSound =  [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Select" ofType:@"caf"]];
    
	// Erase the view when recieving a notification named "shake" from the NSNotificationCenter object
	// The "shake" nofification is posted by the PaintingWindow object when user shakes the device
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eraseView) name:@"shake" object:nil];
}

- (void)dealloc
{
	[selectSound release];
	[erasingSound release];
	[drawingView release];
    [window release];
    [super dealloc];
}


// Change the brush color
- (void)changeBrushColor:(id)sender
{
    BOOL red, green, blue;
    NSLog(@"changeBrushColor index = %d", [sender selectedSegmentIndex]);
	// Play sound
 	[selectSound play];
    switch ([sender selectedSegmentIndex]) {
            // Red Segment selected
        case 0:
            red = YES;
            green = NO;
            blue = NO;
            break;
            // Yellow Segment selected
        case 1:
            red = YES;
            green = YES;
            blue = NO;
            break;
            // Green Segment selected
        case 2:
            red = NO;
            green = YES;
            blue = NO;
            break;
            // Blue Segment selected
        case 3:
            red = NO;
            green = NO;
            blue = YES;
            break;
            // Cyan Segment selected
        case 4:
            red = NO;
            green = YES;
            blue = YES;
            break;
            // Purple Segment selected
        case 5:
            red = YES;
            green = NO;
            blue = YES;
            break;
            // White Segment selected
        case 6:
            red = YES;
            green = YES;
            blue = YES;
            break;
        default:
            red = NO;
            green = NO;
            blue = NO;
            break;
    }	
    [drawingView setBrushColorWithRed:red green:green blue:blue];
}


// Called when receiving the "shake" notification; plays the erase sound and redraws the view
-(void) eraseView
{
	if(CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval) {
		[erasingSound play];
		[drawingView erase];
		lastTime = CFAbsoluteTimeGetCurrent();
	}
}


@end
