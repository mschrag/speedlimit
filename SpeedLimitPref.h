//
//  SpeedLimitPref.h
//  SpeedLimit
//
//  Created by Michael Schrag on 8/27/08.
//  Copyright (c) 2008 m Dimension Technology. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import <SecurityInterface/SFAuthorizationView.h>
#import "Speed.h"

@interface SpeedLimitPref : NSPreferencePane {
	NSString *delay;
	NSString *hosts;
	Speed *speed;
	NSArray *rules;
	BOOL slow;
	double packetLossRatio;
	BOOL packetLossErrorSuppress;
	
	NSArrayController *speedsController;
	NSArrayController *portsController;
	NSTextField *speedLimitLabel;
	NSTableView *portsView;
	NSTextField *hostsTextField;
	NSTextField *delayTextField;
	NSPopUpButton *speedsPopUpButton;
	NSButton *addButton;
	NSButton *removeButton;
	NSButton *startStopButton;
	
	AuthorizationRef authorizationRef;
	
	NSInteger authorizationState;
	SFAuthorizationView *authorizationView;
}

@property (readwrite, retain) NSString *delay;
@property (readwrite, retain) NSString *hosts;
@property (readwrite, retain) Speed *speed;
@property (readwrite, retain) NSArray *rules;
@property (readwrite, assign) BOOL slow;
@property (readwrite, assign) double packetLossRatio;
@property (readwrite, assign) BOOL packetLossErrorSuppress;

@property (readwrite, retain) IBOutlet NSArrayController *speedsController;
@property (readwrite, retain) IBOutlet NSArrayController *portsController;
@property (readwrite, retain) IBOutlet NSTextField *speedLimitLabel;
@property (readwrite, retain) IBOutlet NSTableView *portsView;
@property (readwrite, retain) IBOutlet NSTextField *hostsTextField;
@property (readwrite, retain) IBOutlet NSTextField *delayTextField;
@property (readwrite, retain) IBOutlet NSPopUpButton *speedsPopUpButton;
@property (readwrite, retain) IBOutlet NSButton *addButton;
@property (readwrite, retain) IBOutlet NSButton *removeButton;
@property (readwrite, retain) IBOutlet NSButton *startStopButton;
@property (readwrite, retain) IBOutlet SFAuthorizationView *authorizationView;

-(void) mainViewDidLoad;

-(IBAction)addPort:(id)sender;
-(IBAction)removePort:(id)sender;
-(IBAction)toggle:(id)sender;

@end
