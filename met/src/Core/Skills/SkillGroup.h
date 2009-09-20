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

#import "Skill.h"

@interface SkillGroup : NSObject <NSCopying> {
	NSString *groupName;
	NSNumber *groupID;
	NSInteger groupIDNum; /*integer ID of the group*/
	
	/*Key - value pair of skills keyed on skillID*/
	NSMutableDictionary *skills;
	NSArray *skillArray; /*sorted aray generated from the dictionary*/
	
	NSInteger groupSPTotal;
}



-(SkillGroup*) initWithDetails:(NSString*)name group:(NSNumber*)skillGroupID;

-(BOOL) addSkill:(Skill*)skill;

-(NSUInteger) skillCount;

-(Skill*) getSkillAtIndex:(NSUInteger)index;

-(NSComparisonResult) sortByName:(SkillGroup*)group;

-(NSInteger) groupSPTotal;

-(NSString*) description;

@property (readonly, nonatomic) NSNumber* groupID;
@property (readonly, nonatomic) NSString* groupName;

@end
