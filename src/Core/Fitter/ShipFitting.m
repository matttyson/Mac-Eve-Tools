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

#import "ShipFitting.h"
#import "GlobalData.h"
#import "CCPDatabase.h"
#import "Character.h"
#import "FitterMacros.h"
#import "ShipSlots.h"
#import "CCPAttributeData.h"

@implementation ShipFitting

-(void)dealloc
{
	[shipSlots release];
	[shipBaseAttributes release];
	[character release];
	[shipSlots release];
	[super dealloc];
}

#define SLOT_COUNT(x) [[baseAttributes objectForKey:[NSNumber numberWithInteger:(NSInteger) (x) ]]attributeID]

-(ShipSlots*) createShipSlots:(NSDictionary*)baseAttributes
{
	
	
	ShipSlots *slots = [[ShipSlots alloc]initWithHigh:SLOT_COUNT(attrLowSlots) 
												  mid:SLOT_COUNT(attrMedSlots) 
												  low:SLOT_COUNT(attrHiSlots)
												 rigs:SLOT_COUNT(attrRigSlots)
												 subs:SLOT_COUNT(attrSubSystemSlot)];
	
	return slots;
}

#undef SLOT_COUNT

-(ShipFitting*) initWithTypeID:(NSInteger)tID forCharacter:(Character*)ch
{
	if((self = [super init])){
		typeID = tID;
		shipSlots = [[NSMutableDictionary alloc]init];
		shipBaseAttributes = [[[GlobalData sharedInstance]database]attributesForType:tID];
		character = [ch retain];
		shipSlots = [self createShipSlots:shipBaseAttributes];
	}
	return self;
}

-(NSInteger) slotCount:(enum SlotType)slotType
{
	return [shipSlots slotCount:slotType];
}

-(BOOL) fitModule:(FittingObject*)object inSlot:(NSInteger)slotNumber slotType:(enum SlotType)slotType
{
	return [shipSlots fitModule:object inSlot:slotNumber slotType:slotType];
}

-(FittingObject*) getModuleInSlot:(NSInteger)slotNumber slotType:(enum SlotType)slotType
{
	return [shipSlots getModuleInSlot:slotType slotType:slotType];
}

@end
