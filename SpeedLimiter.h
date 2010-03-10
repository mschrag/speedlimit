//
//  SpeedLimiter.h
//  SpeedLimit
//
//  Created by Jamie Pinkham on 3/8/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Speed.h"
#import "SLPort.h"

@interface SpeedLimiter : NSObject {
    NSString *delay;
	NSString *hosts;
	Speed *currentSpeed;
    NSMutableArray *speeds;
    NSMutableArray *ports;
	NSArray *rules;
	BOOL slow;
	double packetLossRatio;
	BOOL packetLossErrorSuppress;
    AuthorizationRef authorizationRef;
	
	NSInteger authorizationState;
}

- (NSString *)speedLimiterPath;
- (void)toggle;
- (void)releaseAuthorization;
- (void)addPort:(SLPort *)port;
- (void)removePorts:(NSArray *)thePorts;
- (void)saveSettings;

@property (readwrite, retain) NSString *delay;
@property (readwrite, retain) NSString *hosts;
@property (readwrite, retain) Speed *currentSpeed;
@property (readwrite, retain) NSArray *speeds;
@property (readwrite, retain) NSArray *ports;
@property (readwrite, retain) NSArray *rules;
@property (readwrite, assign) BOOL slow;
@property (readwrite, assign) double packetLossRatio;
@property (readwrite, assign) BOOL packetLossErrorSuppress;
@property (readwrite, assign) AuthorizationRef authorizationRef;
@property (readonly, assign) NSInteger authorizationState;

@end

extern NSString * const SpeedLimitWillSlowNotification;
extern NSString * const SpeedLimitDidSlowNotification;
