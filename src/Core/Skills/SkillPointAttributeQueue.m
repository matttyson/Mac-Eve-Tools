//
//  SkillPointAttributeQueue.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 31/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SkillPointAttributeQueue.h"
#import "SkillPointAttributeTotal.h"

#import "SkillPair.h"
#import "SkillTree.h"
#import "Skill.h"
#import "SkillPlan.h"

#import "GlobalData.h"


#import "Character.h"

@implementation SkillPointAttributeQueue

-(SkillPointAttributeQueue*)init
{
	self = [super init];
	if(self != nil){
		queue = [[NSMutableArray alloc]init];
	}
	return self;
}

-(void)dealloc
{
	[queue release];
	[super dealloc];
}

-(void) addSkillPoints:(NSInteger)skillPoints 
		   primaryAttr:(NSInteger)primary
		 secondaryAttr:(NSInteger)secondary
{
	//first, see if there is already a SkillPointAttributeTotal object in the array.
	for(SkillPointAttributeTotal *total in queue){
		if([total primary] == primary){
			if([total secondary] == secondary){
				[total addSkillPoints:skillPoints];
				return;
			}
		}
	}
	
	SkillPointAttributeTotal *total = [[SkillPointAttributeTotal alloc]initWithPrimary:primary
																		  andSecondary:secondary];
	[total addSkillPoints:skillPoints];
	[queue addObject:total];
	[total release]	;
}

-(NSInteger) calculateTrainingTimeForCharacter:(Character*)character
{
	NSInteger trainingTime = 0;
	
	for(SkillPointAttributeTotal *total in queue){
		trainingTime += [character trainingTimeInSeconds:[total primary] 
											   secondary:[total secondary]
											 skillPoints:[total skillPoints]];
	}
	
	return trainingTime;
}

-(NSUInteger) count
{
	return [queue count];
}

-(NSInteger) trainingTimeForIndex:(NSUInteger)index withCharacter:(Character*)character
{
	SkillPointAttributeTotal *total = [queue objectAtIndex:index];
	
	return [character trainingTimeInSeconds:[total primary] 
								  secondary:[total secondary] 
								skillPoints:[total skillPoints]];
}

-(NSInteger) primaryAttributeForIndex:(NSUInteger)index
{
	return [[queue objectAtIndex:index]primary];
}

-(NSInteger) secondaryAttributeForIndex:(NSUInteger)index
{
	return [[queue objectAtIndex:index]secondary];
}

-(NSInteger) skillPointsForIndex:(NSUInteger)index
{
	return [[queue objectAtIndex:index]skillPoints];
}

-(void) addPlanToQueue:(SkillPlan*)plan
{
	NSInteger planLength = [plan skillCount];
	SkillTree *st = [[GlobalData sharedInstance]skillTree];
	
	for(NSInteger i = 0; i < planLength; i++){
		SkillPair *pair = [plan skillAtIndex:i];
		
		Skill *s = [st skillForId:[pair typeID]];
		
		[self addSkillPoints:[s skillPointsForLevel:[pair skillLevel]]
				 primaryAttr:[s primaryAttr]
			   secondaryAttr:[s secondaryAttr]];
	}
	
	[queue sortUsingSelector:@selector(sortBySkillPoints:)];
}


@end
