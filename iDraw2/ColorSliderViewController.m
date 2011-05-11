//
//  ColorSliderViewController.m
//  iDraw2
//
//  Created by Chris Cheung on 06/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ColorSliderViewController.h"


@implementation ColorSliderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
        
        // Get the tab bar item
        UITabBarItem *tbi = [self tabBarItem];
        
        // Give it a label
        [tbi setTitle:@"Slider"];
        UIImage *i = [UIImage imageNamed:@"Chat-Bubble.png"];
        [tbi setImage:i];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark -
#pragma mark IBActions

- (IBAction) redSliderChanged:(id)sender{
	UISlider *slider = (UISlider *)sender;
	
	UIImage *redSliderImage = [[UIImage alloc] initWithContentsOfFile:@"redslider.png"];
	[redColorSlider setMinimumTrackImage:redSliderImage forState:UIControlStateSelected];
	
	unsigned char valueInInt = (unsigned char)(slider.value + 0.5f);
	unsigned char dataToSend[3] = {0x20, 0xff, 0xff};
	
	NSString *valueInString = [[NSString alloc] initWithFormat:@"%d", valueInInt];
	[redValueLabel setText:valueInString];
	
	if (valueInInt % 4 == 0 && valueInInt != 0) {
		if(valueInInt < 16)
			dataToSend[1] = 0x00;
		else if(valueInInt > 239)
			dataToSend[1] = 0x0f;
		else {
			valueInInt = (unsigned char) (valueInInt / 16 + 0.5f);
			dataToSend[1] = valueInInt;
		}
		NSData *data = [NSData dataWithBytes:dataToSend length:sizeof(dataToSend)];
		if(![udpSocket sendData:data toHost:DESTADDR port:7777 withTimeout:-1 tag:1])		
			NSLog(@"Send failed.\n");
	}
	
	[valueInString release];
}

- (IBAction) greenSliderChanged:(id)sender{
	UISlider *slider = (UISlider *)sender;
	
	unsigned char valueInInt = (unsigned char)(slider.value + 0.5f);
	unsigned char dataToSend[3] = {0x21, 0xff, 0xff};
	
	NSString *valueInString = [[NSString alloc] initWithFormat:@"%d", valueInInt];
	[greenValueLabel setText:valueInString];
	
	if (valueInInt % 4 == 0 && valueInInt != 0) {
		if(valueInInt < 16)
			dataToSend[1] = 0x00;
		else if(valueInInt > 239)
			dataToSend[1] = 0x0f;
		else {
			valueInInt = (unsigned char) (valueInInt / 16 + 0.5f);
			dataToSend[1] = valueInInt;
		}
		NSData *data = [NSData dataWithBytes:dataToSend length:sizeof(dataToSend)];
		if(![udpSocket sendData:data toHost:DESTADDR port:7777 withTimeout:-1 tag:1])		
			NSLog(@"Send failed.\n");
	}
	
	[valueInString release];
}

- (IBAction) blueSliderChanged:(id)sender{
	UISlider *slider = (UISlider *)sender;
	
	unsigned char valueInInt = (unsigned char)(slider.value + 0.5f);
	unsigned char dataToSend[3] = {0x22, 0xff, 0xff};
	
	NSString *valueInString = [[NSString alloc] initWithFormat:@"%d", valueInInt];
	[blueValueLabel setText:valueInString];
	
	if (valueInInt % 4 == 0 && valueInInt != 0) {
		if(valueInInt < 16)
			dataToSend[1] = 0x00;
		else if(valueInInt > 239)
			dataToSend[1] = 0x0f;
		else {
			valueInInt = (unsigned char) (valueInInt / 16 + 0.5f);
			dataToSend[1] = valueInInt;
		}
		NSData *data = [NSData dataWithBytes:dataToSend length:sizeof(dataToSend)];
		if(![udpSocket sendData:data toHost:DESTADDR port:7777 withTimeout:-1 tag:1])		
			NSLog(@"Send failed.\n");
	}
	
	[valueInString release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
