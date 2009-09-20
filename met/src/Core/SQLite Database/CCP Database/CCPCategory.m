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

#import "CCPGroup.h"
#import "CCPCategory.h"
#import "CCPDatabase.h"



@implementation CCPCategory

@synthesize categoryID;
@synthesize graphicID;
@synthesize categoryName;

-(CCPCategory*) init
{
	if((self = [super init])){
		groups = [[NSMutableDictionary alloc]init];
	}
	return self;
}

-(CCPCategory*) initWithCategory:(NSInteger)cID 
						 graphic:(NSInteger)gID 
							name:(NSString*)cName
						database:(CCPDatabase*)db
{
	if((self = [self init])){
		categoryID = cID;
		graphicID = gID;
		categoryName = [cName retain];
		
		database = [db retain];
		
		[groups release];  //nasty hack.
		
		groups = [[database groupsInCategory:cID]retain];
		groupCount = [groups count];
	}
	return self;
}

-(void) dealloc
{
	[groups release];
	[database release];
	[categoryName release];
	[super dealloc];
}

-(NSInteger)groupCount
{
	return groupCount;
}

-(CCPGroup*) groupAtIndex:(NSInteger)groupIndex
{
	return [groups objectAtIndex:groupIndex];
}

-(CCPGroup*) groupByID:(NSInteger)gID
{
	for(CCPGroup *g in groups){
		if([g groupID] == gID){
			return g;
		}
	}
	return nil;
}


@end
