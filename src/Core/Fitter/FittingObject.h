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

#import "macros.h"

#import "FitterMacros.h"


/*
	Represents an object that can be fitted to a ship, 
 be it a High,Mid,Low,Subsytem or Rig slot item.
 
 */

@class ModuleCharge;

@interface FittingObject : NSObject {
	NSInteger typeID;
	NSDictionary *attributes;  //All the attriubutes that this object posseses
	
	ModuleCharge *charge; //The charge fitted to this module, if it is capable of holding charges.
}

-(FittingObject*) initWithTypeID:(NSInteger)tID andAttributes:(NSDictionary*)attrs;

-(BOOL) isActive; // The module can be activated.
-(BOOL) canOverheat; // The module can be overheated.
-(enum SlotType) slotType; // The slot type that this module belongs to.
-(BOOL) hasCharges; // Either weapon ammo such as missiles or charges,  or scripts for sensor boosters etc.

-(ModuleCharge*) charge;
-(void) setCharge:(ModuleCharge*)chrg;


//Return the float value of an attribute.
-(CGFloat) valueForAttribute:(enum CCPAttributeID)attributeID;



@end
