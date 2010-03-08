//
//  SpeedLimitAppDelegate.m
//  SpeedLimit
//
//  Created by Jamie Pinkham on 3/8/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SpeedLimitAppDelegate.h"
#import "SpeedLimitWindowController.h"


@implementation SpeedLimitAppDelegate

- (NSString *)speedLimiterPath{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *speedLimiterPath = [[bundle resourcePath] stringByAppendingPathComponent:@"SpeedLimiter"];
	return speedLimiterPath;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    speedLimiter = [[SpeedLimiter alloc] init];
	item = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
    
    NSBundle *bundle = [NSBundle mainBundle];
    
    image = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"SpeedLimitPref" ofType:@"tiff"]];
    
    [item setImage:image];
    [item setMenu:statusMenu];
    [item setToolTip:@"Speed Limit"];
    [item setHighlightMode:YES];
    
}

- (void)dealloc{
    [speedLimiter release];
    [image release];
    [item release];
    [super dealloc];
}

- (IBAction)showWindowAction:(id)sender{
    [NSApp activateIgnoringOtherApps:YES];
    if(speedLimitWindow == nil){
        SpeedLimitWindowController *wc = [[SpeedLimitWindowController alloc] initWithWindowNibName:@"SpeedLimitWindow"];
        [wc setSpeedLimiter:speedLimiter];
        speedLimitWindow = [[wc window] retain];
    }
    [speedLimitWindow makeKeyAndOrderFront:NSApp];
    
}

@end