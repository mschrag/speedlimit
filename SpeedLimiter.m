//
//  SpeedLimiter.m
//  SpeedLimit
//
//  Created by Jamie Pinkham on 3/8/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SpeedLimiter.h"
#import "Speed.h"
#import "SLPort.h"

@interface SpeedLimiter()

- (NSString *)execute:(NSString *)command withArguments:(NSArray *)arguments;
- (NSArray *)rulesForCommand:(NSString *)command withArguments:(NSArray *)arguments;
- (void)saveSettings;
- (void)updateStatus;

@end

@implementation SpeedLimiter

NSString *const PORTS_KEY = @"ports";
NSString *const DELAY_KEY = @"delay";
NSString *const SPEED_KEY = @"speed";
NSString *const RULES_KEY = @"rules";
NSString *const HOSTS_KEY = @"hosts";
NSString *const AUTH_STATE_KEY = @"authstate";

NSString * const SpeedLimitWillSlowNotification = @"SpeedLimitWillSlowNotification";
NSString * const SpeedLimitDidSlowNotification = @"SpeedLimitDidSlowNotification";

@synthesize delay;
@synthesize hosts;
@synthesize currentSpeed;
@synthesize speeds;
@synthesize ports;
@synthesize rules;
@synthesize slow;
@synthesize packetLossRatio;
@synthesize packetLossErrorSuppress;
@synthesize authorizationRef;
@synthesize authorizationState;

- (id)init{
    if(self = [super init]){
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:[Speed speedWithName:@"T1" speed:1572]];
        [array addObject:[Speed speedWithName:@"DSL" speed:768]];
        [array addObject:[Speed speedWithName:@"3G" speed:384]];
        [array addObject:[Speed speedWithName:@"Edge" speed:64]];
        [array addObject:[Speed speedWithName:@"Dialup" speed:48]];
        [self setSpeeds:array];
        
        NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
        NSArray *previousPorts = [prefs objectForKey:PORTS_KEY];
        ports = [[NSMutableArray alloc] init];
        if ([previousPorts count]) {
            for (NSString *object in [previousPorts objectEnumerator]) {
                SLPort *newPort = [[SLPort alloc] initWithPort:[object intValue]];
                [ports addObject:newPort];
                [newPort release];
            }
        }
        else {
            [ports addObject:[[[SLPort alloc] initWithPort:80] autorelease]];
            [ports addObject:[[[SLPort alloc] initWithPort:443] autorelease]];
        }
        
        NSString *previousDelay = [prefs objectForKey:DELAY_KEY];
        if (previousDelay) {
            self.delay = previousDelay;
        }
        else {
            self.delay = @"250";
        }
        
        NSString *previousHosts = [prefs objectForKey:HOSTS_KEY];
        if (previousHosts) {
            self.hosts = previousHosts;
        }
        else {
            self.hosts = @"";
        }
        
        NSInteger previousSpeed = [[prefs objectForKey:SPEED_KEY] integerValue];
        if (previousSpeed) {
            for (Speed *loopSpeed in [self speeds]) {
                if (loopSpeed.speed == previousSpeed) {
                    currentSpeed = [loopSpeed retain];
                }
            }
        }
        
        authorizationState = [[prefs objectForKey:AUTH_STATE_KEY] integerValue];
        
        self.rules = [prefs objectForKey:RULES_KEY];
        self.slow = [self.rules count];
    }
    return self;
}

- (void)dealloc{
    [delay release];
    [hosts release];
    [currentSpeed release];
    [speeds release];
    [ports release];
    [rules release];
    [super dealloc];
}

- (NSString *)speedLimiterPath{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *speedLimiterPath = [[bundle resourcePath] stringByAppendingPathComponent:@"SpeedLimiter"];
	return speedLimiterPath;
}

