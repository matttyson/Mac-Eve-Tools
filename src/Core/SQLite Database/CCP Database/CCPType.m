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

#import "CCPType.h"

#import "CCPDatabase.h"


@implementation CCPType

@synthesize typeID;
@synthesize groupID;
@synthesize graphicID;
@synthesize raceID;
@synthesize marketGroupID;

@synthesize radius;
@synthesize mass;
@synthesize volume;
@synthesize capacity;
@synthesize basePrice;

@synthesize typeName;
@synthesize typeDescription;

@synthesize attributes;

@synthesize database;

-(CCPType*) initWithType:(NSInteger)tID
				   group:(NSInteger)gID
				 graphic:(NSInteger)grID
					race:(NSInteger)rID
			 marketGroup:(NSInteger)mgID
				  radius:(double)rad
					mass:(double)mas
				  volume:(double)vol
				capacity:(double)cap
			   basePrice:(double)bPrice
				typeName:(NSString*)tName
				typeDesc:(NSString*)tDesc
				database:(CCPDatabase*)db
{
	if(self = [super init]){
		typeID = tID;
		groupID = gID;
		graphicID = grID;
		raceID = rID;
		marketGroupID = mgID;
		radius = rad;
		mass = mas;
		volume = vol;
		capacity = cap;
		basePrice = bPrice;
		typeName = [tName retain];
		typeDescription = [tDesc retain];
		database = [db retain];
		skills = nil;
		
		metaGroupID = -1;
		parentTypeID = -1;
		metaLevel = -1;
		pirate = -1;
	}
	return self;
}

-(NSInteger) metaGroupID
{
	if(metaGroupID == -1){
		[database parentForTypeID:typeID parentTypeID:&parentTypeID metaGroupID:&metaGroupID];
	}
	return metaGroupID;
}
-(NSInteger) parentTypeID
{
	if(parentTypeID == -1){
		[database parentForTypeID:typeID parentTypeID:&parentTypeID metaGroupID:&metaGroupID];
	}
	return parentTypeID;
}

-(void) dealloc
{
	[database release];
	[typeName release];
	[typeDescription release];
	[skills release];
	[super dealloc];
}

-(NSArray*) prereqs
{
	if(skills == nil){
		skills = [[database prereqForType:typeID]retain];
	}
	
	return skills;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"%ld - %@",typeID,typeName];
}

-(NSInteger) metaLevel
{
	if(metaLevel == -1){
		metaLevel = [database metaLevelForTypeID:typeID];
	}
	return metaLevel;
}

-(BOOL) isPirateShip
{
	if(pirate == -1){
		if([database isPirateShip:typeID]){
			pirate = 1;
		}else{
			pirate = 0;
		}
	}
	return (pirate == 1);
}

-(CCPTypeAttribute*) attributeForID:(NSInteger)attrID
{
	if(attributes == nil){
		attributes = [[database typeAttributesForTypeID:typeID]retain];
		
	}
	return [attributes objectForKey:[NSNumber numberWithInteger:attrID]];
}

@end
