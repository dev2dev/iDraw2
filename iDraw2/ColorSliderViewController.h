//
//  ColorSliderViewController.h
//  iDraw2
//
//  Created by Chris Cheung on 06/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncUdpSocket.h"
#import "AppController.h"
#import "SingletonData.h"

@interface ColorSliderViewController : UIViewController {
	AsyncUdpSocket *udpSocket;
	
	IBOutlet UILabel *networkStatusLabel;
	
	IBOutlet UILabel *redValueLabel;
	IBOutlet UILabel *greenValueLabel;
	IBOutlet UILabel *blueValueLabel;
	
	IBOutlet UISlider *redColorSlider;
	IBOutlet UISlider *greenColorSlider;
	IBOutlet UISlider *blueColorSlider;
    
    SingletonData *s;
    NSString *mcuAddress;
    int mcuPort;
}


- (IBAction)redSliderChanged:(id)sender;
- (IBAction)greenSliderChanged:(id)sender;
- (IBAction)blueSliderChanged:(id)sender;

@end
