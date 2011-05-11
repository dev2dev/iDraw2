//
//  iDraw2AppDelegate.h
//  iDraw2
//
//  Created by Chris Cheung on 06/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define DESTSERV @"_idraw._udp."
#define DESTADDR @"MCHPPIC18."

@interface iDraw2AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *windows;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
