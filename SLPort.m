//
//  SLPort.m
//  speedlimit
//
//  Created by Michael Ledford on 11/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SLPort.h"


@implementation SLPort

@synthesize port;

- (id)initWithPort:(int)portValue
{
    self = [self init];
    
    if (self != nil) {
        if (!portValue) {
            [self release];
            return nil;
        }
        [self setPort:[NSNumber numberWithInt:portValue]];
    }

    return self;
}

-(NSString *)description {
	return [self.port description];
}

- (void)dealloc
{
    [port release];
    [super dealloc];
}

@end
