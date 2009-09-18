//
//  Speed.m
//  SpeedLimit
//
//  Created by Michael Schrag on 8/27/08.
//  Copyright 2008 m Dimension Technology. All rights reserved.
//

#import "Speed.h"


@implementation Speed
@synthesize name;
@synthesize speed;

-(id)initWithName:(NSString *)aName speed:(NSInteger)aSpeed {
	if (self = [super init]) {
		self.name = aName;
		self.speed = aSpeed;
	}
	return self;
}

-(void)dealloc {
	[name release];
	[super dealloc];
}

-(NSString *)description {
	return [NSString stringWithFormat:@"%ldk (%@)", self.speed, self.name];
}

+(Speed *)speedWithName:(NSString *)aName speed:(NSInteger)aSpeed {
	return [[[Speed alloc] initWithName:aName speed:aSpeed] autorelease];
}
@end
