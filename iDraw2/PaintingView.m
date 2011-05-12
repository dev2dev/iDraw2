//
//  PaintingView.m
//  iDraw2
//
//  Created by Chris Cheung on 18/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaintingView.h"
#import <netinet/in.h>
#import <arpa/inet.h>
#import "SingletonData.h"
//#import "Matrix.h"

//#import <stdlib.h>

//CLASS IMPLEMENTATIONS:

// A class extension to declare private methods



@interface PaintingView (private)
- (void)touchesHandler:(CGFloat)x:(CGFloat)y;
- (void)touchesMovedHandler:(CGFloat)x:(CGFloat)y;
- (void)drawInContext:(CGContextRef)context;
- (void)sendDataToMCUWithRedGreenBlue;
@end

@implementation PaintingView

@synthesize matrixData=_matrixData;
@synthesize matrixBackup=_matrixBackup;
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
		self.clearsContextBeforeDrawing = YES;
        
        // init matrix contents
        [self setRedSelected:NO];
        [self setGreenSelected:NO];
        [self setBlueSelected:NO];
        
        memset(&matrixData, 0, sizeof(matrix));
        memset(&matrixBackup, 0, sizeof(matrix));
        firstSend = YES;
        // Create an empty array 
        netServices = [[NSMutableArray alloc] init]; 
        // Create a net service browser 
        serviceBrowser = [[NSNetServiceBrowser alloc] init];
        
        // As the delegate, you will be told when services are found 
        [serviceBrowser setDelegate:self]; 
        [serviceBrowser searchForServicesOfType:DESTSERV inDomain:@""];

		udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
        s = [SingletonData instance];
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
        
        [self addSubview:segmentedControl];
        // Now that the control is added, you can release it
        [segmentedControl release];
    }
    return self;
}

// initialize method when using nib
//- (id)initWithCoder:(NSCoder *)coder
//{
//    if ((self = [super initWithCoder:coder])) {
//		self.clearsContextBeforeDrawing = YES;
//        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"whitebackground.jpg"]];
//        
//        // init matrix contents
//        memset(matrixData.Red, 0, 64);
//        memset(matrixData.Green, 0, 64);
//        memset(matrixData.Blue, 0, 64);
//        [self setRedSelected:NO];
//        [self setGreenSelected:NO];
//        [self setBlueSelected:NO];
//		udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
//    }
//    return self;
//}

#pragma bonjour service

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser 
           didFindService:(NSNetService *)aNetService 
               moreComing:(BOOL)moreComing 
{ 
    NSLog(@"adding %@", aNetService); 
    // Add it to the array 
    [netServices addObject:aNetService]; 
    // Update the interface 
    NSIndexPath *ip = [NSIndexPath indexPathForRow:[netServices count] - 1 
                                         inSection:0]; 
    // Start resolution to get TXT record 
    [aNetService setDelegate:self]; 
    [aNetService resolveWithTimeout:30]; 
} 
- (void)netServiceDidResolveAddress:(NSNetService *)sender 
{ 
    // What row just resolved? 
    int row = [netServices indexOfObjectIdenticalTo:sender]; 
    NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:0]; 
    NSArray *ips = [NSArray arrayWithObject:ip]; 
    
	NSArray *addrs = [sender addresses];
	if([addrs count] > 0)
	{
		NSData *firstAddress = [addrs objectAtIndex:0];
		const struct sockaddr_in *addy = [firstAddress bytes];
		char *str = inet_ntoa(addy->sin_addr);
		NSLog(@"%s:%d", str, ntohs(addy->sin_port));
        
        [s setIpAddress: str];
        [s setPort:ntohs(addy->sin_port)];
        NSString *amsg = [[NSString alloc] initWithFormat:@"Target Board Found (%@%@local) with IP Address: %s",DESTADDR, DESTSERV, str]; 
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NetService" message:amsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
	}
}
// Called when services are lost 
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser 
         didRemoveService:(NSNetService *)aNetService 
               moreComing:(BOOL)moreComing 
{ 
    NSLog(@"removing %@", aNetService); 
    // Take it out of the array 
    NSUInteger row = [netServices indexOfObject:aNetService]; 
    if (row == NSNotFound) { 
        NSLog(@"unable to find the service in %@", netServices); 
        return; 
    } 
    [netServices removeObjectAtIndex:row]; 
    // Update the interface 
    NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:0]; 
} 



