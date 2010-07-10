//
//  NSTableViewCellExtended.m
//  Mac Eve Tools
//
//  Created by Sebastian Kruemling on 20.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSTableViewCellExtended.h"


@implementation NSTableViewCellExtended

@synthesize controller;

- (void)textDidEndEditing:(NSNotification *)aNotification {
	[super textDidEndEditing:aNotification];
	
	[controller accountNameDidChanged];
}

@end
