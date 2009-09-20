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

/*
	represents all information about a ship
	Given the typeID of the ship, load up all the data from the database
*/

@interface CCPShip : NSObject {
	NSInteger typeID;
	
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
			Damage Resist (267,268,269,270)
		
		Shield:
			Sheild amount (263)
			Shield recharg time (479)
			damage resist (271,272,273,274)
		Capacitor:
			Capacity (482) 
			Recharge time (55)
		Targeting:
			Max targeting range (75)
			Max locked targets (192)
			Sensor type and strength (211,209,210,208)
			Signature radius (552)
		Propulsion
			Max Velocity (37)
			Ship warp speed
	 
	 Fitting tab:
		CPU (48)
		Powergrid (11)
		Calibration 
		Low / Med / High slots
		Launcher hardpoints
		Turret Hardpoints
		Upgrade hardpoints
	 
	 Skill Prerequisites:
	 
	 Variations:
	 
	 Tech I
	 Tech II
	 Faction
		
	 */
}

@end
