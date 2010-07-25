//
//  ShipSlots.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 25/07/10.
//  Copyright 2010 Sebastian Kruemling. All rights reserved.
//

#import "ShipSlots.h"


@implementation ShipSlots

@synthesize highSlotMax;
@synthesize midSlotMax;
@synthesize lowSlotMax;
@synthesize rigSlotMax;
@synthesize subsystemSlotMax;

-(ShipSlots*) initWithHigh:(NSInteger)hi 
					   mid:(NSInteger)mid 
					   low:(NSInteger)low
					  rigs:(NSInteger)rigs
					  subs:(NSInteger)subs
{
	if((self = [super init])){
		highSlotMax = hi;
		midSlotMax = mid;
		lowSlotMax = low;
		rigSlotMax = rigs;
		subsystemSlotMax = subs;
		
		/*probs should be set to nil, but 0 is the same thing.*/
		bzero(highSlots, sizeof(highSlots));
		bzero(midSlots, sizeof(midSlots));
		bzero(lowSlots, sizeof(lowSlots));
		bzero(rigSlots, sizeof(rigSlots));
		bzero(subsystemSlots, sizeof(subsystemSlots));
	}
	return self;
}

-(void)dealloc
{
	for(int i = 0; i < MAX_HIGH_SLOTS; i++){
		[highSlots[i] release];
	}
	for(int i = 0; i < MAX_MID_SLOTS; i++){
		[midSlots[i] release];
	}
	for(int i = 0; i < MAX_LOW_SLOTS; i++){
		[lowSlots[i] release];
	}
	for(int i = 0; i < MAX_RIG_SLOTS; i++){
		[rigSlots[i] release];
	}
	for(int i = 0; i < MAX_HIGH_SLOTS; i++){
		[subsystemSlots[i] release];
	}

	[super dealloc];
}

-(FittingObject**) enumToSlot:(enum SlotType)slotType
{
	switch (slotType) {
		case slotHigh:
			return highSlots;
		case slotMid:
			return midSlots;
		case slotLow:
			return lowSlots;
		case slotRigS:
		case slotRigM:
		case slotRigL:
			return rigSlots;
		case slotSubsystem:
			return subsystemSlots;
	}
	return NULL;
}

-(NSInteger) slotCount:(enum SlotType)slotType
{
	switch (slotType) {
		case slotHigh:
			return highSlotMax;
		case slotMid:
			return midSlotMax;
		case slotLow:
			return lowSlotMax;
		case slotRigS:
		case slotRigM:
		case slotRigL:
			return rigSlotMax;
		case slotSubsystem:
			return subsystemSlotMax;
	}
	NSLog(@"Unknown slot type %d",slotType);
	return 0;
}

-(void) fitSlot:(FittingObject*)object inSlot:(NSInteger)slotNumber slotVar:(FittingObject**)slot
{
	if (slot[slotNumber] != nil) {
		[slot[slotNumber] release];
	}
	
	slot[slotNumber] = [object retain];
}

-(BOOL) fitModule:(FittingObject*)object inSlot:(NSInteger)slotNumber slotType:(enum SlotType)slotType
{
	/* 
	 Note: perform checking in here, make sure a mid slot item doesn't go in the wrong place. etc.
	 make sure that the right number of slots are available etc.
	 
	 Calculate any changes to slots caused by subsystem modules
	 */
	
	[self fitSlot:object inSlot:slotNumber slotVar:[self enumToSlot:slotType]];
	
	return YES;
}



-(FittingObject*) getModuleInSlot:(NSInteger)slotNumber slotType:(enum SlotType)slotType
{
	FittingObject **array = [self enumToSlot:slotType];
	return array[slotNumber];
}

-(void) deleteModuleInSlot:(NSInteger)slotNumber slotType:(enum SlotType)slotType
{
	FittingObject **array = [self enumToSlot:slotType];
	[array[slotNumber] release];
	array[slotNumber] = nil;
}

-(NSArray*) getAllModules
{
	//Return all of the objects in one hit, for the purposes of batch processing.
	return nil;
}


@end
