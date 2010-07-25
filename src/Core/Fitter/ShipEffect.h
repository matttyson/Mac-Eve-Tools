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

#import "FitterMacros.h"

@interface ShipEffect : NSObject {
	NSInteger shipTypeID;	// TypeID of the ship.
	enum EffectType affectingType; //
	
	NSInteger affectingID; // The TypeID of the skill that is causing this effect
	NSInteger affectingAttributeID; // the attributeID that this effect is applied to

	enum EffectType affectedType; // ???
	NSMutableArray *affectedTypeID;  //A list of typeIDs that are affected by this
	
	enum EffectStackType stackingNerf; // Something to do with how the stacking nerf is calculated.
	BOOL isPerLevel; //  Not entierly sure yet. maybe it means this attribute is applied once per level.
	
	enum EffectCalcType calcType; // How is this attribute calculated?
	
	NSInteger status; // ??
	CGFloat value;
}

@end
