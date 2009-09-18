//
//  SpeedLimitPref.m
//  SpeedLimit
//
//  Created by Michael Schrag on 8/27/08.
//  Copyright (c) 2008 m Dimension Technology. All rights reserved.
//

#import "SpeedLimitPref.h"
#include <Security/Authorization.h>
#include <Security/AuthorizationTags.h>

NSString *const PORTS_KEY = @"ports";
NSString *const DELAY_KEY = @"delay";
NSString *const SPEED_KEY = @"speed";
NSString *const RULES_KEY = @"rules";
NSString *const HOSTS_KEY = @"hosts";

@implementation SpeedLimitPref
@synthesize speedsController;
@synthesize portsController;
@synthesize delay;
@synthesize hosts;
@synthesize speed;
@synthesize rules;
@synthesize slow;
@synthesize speedLimitLabel;
@synthesize startStopButton;

- (NSString *)speedLimiterPath {
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *speedLimiterPath = [[bundle resourcePath] stringByAppendingPathComponent:@"SpeedLimiter"];
	return speedLimiterPath;
}

- (void) mainViewDidLoad {
	[speedsController addObject:[Speed speedWithName:@"DSL" speed:768]];
	[speedsController addObject:[Speed speedWithName:@"3G" speed:384]];
	[speedsController addObject:[Speed speedWithName:@"Edge" speed:64]];
	[speedsController addObject:[Speed speedWithName:@"Dialup" speed:48]];
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

- (void)saveSettings {
	NSMutableDictionary *prefs = [NSMutableDictionary dictionary];
	
	[prefs setObject:[portsController arrangedObjects] forKey:PORTS_KEY];
	if (self.delay) {
		[prefs setObject:self.delay forKey:DELAY_KEY];
	}
	if (speed) {
		[prefs setObject:[NSNumber numberWithInteger:speed.speed] forKey:SPEED_KEY];
	}
	if (rules) {
		[prefs setObject:rules forKey:RULES_KEY];
	}
	if (self.hosts) {
		[prefs setObject:self.hosts forKey:HOSTS_KEY];
	}
	
	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
	[[NSUserDefaults standardUserDefaults] setPersistentDomain:prefs forName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
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
	
	[startStopButton setEnabled:TRUE];
	if (self.slow) {
		[startStopButton setTitle:@"Speed Up"];
		[speedLimitLabel setStringValue:[NSString stringWithFormat:@"%ld", speed.speed]];
	}
	else {
		[speedLimitLabel setStringValue:@"-"];
		[startStopButton setTitle:@"Slow Down"];
	}
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

- (void)releaseAuthorization {
	if (authorizationRef != NULL) {
		AuthorizationFree(authorizationRef, kAuthorizationFlagDestroyRights);	
		authorizationRef = NULL;
	}
}

- (void)willSelect {
	NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];

	NSArray *previousPorts = [prefs objectForKey:PORTS_KEY];
	[portsController removeObjects:[portsController arrangedObjects]];
	if ([previousPorts count]) {
		[portsController addObjects:previousPorts];
	}
	else {
		[portsController addObject:@"80"];
		[portsController addObject:@"443"];
	}
	[portsController setSelectedObjects:nil];
	
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
		for (Speed *loopSpeed in [speedsController arrangedObjects]) {
			if (loopSpeed.speed == previousSpeed) {
				self.speed = loopSpeed;
			}
		}
	}
	
	self.rules = [prefs objectForKey:RULES_KEY];
	self.slow = YES;
	[startStopButton setEnabled:FALSE];
	[speedLimitLabel setStringValue:@"-"];
	[startStopButton setTitle:@"-"];
}

- (void)didSelect {
	OSStatus err = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authorizationRef);
	if (err == errAuthorizationSuccess) {
		const char *path = [[self speedLimiterPath] fileSystemRepresentation];
		AuthorizationItem right = { kAuthorizationRightExecute, strlen(path), (char *)path, 0 };
		AuthorizationRights rights = { 1, &right };
		AuthorizationFlags flags = kAuthorizationFlagExtendRights | kAuthorizationFlagInteractionAllowed;
		err = AuthorizationCopyRights(authorizationRef, &rights, kAuthorizationEmptyEnvironment, flags, NULL);
		if (err == errAuthorizationSuccess) {
			[self refreshRules];
		}
	}
}

- (void)willUnselect {
	[self saveSettings];
}

- (void)didUnselect {
	[self releaseAuthorization];
}

-(void)dealloc {
	[speedsController release];
	[portsController release];
	[speedLimitLabel release];
	[startStopButton release];
	
	[hosts release];
	[delay release];
	[rules release];
	
	[self releaseAuthorization];
	
	[super dealloc];
}

-(IBAction)addPort:(id)sender {
	NSString *newPort = @"1000";
	[portsController addObject:newPort];
}

-(IBAction)removePort:(id)sender {
	[portsController removeObjects:[portsController selectedObjects]];
}

-(IBAction)toggle:(id)sender {
	[self refreshRules];
	if (!self.slow) {
		NSArray *ports = [self.portsController arrangedObjects];
		if (self.speed && [ports count]) {
			NSString *finalSpeed = [NSString stringWithFormat:@"%ld", speed.speed];
			NSString *finalDelay = (self.delay == nil || [self.delay length] == 0) ? 0 : self.delay;
			NSString *finalHosts = (self.hosts == nil) ? @"" : self.hosts;
			NSMutableArray *arguments = [NSMutableArray array];
			[arguments addObject:finalSpeed];
			[arguments addObject:finalDelay];
			[arguments addObject:finalHosts];
			[arguments addObjectsFromArray:ports];
			self.rules = [self rulesForCommand:@"start" withArguments:arguments];
			[self saveSettings];
			[self updateStatus];
			if (![self.rules count]) {
				[[NSAlert alertWithMessageText:@"Failed to set speed limit." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
			}
		}
		else {
			[[NSAlert alertWithMessageText:@"You must select a speed and at least one port." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
		}
	}
	else {
		if (self.rules) {
			[self execute:@"stop" withArguments:self.rules];
		}
		self.rules = nil;
		[self saveSettings];
		[self updateStatus];
	}
}
@end
