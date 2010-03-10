//
//  SpeedLimitWindowController.m
//  SpeedLimit
//
//  Created by Jamie Pinkham on 3/8/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SpeedLimitWindowController.h"
#import "SLPort.h"
#import <Security/Authorization.h>
#import <Security/AuthorizationTags.h>

@interface SpeedLimitWindowController(PrivateMethods)

- (void)enableInterfaces:(BOOL)enable;

@end

@implementation SpeedLimitWindowController

@synthesize speedLimiter;
@synthesize portsController;
@synthesize speedLimitLabel;
@synthesize portsView;
@synthesize hostsTextField;
@synthesize delayTextField;
@synthesize speedsPopUpButton;
@synthesize addButton;
@synthesize removeButton;
@synthesize startStopButton;
@synthesize authorizationView;

- (void)awakeFromNib{
    [portsController setContent:[[self speedLimiter] ports]];
    if (authorizationView) {
        
		const char *path = [[[self speedLimiter] speedLimiterPath] fileSystemRepresentation];
		AuthorizationItem right = { kAuthorizationRightExecute, strlen(path), (char *)path, 0 };
		AuthorizationRights rights = { 1, &right };
		
		[authorizationView setDelegate:self];
		[authorizationView setAuthorizationRights:&rights];
		[authorizationView updateStatus:self];
	}
    
	[self enableInterfaces:NO];

    if([[self speedLimiter] slow]){
        [speedLimitLabel setStringValue:[NSString stringWithFormat:@"%ld", self.speedLimiter.currentSpeed.speed]];
        [startStopButton setTitle:@"Speed Up"];
    }else{
        [speedLimitLabel setStringValue:@"-"];
        [startStopButton setTitle:@"Slow Down"];
    }
    [super awakeFromNib];
}

-(IBAction)addPort:(id)sender {
    SLPort *newPort = [[SLPort alloc] initWithPort:1000];
	//[[self speedLimiter] addPort:newPort];
    [portsController addObject:newPort];
    [newPort release];
}

-(IBAction)removePort:(id)sender {
    //[[self speedLimiter] removePorts:[portsController selectedObjects]];
    [portsController removeObjects:[portsController selectedObjects]];
	//[[self speedLimiter] removePorts:[portsView selectedObjects]];
}



-(IBAction)toggle:(id)sender {
    Speed *s = [[[self speedLimiter] speeds] objectAtIndex:[speedsPopUpButton indexOfSelectedItem]];
    [[self speedLimiter] setCurrentSpeed:s];
    [[self speedLimiter] toggle];
    if([[self speedLimiter] slow]){
        [speedLimitLabel setStringValue:[NSString stringWithFormat:@"%ld", self.speedLimiter.currentSpeed.speed]];
        [startStopButton setTitle:@"Speed Up"];
    }else{
        [speedLimitLabel setStringValue:@"-"];
        [startStopButton setTitle:@"Slow Down"];
    }
}

- (void)enableInterfaces:(BOOL)enable {
    
	[portsView setEnabled:enable];
	[hostsTextField setEnabled:enable];
	[delayTextField setEnabled:enable];
	[speedsPopUpButton setEnabled:enable];
	[addButton setEnabled:enable];
	[removeButton setEnabled:enable];
	[startStopButton setEnabled:enable];
	
	if (!enable)
		[startStopButton setTitle:@"-"];
    else{
        if([[self speedLimiter] slow]){
            [startStopButton setTitle:@"Speed Up"];
        }else{
            [startStopButton setTitle:@"Slow Down"];
        }
    }
}



- (void)dealloc{
	[speedLimitLabel release];
	[portsView release];
	[hostsTextField release];
	[delayTextField release];
	[speedsPopUpButton release];
	[addButton release];
	[removeButton release];
	[startStopButton release];
	
	[authorizationView release];
	
	[super dealloc];
}



#pragma mark SFAuthorizationView delegate methods

- (void)authorizationViewCreatedAuthorization:(SFAuthorizationView *)view {
	
	AuthorizationRef authorizationRef = [[view authorization] authorizationRef];
    [[self speedLimiter] setAuthorizationRef:authorizationRef];
}

- (void)authorizationViewDidAuthorize:(SFAuthorizationView *)view {
	
	//[self refreshRules];
	
	[self enableInterfaces:YES];
}

- (void)authorizationViewDidDeauthorize:(SFAuthorizationView *)view {
	
	[self enableInterfaces:NO];
}

- (void)authorizationViewReleasedAuthorization:(SFAuthorizationView *)view {
	[[self speedLimiter] releaseAuthorization];
}

- (BOOL)authorizationViewShouldDeauthorize:(SFAuthorizationView *)view {
    
	return YES;
}

@end