#pragma mark Draw Method
- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
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
            CGContextSetRGBFillColor(context, matrixData.Red[x][y]?1.0:0.3, matrixData.Green[x][y]?1.0:0.3, matrixData.Blue[x][y]?1.0:0.3, 1.0);
            CGContextFillEllipseInRect(context, CGRectMake(DOTOFFSETX + DOTINTERVAL * x ,DOTOFFSETY +  DOTINTERVAL * y, DOTRADIUS, DOTRADIUS));
        }
    }
}

#pragma mark Touch Event Handler
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchesBegan");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchesMoved");
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:[touch view]];
    //NSLog(@"x=%f,y=%f",currentLocation.x,currentLocation.y);
    [self touchesMovedHandler:(double) currentLocation.x :(double) currentLocation.y];
    touchesMovedCount++;
    //NSLog(@"NSNumber in moved %d", touchesMovedCount);
    [self sendDataToMCUWithRedGreenBlue];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchesEnded");
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:[touch view]];
    if ([[touches anyObject] tapCount] == 4) {
        [self erase];
    }
    else if (touchesMovedCount != 0) {
        [self touchesMovedHandler:currentLocation.x :currentLocation.y];
    }
    else{
        //NSLog(@"x=%f,y=%f",currentLocation.x,currentLocation.y);
        [self touchesHandler:currentLocation.x :currentLocation.y];
    }
    touchesMovedCount = 0;
    //NSLog(@"NSNumber %d", touchesMovedCount);
    [self sendDataToMCUWithRedGreenBlue];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchesCancelled");
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
        //NSLog(@"x=%f, y=%f, tx=%f, ty=%f, dx=%d, dy=%d\n",x, y, tempX,tempY,dotX,dotY);  
        if([self getRedSelected])
            matrixData.Red[dotX][dotY] = YES;
        else
            matrixData.Red[dotX][dotY] = NO;
        if([self getGreenSelected])
            matrixData.Green[dotX][dotY] = YES;
        else
            matrixData.Green[dotX][dotY] = NO;
        if([self getBlueSelected])
            matrixData.Blue[dotX][dotY] = YES;
        else
            matrixData.Blue[dotX][dotY] = NO;
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
        //NSLog(@"x=%f, y=%f, tx=%f, ty=%f, dx=%d, dy=%d\n",x, y, tempX,tempY,dotX,dotY);  
        
        // map adjusted coordinates to matrix
        if([self getRedSelected])
            matrixData.Red[dotX][dotY] = YES;
        else
            matrixData.Red[dotX][dotY] = NO;
        if([self getGreenSelected])
            matrixData.Green[dotX][dotY] = YES;
        else
            matrixData.Green[dotX][dotY] = NO;
        if([self getBlueSelected])
            matrixData.Blue[dotX][dotY] = YES;
        else
            matrixData.Blue[dotX][dotY] = NO;
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
    memset(matrixData.Red, 0, 64);
    memset(matrixData.Green, 0, 64);
    memset(matrixData.Blue, 0, 64);
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

