//
//  SkillDetailsTrainingTimeDatasource.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 12/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SkillDetailsTrainingTimeDatasource.h"

#import "Skill.h"
#import "Character.h"

#import "Helpers.h"
#import "macros.h"

@implementation SkillDetailsTrainingTimeDatasource

-(id) initWithSkill:(Skill*)s forCharacter:(Character*)ch
{
	if((self = [super init])){
		skill = [s retain];
		character = [ch retain];
	}
	return self;
}

-(void)dealloc
{
	[skill release];
	[character release];
	[super dealloc];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return 5;
}


- (id)tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSInteger)rowIndex
{
	
	if([[aTableColumn identifier]isEqualToString:SD_LEVEL]){
		return [NSNumber numberWithInteger:rowIndex + 1];
	}else if([[aTableColumn identifier]isEqualToString:SD_TIME]){
		
		NSInteger rank = [skill skillRank];
		NSInteger primaryAttr = [skill primaryAttr];
		NSInteger secondaryAttr = [skill secondaryAttr];
		
		NSInteger totalForLevel = 
		totalSkillPointsForLevel(rowIndex+1,rank) - totalSkillPointsForLevel(rowIndex,rank);
		
		NSInteger seconds = [character trainingTimeInSeconds:primaryAttr 
												   secondary:secondaryAttr 
												 skillPoints:totalForLevel];
		
		return stringTrainingTime(seconds);
		
	}else if([[aTableColumn identifier]isEqualToString:SD_TOTAL]){
		NSInteger time = 0;
		
		for(NSInteger i = 0; i <= rowIndex; i++){
			/*
			 time += [character trainingTimeInSeconds:[skill typeID]
			 fromLevel:i
			 toLevel:i+1
			 accountForTrainingSkill:NO];
			 */
			
			NSInteger rank = [skill skillRank];
			NSInteger primaryAttr = [skill primaryAttr];
			NSInteger secondaryAttr = [skill secondaryAttr];
			
			NSInteger totalForLevel = 
			totalSkillPointsForLevel(i+1,rank) - totalSkillPointsForLevel(i,rank);
			
			time += [character trainingTimeInSeconds:primaryAttr 
										   secondary:secondaryAttr 
										 skillPoints:totalForLevel];
		}
		return stringTrainingTime(time);
		
	}else if([[aTableColumn identifier]isEqualToString:SD_FROM_NOW]){
		if([skill skillLevel] > rowIndex){
			return NSLocalizedString(@"Already Trained",
									 @"skill details window. skill Already Trained to level x");
		}
		NSInteger time = 0;
		
		for(NSInteger i = [skill skillLevel]; i < rowIndex+1; i++){
			time += [character trainingTimeInSeconds:[skill typeID]
										   fromLevel:i
											 toLevel:i+1
							 accountForTrainingSkill:YES];
		}
		return stringTrainingTime(time);
		
	}
	return nil;
}

@end
