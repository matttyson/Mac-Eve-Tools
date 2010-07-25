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


#import <Cocoa/Cocoa.h>

#import "FittingObject.h"

/*
	This class represents the ship that is being fitted.
 
 It has an array of base ship attributes that define the ship's fitting parameters, 
 such as CPU, Powergrid, Slots.
 
 It takes a tree of Skill objects and applies any bonuses to the ship. (maybe)
 
 Maybe It should post notifications when something changes, such as slot layouts or cpu/powergrid stuff.
 */


@class ShipEffect;
@class Character;
@class ShipSlots;

@interface ShipFitting : NSObject {
	NSInteger typeID; //The typeID of the ship we are fitting.
	Character *character; //The character that is flying this ship.
	
	ShipSlots *shipSlots; // The items that have been fitted to this ship.
	
	NSDictionary *shipBaseAttributes;
	
	/*
	 The effects array is a list of effects that apply to this ship for the purposes of
	 calculating ship bonus attributes.
	 
	 EG: the Abaddon has a 5% base armour resist for all dmg types, and a 5% damage bonus per leve.
	 This information and how it relates to skills, and what attributes it applies to is contained in here.
	 
	 Array of ShipEffect class.
	 */
	NSMutableArray *effects;
}

/*
	Given the TypeID of the ship, create a new ship fitting object.
	
 */
-(ShipFitting*) initWithTypeID:(NSInteger)tID forCharacter:(Character*)ch;

-(NSInteger) slotCount:(enum SlotType)slotType; //How many slots are availbe for the given type?

-(NSArray*) skillPrereqs; //Return an array of skillPairs that are prerequisites for this fit.

-(BOOL) fitModule:(FittingObject*)object inSlot:(NSInteger)slotNumber slotType:(enum SlotType)slotType;
-(FittingObject*) getModuleInSlot:(NSInteger)slotNumber slotType:(enum SlotType)slotType;


@end