- (void)sendDataToMCUWithRedGreenBlue
{
	unsigned char message[26];
    unsigned char dataToSend[26];
    message[0] = 0x26;
    for(int y = 0; y < DOTMAXHEIGHT; y++){
        if (matrixData.Red[0][y] == 1)
            dataToSend[y+1] |= 0x80;
        else
            dataToSend[y+1] &= 0x7f;
        if (matrixData.Red[1][y] == 1)
            dataToSend[y+1] |= 0x40;
        else
            dataToSend[y+1] &= 0xbf;
        if (matrixData.Red[2][y] == 1)
            dataToSend[y+1] |= 0x20;
        else
            dataToSend[y+1] &= 0xdf;
        if (matrixData.Red[3][y] == 1)
            dataToSend[y+1] |= 0x10;
        else
            dataToSend[y+1] &= 0xef;
        if (matrixData.Red[4][y] == 1)
            dataToSend[y+1] |= 0x08;
        else
            dataToSend[y+1] &= 0xf7;
        if (matrixData.Red[5][y] == 1)
            dataToSend[y+1] |= 0x04;
        else
            dataToSend[y+1] &= 0xfb;
        if (matrixData.Red[6][y] == 1)
            dataToSend[y+1] |= 0x02;
        else
            dataToSend[y+1] &= 0xfd;
        if (matrixData.Red[7][y] == 1)
            dataToSend[y+1] |= 0x01;
        else
            dataToSend[y+1] &= 0xfe;
        message[1+y]=dataToSend[y+1];
    }
    for(int y = 0; y < DOTMAXHEIGHT; y++){
        if (matrixData.Green[0][y] == 1)
            dataToSend[y+1] |= 0x80;
        else
            dataToSend[y+1] &= 0x7f;
        if (matrixData.Green[1][y] == 1)
            dataToSend[y+1] |= 0x40;
        else
            dataToSend[y+1] &= 0xbf;
        if (matrixData.Green[2][y] == 1)
            dataToSend[y+1] |= 0x20;
        else
            dataToSend[y+1] &= 0xdf;
        if (matrixData.Green[3][y] == 1)
            dataToSend[y+1] |= 0x10;
        else
            dataToSend[y+1] &= 0xef;
        if (matrixData.Green[4][y] == 1)
            dataToSend[y+1] |= 0x08;
        else
            dataToSend[y+1] &= 0xf7;
        if (matrixData.Green[5][y] == 1)
            dataToSend[y+1] |= 0x04;
        else
            dataToSend[y+1] &= 0xfb;
        if (matrixData.Green[6][y] == 1)
            dataToSend[y+1] |= 0x02;
        else
            dataToSend[y+1] &= 0xfd;
        if (matrixData.Green[7][y] == 1)
            dataToSend[y+1] |= 0x01;
        else
            dataToSend[y+1] &= 0xfe;
        message[9+y]=dataToSend[y+1];
    }
    for(int y = 0; y < DOTMAXHEIGHT; y++){
        if (matrixData.Blue[0][y] == 1)
            dataToSend[y+1] |= 0x80;
        else
            dataToSend[y+1] &= 0x7f;
        if (matrixData.Blue[1][y] == 1)
            dataToSend[y+1] |= 0x40;
        else
            dataToSend[y+1] &= 0xbf;
        if (matrixData.Blue[2][y] == 1)
            dataToSend[y+1] |= 0x20;
        else
            dataToSend[y+1] &= 0xdf;
        if (matrixData.Blue[3][y] == 1)
            dataToSend[y+1] |= 0x10;
        else
            dataToSend[y+1] &= 0xef;
        if (matrixData.Blue[4][y] == 1)
            dataToSend[y+1] |= 0x08;
        else
            dataToSend[y+1] &= 0xf7;
        if (matrixData.Blue[5][y] == 1)
            dataToSend[y+1] |= 0x04;
        else
            dataToSend[y+1] &= 0xfb;
        if (matrixData.Blue[6][y] == 1)
            dataToSend[y+1] |= 0x02;
        else
            dataToSend[y+1] &= 0xfd;
        if (matrixData.Blue[7][y] == 1)
            dataToSend[y+1] |= 0x01;
        else
            dataToSend[y+1] &= 0xfe;
        message[17+y]=dataToSend[y+1];
    }
    message[25]=0xff;
    if (memcmp(&matrixData, &matrixBackup, sizeof(matrix)) || firstSend == YES) {
        firstSend = NO;
        memcpy(&matrixBackup, &matrixData, sizeof(matrix));
        NSData *data = [NSData dataWithBytes:message length:sizeof(message)];
        mcuAddress = nil;
        mcuAddress = [[NSString alloc] initWithCString:[s getIpAddress] encoding:NSASCIIStringEncoding];
        mcuPort = [s getPort];
        if(![udpSocket sendData:data toHost:mcuAddress port:mcuPort withTimeout:-1 tag:1])		
            NSLog(@"Send failed.\n");
    }
}

#pragma segmentedControl Event
// Change the brush color
- (void)changeBrushColor:(id)sender
{
    BOOL red, green, blue;
    NSLog(@"changeBrushColor index = %d", [sender selectedSegmentIndex]);
	// Play sound
 	//[selectSound play];
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
    [self setBrushColorWithRed:red green:green blue:blue];
}

@end
