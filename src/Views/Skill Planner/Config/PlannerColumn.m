//
//  PlannerColumn.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 23/09/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PlannerColumn.h"


#define COL_NAME @"col_name"
#define COL_ACTIVE @"col_active"
#define COL_WIDTH @"col_width"
#define COL_IDENTIFER @"col_identifier"

@implementation PlannerColumn

@synthesize identifier;
@synthesize columnName;
@synthesize active;
@synthesize columnWidth;

-(void) dealloc
{
	[columnName release];
	[super dealloc];
}

-(PlannerColumn*) initWithName:(NSString*)name 
					identifier:(NSString*)idName
						status:(BOOL)isActive
						 width:(float)colWidth
{
	if((self = [super init])){
		columnName = [name retain];
		identifier = [idName retain];
		active = isActive;
		columnWidth = colWidth;
	}
	return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	if((self = [super init])){
		columnName = [[aDecoder decodeObjectForKey:COL_NAME]retain];
		identifier = [[aDecoder decodeObjectForKey:COL_IDENTIFER]retain];
		active = [aDecoder decodeBoolForKey:COL_ACTIVE];
		columnWidth = [aDecoder decodeFloatForKey:COL_WIDTH];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:columnName forKey:COL_NAME];
	[aCoder encodeObject:identifier forKey:COL_IDENTIFER];
	[aCoder encodeBool:active forKey:COL_ACTIVE];
	[aCoder encodeFloat:columnWidth forKey:COL_WIDTH];
}

-(NSString*) description
{
	NSMutableString *str = [[[NSMutableString alloc]init]autorelease];
	
	[str appendFormat:@"Name: %@ ",columnName];
	[str appendFormat:@"Enabled: %@",active ? @"yes" : @"no"];
	
	return str;
}

@end
