/*
 This file is part of Mac Eve Tools.
 
 Mac Eve Tools is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Mac Eve Tools is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Mac Eve Tools.  If not, see <http://www.gnu.org/licenses/>.
 
 Copyright Matt Tyson, 2009.
 */


#import "PlannerColumn.h"


#define COL_NAME @"col_name"
#define COL_ACTIVE @"col_active"
#define COL_WIDTH @"col_width"
#define COL_IDENTIFER @"col_identifier"
#define COL_ORDER @"col_order"

@implementation PlannerColumn

@synthesize identifier;
@synthesize columnName;
@synthesize active;
@synthesize columnWidth;
@synthesize order;

-(void) dealloc
{
	[columnName release];
	[identifier release];
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
		order = [aDecoder decodeIntForKey:COL_ORDER];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:columnName forKey:COL_NAME];
	[aCoder encodeObject:identifier forKey:COL_IDENTIFER];
	[aCoder encodeBool:active forKey:COL_ACTIVE];
	[aCoder encodeFloat:columnWidth forKey:COL_WIDTH];
	[aCoder encodeInt:order forKey:COL_ORDER];
}

-(NSString*) description
{
	NSMutableString *str = [[[NSMutableString alloc]init]autorelease];
	
	[str appendFormat:@"Name: %@ ",columnName];
	[str appendFormat:@"Enabled: %@",active ? @"yes" : @"no"];
	
	return str;
}

@end
