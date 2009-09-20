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

#import "SkillGroup.h"


@implementation SkillGroup

@synthesize groupID;
@synthesize groupName;

-(void) dealloc
{
	[groupName release];
	[groupID release];
	[skills release];
	[skillArray release];
	[super dealloc];
}

-(SkillGroup*) initWithDetails:(NSString*)name group:(NSNumber*)skillGroupID
{
	if(self = [super init])
	{
		groupName = [name retain];
		groupID = [skillGroupID retain];
		skills = [[NSMutableDictionary alloc]init];
		skillArray = nil;
		groupSPTotal = 0;
	}
	return self;
}

-(SkillGroup*) copyWithZone:(NSZone*)zone
{
	SkillGroup *sg = [[SkillGroup allocWithZone:zone]init];
	
	sg->groupName = [self->groupName retain];
	sg->groupID = [self->groupID retain];
	sg->skills = [self->skills mutableCopy];
	
	sg->skillArray = nil;
	sg->groupSPTotal = 0;
	
	return sg;
}

-(BOOL) addSkill:(Skill*)skill
{
	[skills setObject:skill forKey:[skill typeID]];
	/*invalidate the cached skill array for the dataset*/
	if(skillArray != nil){
		[skillArray release];
		skillArray = nil;
	}
	groupSPTotal = 0;
	return YES;
}

-(NSInteger) groupSPTotal
{
	if(groupSPTotal == 0){
		/*calculate total SP*/
		NSEnumerator *e = [skills objectEnumerator];
		Skill *s;
		while((s = [e nextObject]) != nil){
			groupSPTotal += [s skillPoints];
		}
	}
	return groupSPTotal;
}

-(NSUInteger) skillCount
{
	return [skills count];
}

-(Skill*) getSkillAtIndex:(NSUInteger)index;
{
	if(skillArray == nil){
		/*get the skill array, sort them alphabeticly*/
		skillArray = [[[skills allValues]sortedArrayUsingSelector:@selector(sortByName:)]retain];
	}
	
	return [skillArray objectAtIndex:index];
	
}

-(NSComparisonResult) sortByName:(SkillGroup*)group
{
	return [groupName localizedCompare:group->groupName];
}

-(NSString*) description
{
	return groupName;
}

@end
