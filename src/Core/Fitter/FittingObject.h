//
//  FittingObject.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 20/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "macros.h"

/*
	Represents an object that can be fitted to a ship, 
 be it a High,Mid,Low,Subsytem or Rig slot item.
 
 */

@interface FittingObject : NSObject {

}

-(BOOL) isActive;
-(BOOL) canOverheat;
-(enum SlotType) slotType;
-(BOOL) hasAmmo; // Either weapon ammo such as missiles or charges,  or scripts for sensor boosters etc.

-(CGFloat) valueForAttribute:(NSInteger)attributeID;

@end
