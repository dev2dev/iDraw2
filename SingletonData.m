//
//  SingletonData.m
//  iDraw2
//
//  Created by Chris Cheung on 12/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SingletonData.h"


@implementation SingletonData

//@synthesize ipAddress=_ipAddress;
//@synthesize port;


static SingletonData *_instance;


+ (SingletonData *) instance{
	if (!_instance) {
		_instance = [[SingletonData alloc] init];
	}
	return _instance;
}

- (id) init{
	if (self = [super init]) {
	}
	return self;
}

- (void) dealloc{
	[super dealloc];
}

- (void) setPort:(int)aport{
    port = aport;
    NSLog(@"Set port number: %d", port);
}

- (void) setIpAddress:(char *)addr{
    memset(ipAddress, 0, sizeof(ipAddress));
    strcpy(ipAddress, addr);
    NSLog(@"Set ip address: %s", ipAddress);
}

- (char *) getIpAddress {
    return ipAddress;
}

- (int) getPort {
    return port;
}

@end
