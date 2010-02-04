//
//  MTImage.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 2/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MTImageView.h"


@implementation MTImageView

@synthesize selector;
@synthesize delegate;

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	NSMenu *menu = nil;
	if([theEvent type] == NSRightMouseDown){
		menu = [[[NSMenu alloc]initWithTitle:@"Menu"]autorelease];
		
		
		NSMenuItem *item = [[NSMenuItem alloc]initWithTitle:NSLocalizedString(@"Refresh Portrait",)
													 action:selector
											  keyEquivalent:@""];
		[item setTarget:delegate];
		
		[menu addItem:item];
		[item release];
	}
	
	return menu;
}

@end
