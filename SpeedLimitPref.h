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
	Speed *speed;
	NSArray *rules;
	BOOL slow;
	IBOutlet NSArrayController *speedsController;
	IBOutlet NSArrayController *portsController;
	
	IBOutlet NSButton *addPortButton;
	IBOutlet NSButton *removePortButton;
	IBOutlet NSTextField *speedLimitLabel;
	IBOutlet NSTextField *portField;
	IBOutlet NSTextField *delayField;
	IBOutlet NSPopUpButton *speedField;
	IBOutlet NSButton *startStopButton;
	IBOutlet NSTableView *portsTable;
	
	AuthorizationRef authorizationRef;
}

@property (readwrite, retain) NSString *delay;
@property (readwrite, retain) Speed *speed;
@property (readwrite, retain) NSArray *rules;
@property (readwrite, retain) NSArrayController *speedsController;
@property (readwrite, retain) NSArrayController *portsController;
@property (readwrite, assign) BOOL slow;

-(void) mainViewDidLoad;

-(IBAction)addPort:(id)sender;
-(IBAction)removePort:(id)sender;
-(IBAction)toggle:(id)sender;

@end
