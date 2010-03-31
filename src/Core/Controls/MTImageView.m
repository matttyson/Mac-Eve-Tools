//
//  MTImage.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 2/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MTImageView.h"


@implementation MTImageView

@synthesize menu;

-(MTImageView*)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if(self){
		menu = nil;
	}
	
	return self;
}

-(void)dealloc
{
	[menu release];
	[super dealloc];
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	
	if([theEvent type] == NSRightMouseDown){
		return menu;
	}else if( ([theEvent type] == NSLeftMouseDown) && 
			 ([theEvent modifierFlags] & NSControlKeyMask))
	{
		return menu;
	}
	
	return nil;
}

@end
