//
//  ShipSlots.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 25/07/10.
//  Copyright 2010 Sebastian Kruemling. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FitterMacros.h"

@class FittingObject;

@interface ShipSlots : NSObject {
	NSInteger highSlotMax;
	NSInteger midSlotMax;
	NSInteger lowSlotMax;
	NSInteger rigSlotMax;
	NSInteger subsystemSlotMax;

	FittingObject *highSlots[MAX_HIGH_SLOTS];
	FittingObject *midSlots[MAX_MID_SLOTS];
	FittingObject *lowSlots[MAX_LOW_SLOTS];
	FittingObject *rigSlots[MAX_RIG_SLOTS];
	FittingObject *subsystemSlots[MAX_SUBSYSTEM_SLOTS];
}

-(ShipSlots*) initWithHigh:(NSInteger)hi 
					   mid:(NSInteger)mid 
					   low:(NSInteger)low
					  rigs:(NSInteger)rigs
					  subs:(NSInteger)subs;

@property (readwrite,nonatomic,assign) NSInteger highSlotMax;
@property (readwrite,nonatomic,assign) NSInteger midSlotMax;
@property (readwrite,nonatomic,assign) NSInteger lowSlotMax;
@property (readwrite,nonatomic,assign) NSInteger rigSlotMax;
@property (readwrite,nonatomic,assign) NSInteger subsystemSlotMax;

-(NSInteger) slotCount:(enum SlotType)slotType;

-(BOOL) fitModule:(FittingObject*)object inSlot:(NSInteger)slotNumber slotType:(enum SlotType)slotType;

-(FittingObject*) getModuleInSlot:(NSInteger)slotNumber slotType:(enum SlotType)slotType;

-(void) deleteModuleInSlot:(NSInteger)slotNumber slotType:(enum SlotType)slotType;

-(NSArray*) getAllModules;

@end
