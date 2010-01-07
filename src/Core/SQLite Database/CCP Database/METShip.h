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

@class CCPType;
@class CCPTypeAttribute;

/*
	represents all information about a ship
	Given the typeID of the ship, load up all the data from the database.
 
	This should be called perhaps METObject. as it contains a type, and attributes for that type.
 
	It is not specefic to ships.
*/

@interface METShip : NSObject {
	NSInteger typeID;
	
	NSMutableDictionary *attributes;
	CCPType *shipType;
}

-(NSString*) shipName;
-(CCPTypeAttribute*) attributeForID:(NSInteger)attrID;

@end
	
	/*
		Info needed:
	 
		Attributes Tab:
		
		Structure:
			Capacity (in invTypes table)
			Drone Capacity (283)
			Drone Bandwith (1271)
			Mass 
			Volume
			Inertia Modifier
		
			EM/EXP/KIN/THERM damage resist (113,111,109,110)
			
		Armor:
			Armour amount (265)
			Damage Resist 
			EM (267)
			Explosive (268)
			Kenetic (269)
			Thermal (270)
		
		Shield:
			Sheild amount (263)
			Shield recharg time (479)
			damage resist
			EM (271)
			Explosive (272)
			Kenetic (273)
			Thermal (274)
		Capacitor:
			Capacity (482) 
			Recharge time (55)
		Targeting:
			Max targeting range (75)
			Max locked targets (192)
			Radar Str (208)
			Ladar Str (209)
			Magnetometric (210)
			Gravimetric (211)
			Signature radius (552)
		Propulsion
			Max Velocity (37)
			Ship warp speed
	 
	 Fitting tab:
		CPU (48)
		Powergrid (11)
		Calibration (1132)
		Low (12)/ Med (13)/ High slots (14)
		Launcher hardpoints (101)
		Turret Hardpoints (102)
		Upgrade hardpoints (1137)
	 
	 Skill Prerequisites:
	 
	 Variations:
	 
	 Tech I
	 Tech II
	 Faction
		
	 
	 Query:
	 
	 SELECT at.graphicID, at.attributeID, at.displayName, ta.valueInt, ta.valueFloat 
	 FROM dgmTypeAttributes ta, dgmAttributeTypes at 
	 WHERE at.attributeID = ta.attributeID 
	 AND ta.typeID = 639

	 
	 Gives the attributes needed to display info about a ship
	 
	 Plan:
	 
	 Issue the query to get all the identifiers and stuff everything into a NSDictionary
	 keyed on the attributeID, and fetch the attribute ID data as required.
	 */
