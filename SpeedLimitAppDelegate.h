//
//  SpeedLimitAppDelegate.h
//  SpeedLimit
//
//  Created by Jamie Pinkham on 3/8/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#import <Cocoa/Cocoa.h>
#import "SpeedLimiter.h"

@interface SpeedLimitAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSMenu *statusMenu;
    
    NSStatusItem *item;
    NSImage *image;
    SpeedLimiter *speedLimiter;
    NSMenuItem *currentItem;
    NSWindow *speedLimitWindow;
    
}

- (IBAction)showWindowAction:(id)sender;
- (IBAction)quitAction:(id)sender;

@end
