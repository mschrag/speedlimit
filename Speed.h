//
//  Speed.h
//  SpeedLimit
//
//  Created by Michael Schrag on 8/27/08.
//  Copyright 2008 m Dimension Technology. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Speed : NSObject {
	NSInteger speed;
	NSString *name;
}

@property (readwrite, retain) NSString *name;
@property (readwrite, assign) NSInteger speed;

-(id)initWithName:(NSString *)name speed:(NSInteger)speed;

+(Speed *)speedWithName:(NSString *)aName speed:(NSInteger)aSpeed;

@end
