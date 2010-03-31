//
//  AttributeModifierController.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 29/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AttributeModifierController.h"

#import "GlobalData.h"

#import "Character.h"

#import "Skill.h"
#import "SkillPlan.h"
#import "SkillPair.h"

#import "SkillPointAttributeTotal.h"
#import "SkillPointAttributeQueue.h"

#import "AttributeModifierDatasource.h"

#import "macros.h"
#import "Helpers.h"

@implementation AttributeModifierController

-(void)calculateOriginalTrainingTime
{
	origTrainTimeInt = [attrQueue calculateTrainingTimeForCharacter:character];
	NSString *str = stringTrainingTime(origTrainTimeInt);
	[origTrainTime setStringValue:str];
	[origTrainTime sizeToFit];
}

-(void)calculateTrainingDifference
{
	NSInteger diff = origTrainTimeInt - newTrainTimeInt;
	NSString *str = stringTrainingTime(diff);
	[diffTrainTime setStringValue:str];
	[diffTrainTime sizeToFit];
}

-(void)calculateRevisedTrainingTime
{
	NSInteger trainingTime = [attrQueue calculateTrainingTimeForCharacter:character];
	
	newTrainTimeInt = trainingTime;
	NSString *str = stringTrainingTime(newTrainTimeInt);
	[newTrainTime setStringValue:str];
	[newTrainTime sizeToFit];
	
	[self calculateTrainingDifference];
}

-(void)setAttrValues
{
	origTrainTimeInt = 0;
	newTrainTimeInt = 0;
	
	intelligence = [character attributeValue:ATTR_INTELLIGENCE];
	perception = [character attributeValue:ATTR_PERCEPTION];
	charisma = [character attributeValue:ATTR_CHARISMA];
	willpower = [character attributeValue:ATTR_WILLPOWER];
	memory = [character attributeValue:ATTR_MEMORY];
	
	Skill *s = [[character skillSet]objectForKey:[NSNumber numberWithInteger:SKILL_LEARNING]];
	learning = [s skillLevel];
	
	[lrnField setIntegerValue:learning];
	[intField setIntegerValue:intelligence];
	[perField setIntegerValue:perception];
	[chrField setIntegerValue:charisma];
	[wilField setIntegerValue:willpower];
	[memField setIntegerValue:memory];
	
	[lrnStepper setIntegerValue:learning];
	[intStepper setIntegerValue:intelligence];
	[perStepper setIntegerValue:perception];
	[chrStepper setIntegerValue:charisma];
	[wilStepper setIntegerValue:willpower];
	[memStepper setIntegerValue:memory];
	
	[intValue setStringValue:[character getAttributeString:ATTR_INTELLIGENCE]];
	[perValue setStringValue:[character getAttributeString:ATTR_PERCEPTION]];
	[chrValue setStringValue:[character getAttributeString:ATTR_CHARISMA]];
	[wilValue setStringValue:[character getAttributeString:ATTR_WILLPOWER]];
	[memValue setStringValue:[character getAttributeString:ATTR_MEMORY]];
}

-(void) updateStringValues
{
	[intValue setStringValue:[character getAttributeString:ATTR_INTELLIGENCE]];
	[perValue setStringValue:[character getAttributeString:ATTR_PERCEPTION]];
	[chrValue setStringValue:[character getAttributeString:ATTR_CHARISMA]];
	[wilValue setStringValue:[character getAttributeString:ATTR_WILLPOWER]];
	[memValue setStringValue:[character getAttributeString:ATTR_MEMORY]];
	
	[skillPointTotals reloadData];
	[self calculateRevisedTrainingTime];
}

-(void)resetDataSource
{
	[skillPointTotals setDataSource:nil];
	
	if(attrQueue != nil){
		[attrQueue release];
		attrQueue = nil;
	}
	
	if(attrDS != nil){
		[attrDS release];
		attrDS = nil;
	}
}

-(void)processSkillPlanPoints
{
	[self resetDataSource];
	
	attrQueue = [[SkillPointAttributeQueue alloc]init];
	[attrQueue addPlanToQueue:plan];
	
	attrDS = [[AttributeModifierDatasource alloc]initWithQueue:attrQueue 
												  forCharacter:character];
	
	[skillPointTotals setDataSource:attrDS];
}

-(void)setCharacter:(Character*)ch andPlan:(SkillPlan*)pl
{
	character = ch;
	plan = pl;
	
	[character resetTempAttrBonus];
	[self setAttrValues];
	[self processSkillPlanPoints];
	[self calculateOriginalTrainingTime];
}

-(void)sheetDidEnd:(NSWindow *)theSheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
	[theSheet orderOut:self];
}

-(IBAction) resetButtonClick:(id)sender
{
	[character resetTempAttrBonus];
	
	[self setAttrValues];
	[self calculateOriginalTrainingTime];
	[self processSkillPlanPoints];
	[self updateStringValues];
}

-(IBAction) closeButtonClick:(id)sender
{
	[self resetDataSource];
	
	[character resetTempAttrBonus];
	[character processAttributeSkills];
	
	[origTrainTime setStringValue:@""];
	[newTrainTime setStringValue:@""];
	[diffTrainTime setStringValue:@""];
	[NSApp endSheet:sheet];
}

-(IBAction) learningUpdate:(id)sender
{
	NSInteger newValue = [sender integerValue];
	
	if(newValue > 5){
		newValue = 5;
	}
	
	NSInteger modValue = newValue - learning;
	
	[lrnStepper setIntegerValue:newValue];
	[lrnField setIntegerValue:newValue];
	
	[character setLearning:modValue];
	[character processAttributeSkills];
	
	[self updateStringValues];
}

-(IBAction) willpowerUpdate:(id)sender
{
	NSInteger modValue = [sender integerValue] - willpower;
	
	[wilStepper setIntegerValue:[sender integerValue]];
	[wilField setIntegerValue:[sender integerValue]];
	
	[character setAttribute:ATTR_WILLPOWER toLevel:modValue];
	[character processAttributeSkills];
	
	[self updateStringValues];
}

-(IBAction) intelligenceUpdate:(id)sender
{
	NSInteger modValue = [sender integerValue] - intelligence;
	
	[intStepper setIntegerValue:[sender integerValue]];
	[intField setIntegerValue:[sender integerValue]];
	
	[character setAttribute:ATTR_INTELLIGENCE toLevel:modValue];
	[character processAttributeSkills];
	
	[self updateStringValues];
}

-(IBAction) charismaUpdate:(id)sender
{
	NSInteger modValue = [sender integerValue] - charisma;
	
	[chrStepper setIntegerValue:[sender integerValue]];
	[chrField setIntegerValue:[sender integerValue]];
	
	[character setAttribute:ATTR_CHARISMA toLevel:modValue];
	[character processAttributeSkills];
	
	[self updateStringValues];
}

-(IBAction) perceptionUpdate:(id)sender
{
	NSInteger modValue = [sender integerValue] - perception;
	
	[perStepper setIntegerValue:[sender integerValue]];
	[perField setIntegerValue:[sender integerValue]];
	
	[character setAttribute:ATTR_PERCEPTION toLevel:modValue];
	[character processAttributeSkills];
	
	[self updateStringValues];
}

-(IBAction) memoryUpdate:(id)sender
{
	NSInteger modValue = [sender integerValue] - memory;
	
	[memStepper setIntegerValue:[sender integerValue]];
	[memField setIntegerValue:[sender integerValue]];
	
	[character setAttribute:ATTR_MEMORY toLevel:modValue];
	[character processAttributeSkills];
	
	[self updateStringValues];
}

@end
