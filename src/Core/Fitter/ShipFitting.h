//
//  ShipFitting.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 20/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FittingObject.h"

/*
	This class represents the ship that is being fitted.
 
 It has an array of base ship attributes that define the ship's fitting parameters, 
 such as CPU, Powergrid, Slots.
 
 It takes a tree of Skill objects and applies any bonuses to the ship. (maybe)
 
 Maybe It should post notifications when something changes, such as slot layouts or cpu/powergrid stuff.
 */


@interface ShipFitting : NSObject {
	NSInteger typeID;
	NSMutableDictionary *shipSlots;
	
	NSArray *shipBaseAttributes;
}

-(ShipFitting*) initWithTypeID:(NSInteger)typeID;

-(NSInteger) slotCount:(enum SlotType)slotType; //How many slots are availbe for the given type?

-(NSArray*) skillPrereqs; //Return an array of skillPairs that are prerequisites for this fit.

-(BOOL) fitModule:(FittingObject*)object inSlot:(NSInteger)slotNumber slotType:(enum SlotType)slotType;
-(FittingObject*) getModuleInSlot:(NSInteger)slotNumber slotType:(enum SlotType)slotType;


@end
