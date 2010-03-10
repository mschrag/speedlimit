//
//  SpeedLimitWindowController.h
//  SpeedLimit
//
//  Created by Jamie Pinkham on 3/8/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SecurityInterface/SFAuthorizationView.h>
#import "SpeedLimiter.h"

@interface SpeedLimitWindowController : NSWindowController <NSWindowDelegate> {
    
    SpeedLimiter *speedLimiter;
    NSArrayController *portsController;
	NSTextField *speedLimitLabel;
	NSTableView *portsView;
	NSTextField *hostsTextField;
	NSTextField *delayTextField;
	NSPopUpButton *speedsPopUpButton;
	NSButton *addButton;
	NSButton *removeButton;
	NSButton *startStopButton;
	
	SFAuthorizationView *authorizationView;
}
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
@property (readwrite, retain) SpeedLimiter *speedLimiter;

-(IBAction)addPort:(id)sender;
-(IBAction)removePort:(id)sender;
-(IBAction)toggle:(id)sender;

@end