- (void)toggle{
    if (!self.slow) {
        NSMutableArray *portStrings = [NSMutableArray array];
        for (SLPort *thePort in self.ports) {
            [portStrings addObject:[[thePort port] stringValue]];
        }
		if (self.currentSpeed && [portStrings count]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SpeedLimitWillSlowNotification object:self];
			NSString *finalSpeed = [NSString stringWithFormat:@"%ld", currentSpeed.speed];
			NSString *finalDelay = (self.delay == nil || [self.delay length] == 0) ? 0 : self.delay;
			NSString *finalHosts = (self.hosts == nil) ? @"" : self.hosts;
			NSString *finalPacketLossRatio = [[NSNumber numberWithDouble:self.packetLossRatio] stringValue];
			NSString *finalPacketLossErrorSuppress = (self.packetLossErrorSuppress) ? @"yes" : @"no";
			NSMutableArray *arguments = [NSMutableArray array];
			[arguments addObject:finalSpeed];
			[arguments addObject:finalDelay];
			[arguments addObject:finalPacketLossRatio];
			[arguments addObject:finalPacketLossErrorSuppress];
			[arguments addObject:finalHosts];
			[arguments addObjectsFromArray:portStrings];
			self.rules = [self rulesForCommand:@"start" withArguments:arguments];
			[self saveSettings];
			[self updateStatus];
			if (![self.rules count]) {
				[[NSAlert alertWithMessageText:@"Failed to set speed limit." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
			}else{
                [[NSNotificationCenter defaultCenter] postNotificationName:SpeedLimitDidSlowNotification object:self];
            }
		}
		else {
			[[NSAlert alertWithMessageText:@"You must select a speed and at least one port." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
		}
	}
	else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SpeedLimitWillSlowNotification object:self];
		if (self.rules) {
			[self execute:@"stop" withArguments:self.rules];
            
		}
		self.rules = nil;
		[self saveSettings];
		[self updateStatus];
        [[NSNotificationCenter defaultCenter] postNotificationName:SpeedLimitDidSlowNotification object:self];
	}
}

- (void)saveSettings {
	NSMutableDictionary *prefs = [NSMutableDictionary dictionary];
	
    NSMutableArray *thePorts = [NSMutableArray array];
    for (SLPort *thePort in self.ports) {
        [thePorts addObject:[[thePort port] stringValue]];
    }
    [prefs setObject:thePorts forKey:PORTS_KEY];
	if (self.delay) {
		[prefs setObject:self.delay forKey:DELAY_KEY];
	}
	if (currentSpeed) {
		[prefs setObject:[NSNumber numberWithInteger:currentSpeed.speed] forKey:SPEED_KEY];
	}
	if (rules) {
		[prefs setObject:rules forKey:RULES_KEY];
	}
	if (self.hosts) {
		[prefs setObject:self.hosts forKey:HOSTS_KEY];
	}
	
    [prefs setObject:[NSNumber numberWithInteger:authorizationState] forKey:AUTH_STATE_KEY];
	/*if (authorizationView) {
		[prefs setObject:[NSNumber numberWithInteger:[authorizationView authorizationState]] forKey:AUTH_STATE_KEY];
	}*/
	
	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
	[[NSUserDefaults standardUserDefaults] setPersistentDomain:prefs forName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)execute:(NSString *)command withArguments:(NSArray *)arguments {
	NSMutableArray *finalArguments = [NSMutableArray array];
	[finalArguments addObject:command];
	[finalArguments addObjectsFromArray:arguments];
	
	char *args[[finalArguments count] + 2];
	args[0] = (char *)[command cStringUsingEncoding:NSUTF8StringEncoding];
	NSInteger argNum = 0;
	for (NSString *argument in finalArguments) {
		args[argNum ++] = (char *)[argument cStringUsingEncoding:NSUTF8StringEncoding];
	}
	args[argNum] = NULL;
	
	FILE *ipfwPipe;
	NSString *ipfwPipeStr = nil;
	OSStatus err = AuthorizationExecuteWithPrivileges(authorizationRef, [[self speedLimiterPath] fileSystemRepresentation], 0, args, &ipfwPipe);
	if (err == errAuthorizationSuccess) {
		NSFileHandle *ipfwPipeHandle = [[NSFileHandle alloc] initWithFileDescriptor:fileno(ipfwPipe)];
		ipfwPipeStr = [[NSString alloc] initWithData:[ipfwPipeHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
		// NSLog(@"SpeedLimiter output = %@", ipfwPipeStr);
	}
	
	return [ipfwPipeStr autorelease];
}

- (NSArray *)rulesForCommand:(NSString *)command withArguments:(NSArray *)arguments {
	NSMutableArray *returnRules = [NSMutableArray array];
	NSArray *lines = [[self execute:command withArguments:arguments] componentsSeparatedByString:@"\n"];
	for (NSString *line in lines) {
		if ([line length] > 0) {
			NSInteger ruleNumber = [line integerValue];
			if (!ruleNumber) {
				[returnRules removeAllObjects];
			}
			else {
				[returnRules addObject:[NSString stringWithFormat:@"%ld", ruleNumber]];
			}
		}
	}
	return returnRules;
}

- (void)updateStatus {
	self.slow = [self.rules count];
}

- (void)refreshRules {
	NSArray *previousRules = self.rules;
	if ([previousRules count]) {
		NSArray *returnRules = [self rulesForCommand:@"list" withArguments:previousRules];
		if ([returnRules count] != [previousRules count]) {
			self.rules = nil;
			[self saveSettings];
		}
	}
	[self updateStatus];
}

- (void)releaseAuthorization{
    if (authorizationRef != NULL) {
        AuthorizationFree(authorizationRef, kAuthorizationFlagDestroyRights);	
        authorizationRef = NULL;
    }
}

- (void)addPort:(SLPort *)port{
    [ports addObject:port];
}
- (void)removePorts:(NSArray *)thePorts{
    for(SLPort *port in thePorts){
        [ports removeObject:port];
    }
}

@end
