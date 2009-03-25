//
//  SpeedLimitPref.h
//  SpeedLimit
//
//  Created by Michael Schrag on 8/27/08.
//  Copyright (c) 2008 m Dimension Technology. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import "Speed.h"

@interface SpeedLimitPref : NSPreferencePane {
	NSString *delay;
	NSString *hosts;
	Speed *speed;
	NSArray *rules;
	BOOL slow;
	
	NSArrayController *speedsController;
	NSArrayController *portsController;
	NSTextField *speedLimitLabel;
	NSButton *startStopButton;
	
	AuthorizationRef authorizationRef;
}

@property (readwrite, retain) NSString *delay;
@property (readwrite, retain) NSString *hosts;
@property (readwrite, retain) Speed *speed;
@property (readwrite, retain) NSArray *rules;
@property (readwrite, assign) BOOL slow;

@property (readwrite, retain) IBOutlet NSArrayController *speedsController;
@property (readwrite, retain) IBOutlet NSArrayController *portsController;
@property (readwrite, retain) IBOutlet NSTextField *speedLimitLabel;
@property (readwrite, retain) IBOutlet NSButton *startStopButton;

-(void) mainViewDidLoad;

-(IBAction)addPort:(id)sender;
-(IBAction)removePort:(id)sender;
-(IBAction)toggle:(id)sender;

@end
