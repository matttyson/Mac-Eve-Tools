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

#import "Skill.h"
#import "SkillPair.h"

#import "Helpers.h"

@implementation Skill

@synthesize skillName;
@synthesize typeID;
@synthesize groupID;
@synthesize skillDescription;
@synthesize skillRank;
@synthesize skillLevel;
@synthesize skillPoints;
@synthesize primaryAttr;
@synthesize secondaryAttr;

-(void) dealloc
{
	[typeID release];
	[groupID release];
	[skillName release];
	[skillDescription release];
	[skillPrereqs release];
	[bonuses release];
	[super dealloc];
}

-(Skill*) init
{
	if(self = [super init]){
		skillPrereqs = [[NSMutableArray alloc]init];
		bonuses = [[NSMutableDictionary alloc]init];
	}
	
	return self;
}

-(Skill*) privateInit
{
	if(self = [super init]){
		
	}
	return self;
}

-(Skill*) initWithDetails:(NSString*)name 
					group:(NSNumber*)skillGroupID 
					 type:(NSNumber*)skillTypeID
{
	if([self init])
	{
		typeID = [skillTypeID retain];
		groupID = [skillGroupID retain];
		skillName = [name retain];
	}
	
	return self;
}

-(Skill*) copyWithZone:(NSZone*)zone
{
	Skill *sg = [[Skill allocWithZone:zone]privateInit];
	if(sg != nil){
		
		sg->skillName = [self->skillName retain];
		sg->skillDescription = [self->skillDescription retain];
		sg->skillRank = self->skillRank;

		sg->skillLevel = self->skillLevel;
		sg->skillPoints = self->skillPoints;

		sg->primaryAttr = self->primaryAttr;
		sg->secondaryAttr = self->secondaryAttr;

		sg->skillPrereqs = [self->skillPrereqs retain];

		sg->typeID = [self->typeID retain];
		sg->groupID = [self->groupID retain];
		
		sg->bonuses = [self->bonuses retain];
	}
	return sg;
	
}

-(NSArray*) prerequisites
{
	if([skillPrereqs count] == 0){
		return nil;
	}
	
	return skillPrereqs;
}

-(void) addPrerequiste:(NSNumber*)skillTypeID level:(NSInteger)level;
{
	SkillPair *p = [[SkillPair alloc]initWithSkill:skillTypeID level:level];
	[skillPrereqs addObject:p];
	[p release];
}

-(void) addPrerequisteArray:(NSArray*)pre
{
	[skillPrereqs addObjectsFromArray:pre];
}

-(NSComparisonResult) sortByName:(Skill*)skill
{
	return [skillName localizedCompare:skill->skillName];
}

-(NSString*) description
{
	return skillName;
}

-(NSInteger) skillPointsForLevel:(NSInteger)level
{
	return skillPointsForLevel(level,skillRank);
}
-(NSInteger) totalSkillPointsForLevel:(NSInteger)level
{
	return totalSkillPointsForLevel(level,skillRank);
}

-(void) addBonus:(NSString*)bonusName bonusValue:(NSString*)value
{
	[bonuses setValue:value forKey:bonusName];
}

-(NSString*) getBonus:(NSString*)bonusName
{
	return [bonuses valueForKey:bonusName];
}

-(CGFloat) percentCompleted:(NSInteger)fromLevel toLevel:(NSInteger)toLevel
{	
	NSInteger startPoints = totalSkillPointsForLevel(fromLevel,skillRank);
	NSInteger finishPoints = totalSkillPointsForLevel(toLevel,skillRank);
	
	if(startPoints > skillPoints){
		return 0.0;
	}
	
	return ((CGFloat)(skillPoints - startPoints) / (CGFloat)(finishPoints - startPoints));
	
	/*given the start and finish skill point targets, find what percentage we have completed*/
}


@end
