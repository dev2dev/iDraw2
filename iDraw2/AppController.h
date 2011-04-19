//
//  iDraw2AppDelegate.h
//  iDraw2
//
//  Created by Chris Cheung on 18/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PaintingWindow;
@class PaintingView;
@class SoundEffect;

@interface AppController : NSObject <UIApplicationDelegate> {
	PaintingWindow		*window;
	PaintingView		*drawingView;
    
	SoundEffect			*erasingSound;
	SoundEffect			*selectSound;
	CFTimeInterval		lastTime;
}

@property (nonatomic, retain) IBOutlet PaintingWindow *window;
@property (nonatomic, retain) IBOutlet PaintingView *drawingView;


@end
