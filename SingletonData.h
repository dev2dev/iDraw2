//
//  SingletonData.h
//  iDraw2
//
//  Created by Chris Cheung on 12/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SingletonData : NSObject {
	char ipAddress[16];
    int port;
}

+ (SingletonData *) instance;
//@property (readwrite) char *ipAddress;
//@property (readwrite) int port;

- (void) setIpAddress :(char *) addr;
- (void) setPort : (int) aport;
- (char *) getIpAddress;
- (int) getPort;

@end
