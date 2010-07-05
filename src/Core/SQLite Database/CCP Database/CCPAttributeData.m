//
//  AttributeTest.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 4/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CCPAttributeData.h"


@implementation CCPAttributeData

@synthesize name;
@synthesize value;
@synthesize attributeID;

-(CCPAttributeData*) initWithValues:(NSInteger)attrID value:(CGFloat)val name:(NSString*)n
{
	if((self = [super init])){
		attributeID = attrID;
		value = val;
		name = [n retain];
	}
	return self;
}

-(void)dealloc
{
	[name release];
	[super dealloc];
}

@end
