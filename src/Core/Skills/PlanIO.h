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
	given a plan, write it out in a certian format, or read a plan in from disk.
 
	Set the filename, and call read to read in a plan in a given format.
	if YES is returned, the SkillPlan object can be fetched from the plan accessor.
 
 */

@class SkillPlan;
@class Character;

@interface PlanIO : NSObject {
}

/*read the skill plan into the character.*/
-(BOOL) read:(NSString*)filePath intoPlan:(SkillPlan*)plan;

/*write the given skillplan*/
-(BOOL) write:(NSString*)filePath plan:(SkillPlan*)plan;

@end
