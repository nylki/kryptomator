//
//  TBAboutWindowController.m
//  Kryptomator_dragndrop
//
//  Created by Tom on 20.02.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TBAboutWindowController.h"

TBAboutWindowController *sharedAboutWindowInstance = nil;

@implementation TBAboutWindowController

-(id)initWithWindowNibName:(NSString *)windowNibName
{
	if (!(self = [super initWithWindowNibName:windowNibName]))
        NSLog(@"initWithWindowNibName \"%@\" failed", windowNibName);
    else {
		NSLog(@"initWithWindowNibName \"%@\" succeeded", windowNibName);
	}
	return self;
}

+ (TBAboutWindowController *) aboutWindowController
{
    if (!sharedAboutWindowInstance)
        sharedAboutWindowInstance = [[self alloc] initWithWindowNibName:@"AboutWindow"];
    return sharedAboutWindowInstance;
}

@end
