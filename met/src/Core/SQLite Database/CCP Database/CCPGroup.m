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
#import "CCPType.h"
#import "CCPDatabase.h"

#import "METSubGroup.h"

#import "macros.h"

@implementation CCPGroup

@synthesize groupID;
@synthesize categoryID;
@synthesize graphicID;
@synthesize groupName;

-(CCPGroup*) init
{
	if(self = [super init]){

	}
	return self;
}

-(void) appendTypesToSubgroup:(NSMutableArray*)sub subGroup:(METSubGroup*)group
{
	
}

-(void) buildSubGroups:(NSArray*)typeArray
{
	/*group each item by faction, and filter by metaGroup*/
	
	NSMutableArray *caldari = [[[NSMutableArray alloc]init]autorelease];
	NSMutableArray *amarr = [[[NSMutableArray alloc]init]autorelease];
	NSMutableArray *minmatar = [[[NSMutableArray alloc]init]autorelease];
	NSMutableArray *gallente = [[[NSMutableArray alloc]init]autorelease];
	NSMutableArray *pirate = [[[NSMutableArray alloc]init]autorelease];
	
	for(CCPType *type in types){
		if([type isPirateShip]){
			[pirate addObject:type];
		}else{
			switch([type raceID]){
				case Caldari:
					[caldari addObject:type];
					break;
				case Gallente:
					[gallente addObject:type];
					break;
				case Amarr:
					[amarr addObject:type];
					break;
				case Minmatar:
					[minmatar addObject:type];
					break;
			}	
		}
	}
	
	[subGroups release];
	subGroups = [[NSMutableArray alloc]initWithCapacity:5];
	
	
	/*this is ugly shit. rewrite this later.*/
	
	METSubGroup *sg;
	/*pirate*/
	if([pirate count] > 0){
	sg = [[METSubGroup alloc]
					   initWithName:@"Faction"
					   andTypes:pirate
					   forMetaGroup:NullType
					   withRace:Pirate];
	[subGroups addObject:sg];
	[sg release];
	}
	//caldari
	if([caldari count] > 0){
	sg = [[METSubGroup alloc]
					   initWithName:@"Caldari"
					   andTypes:caldari
					   forMetaGroup:NullType
					   withRace:Caldari];
	[subGroups addObject:sg];
	[sg release];
	}
	//gallente
	if([gallente count] > 0){
	sg = [[METSubGroup alloc]
					   initWithName:@"Gallente"
					   andTypes:gallente
					   forMetaGroup:NullType
					   withRace:Gallente];
	[subGroups addObject:sg];
	[sg release];
	}
	
	//amarr
	if([amarr count] > 0){
	sg = [[METSubGroup alloc]
					   initWithName:@"Amarr"
					   andTypes:amarr
					   forMetaGroup:NullType
					   withRace:Amarr];
	[subGroups addObject:sg];
	[sg release];
	}
	
	//Minmatar
	if([minmatar count] > 0){
	sg = [[METSubGroup alloc]
					   initWithName:@"Minmatar"
					   andTypes:minmatar
					   forMetaGroup:NullType
					   withRace:Minmatar];
	[subGroups addObject:sg];
	[sg release];
	}
}

-(CCPGroup*) initWithGroup:(NSInteger)gID
				  category:(NSInteger)cID
				   graphic:(NSInteger)gaID
				 groupName:(NSString*)gName
				  database:(CCPDatabase*)db
{
	if(self = [self init]){
		groupID = gID;
		categoryID = cID;
		graphicID = gaID;
		groupName = [gName retain];
		database = [db retain];
		types = [[database typesInGroup:gID]retain];
		count = [types count];
	}
	return self;
}

-(void)dealloc
{
	[types release];
	[groupName release];
	[database release];
	[subGroups release];
	[super dealloc];
}

-(NSInteger) typeCount
{
	return count;
}
-(CCPType*) typeAtIndex:(NSInteger)index
{
	return [types objectAtIndex:index];
}
-(CCPType*) typeByID:(NSInteger)tID
{
	for(CCPType *t in types){
		if([t typeID] == tID){
			return t;
		}
	}
	return nil;
}

-(NSInteger) subGroupCount
{
	if([subGroups count] == 0){
		[self buildSubGroups:types];
	}
	return [subGroups count];
}

-(METSubGroup*) subGroupAtIndex:(NSInteger)index
{
	return [subGroups objectAtIndex:index];
}


@end
