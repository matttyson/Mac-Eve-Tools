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


enum CCPAttributeID
{
	attrLowSlots = 12,
	attrMedSlots = 13,
	attrHiSlots = 14,
	attrRigSlots = 1337,
	attrSubSystemSlot = 1366
};

enum CCPEffectID
{
	effectLoPower = 11,
	effectMedPower = 13,
	effectHiPower = 12
};

/*Slot type values for the ship fitter*/
enum SlotType
{
	slotHigh,
	slotMid,
	slotLow,
	slotRigS,
	slotRigM,
	slotRigL,
	slotSubsystem
};
typedef enum SlotType SlotType;


/*
 
 This largley copied from EveHQ written by Vessper
 
 */

enum EffectType
{
	effectAll = 0,
	effectItem = 1,
	effectGroup = 2,
	effectCategory = 3,
	effectMarketGroup = 4,
	effectSkill = 5,
	effectSlot = 6,
	effectAttribute = 7
};

enum EffectCalcType
{
	calcPercentage = 0,
	calcAddition = 1,
	calcDifference = 2,
	calcVelocity = 3,
	calcAbsolute = 4,
	calcMultiplier = 5,
	callAddPositive = 6,
	calcAddNegative = 7,
	calcSubtraction = 8,
	calcCloakedVelocity = 9,
	calcSkillLevel
};

enum EffectStackType 
{
	stackNone = 0,
	stackStandard = 1,
	stackGroup = 2,
	stackItem = 3
};

/*End vessper EveHQ stuff.*/

	
#define MAX_HIGH_SLOTS 8
#define MAX_MID_SLOTS 8
#define MAX_LOW_SLOTS 8
#define MAX_RIG_SLOTS 3
#define MAX_SUBSYSTEM_SLOTS 6
	
