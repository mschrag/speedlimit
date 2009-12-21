//
//  SLPort.h
//  speedlimit
//
//  Created by Michael Ledford on 11/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SLPort : NSObject {
    NSNumber *port;
}

@property (readwrite, retain) NSNumber *port;

- (id)initWithPort:(int)portValue;

@end
