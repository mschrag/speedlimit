//
//  SpeedLimitAppDelegate.m
//  SpeedLimit
//
//  Created by Jamie Pinkham on 3/8/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SpeedLimitAppDelegate.h"
#import "SpeedLimitWindowController.h"

@interface SpeedLimitAppDelegate ()

- (void)setMenuItemImageForSpeedLimiter:(SpeedLimiter *)aSpeedLimiter;

@end

@implementation SpeedLimitAppDelegate

- (NSString *)speedLimiterPath{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *speedLimiterPath = [[bundle resourcePath] stringByAppendingPathComponent:@"SpeedLimiter"];
	return speedLimiterPath;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    speedLimiter = [[SpeedLimiter alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speedLimiterSlowChanged:) name:SpeedLimitDidSlowNotification object:speedLimiter];
	item = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
    
    [self setMenuItemImageForSpeedLimiter:speedLimiter];
   
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

- (void)speedLimiterSlowChanged:(NSNotification *)aNotification{
    SpeedLimiter *aSpeedLimiter = (SpeedLimiter *)[aNotification object];
    [self setMenuItemImageForSpeedLimiter:aSpeedLimiter];
}

- (void)setMenuItemImageForSpeedLimiter:(SpeedLimiter *)aSpeedLimiter{
    NSBundle *bundle = [NSBundle mainBundle];
    if([aSpeedLimiter slow]){
        image = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"SpeedLimitMenuItemActive" ofType:@"tiff"]];
    }else{
        image = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"SpeedLimitMenuItem" ofType:@"tiff"]];
    }
    [item setImage:image];
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

- (IBAction)quitAction:(id)sender{
    [speedLimiter saveSettings];
    [NSApp terminate:sender];
}

@end