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
	origTrainTimeSeconds = [attrQueue calculateTrainingTimeForCharacter:character];
	NSString *str = stringTrainingTime(origTrainTimeSeconds);
	[origTrainTime setStringValue:str];
	[origTrainTime sizeToFit];
}

-(void)calculateTrainingDifference
{
	NSInteger diff = origTrainTimeSeconds - newTrainTimeSeconds;
	NSString *str = stringTrainingTime(diff);
	[diffTrainTime setStringValue:str];
	[diffTrainTime sizeToFit];
}

-(void)calculateRevisedTrainingTime
{
	NSInteger trainingTime = [attrQueue calculateTrainingTimeForCharacter:character];
	
	newTrainTimeSeconds = trainingTime;
	NSString *str = stringTrainingTime(newTrainTimeSeconds);
	[newTrainTime setStringValue:str];
	[newTrainTime sizeToFit];
	
	[self calculateTrainingDifference];
}

-(void)setAttrValues
{
	origTrainTimeSeconds = 0;
	newTrainTimeSeconds = 0;
	
	intelligence = [character attributeValue:ATTR_INTELLIGENCE];
	perception = [character attributeValue:ATTR_PERCEPTION];
	charisma = [character attributeValue:ATTR_CHARISMA];
	willpower = [character attributeValue:ATTR_WILLPOWER];
	memory = [character attributeValue:ATTR_MEMORY];
	
	[intField setIntegerValue:intelligence];
	[perField setIntegerValue:perception];
	[chrField setIntegerValue:charisma];
	[wilField setIntegerValue:willpower];
	[memField setIntegerValue:memory];
	
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

-(void)sheetDidEnd:(NSWindow *)theSheet 
		returnCode:(NSInteger)returnCode 
	   contextInfo:(void *)contextInfo;
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
	
	character = nil;
	plan = nil;
	
	[NSApp endSheet:sheet];
}

-(void) updateTotalAttributePoints
{
	totalPoints = intelligence + perception + charisma + willpower + memory;
	
	NSInteger allocatedPoints = 
	[intStepper integerValue] + 
	[perStepper integerValue] +
	[chrStepper integerValue] +
	[wilStepper integerValue] +
	[memStepper integerValue];
	
	NSInteger pointDifference = totalPoints - allocatedPoints;
	
	[totalAttributePoints setIntegerValue:pointDifference];
}

-(NSInteger) valueFromSender:(id)sender
{
	NSInteger value = [sender integerValue];
	
	if(value < 5){
		value = 5;
	}
	
	//[self updateTotalAttributePoints];
	
	return value;
}

-(IBAction) willpowerUpdate:(id)sender
{
	NSInteger newValue = [self valueFromSender:sender];
	NSInteger modValue = newValue - willpower;
	
	[wilStepper setIntegerValue:newValue];
	[wilField setIntegerValue:newValue];
	
	[character setAttribute:ATTR_WILLPOWER toLevel:modValue];
	[character processAttributeSkills];
	
	[self updateStringValues];
}

-(IBAction) intelligenceUpdate:(id)sender
{
	NSInteger newValue = [self valueFromSender:sender];
	NSInteger modValue = newValue - intelligence;
	
	[intStepper setIntegerValue:newValue];
	[intField setIntegerValue:newValue];
	
	[character setAttribute:ATTR_INTELLIGENCE toLevel:modValue];
	[character processAttributeSkills];
	
	[self updateStringValues];
}

-(IBAction) charismaUpdate:(id)sender
{
	NSInteger newValue = [self valueFromSender:sender];
	NSInteger modValue = newValue - charisma;
	
	[chrStepper setIntegerValue:newValue];
	[chrField setIntegerValue:newValue];
	
	[character setAttribute:ATTR_CHARISMA toLevel:modValue];
	[character processAttributeSkills];
	
	[self updateStringValues];
}

-(IBAction) perceptionUpdate:(id)sender
{
	NSInteger newValue = [self valueFromSender:sender];
	NSInteger modValue = newValue - perception;
	
	[perStepper setIntegerValue:newValue];
	[perField setIntegerValue:newValue];
	
	[character setAttribute:ATTR_PERCEPTION toLevel:modValue];
	[character processAttributeSkills];
	
	[self updateStringValues];
}

-(IBAction) memoryUpdate:(id)sender
{
	NSInteger newValue = [self valueFromSender:sender];
	NSInteger modValue = newValue - memory;
	
	[memStepper setIntegerValue:newValue];
	[memField setIntegerValue:newValue];
	
	[character setAttribute:ATTR_MEMORY toLevel:modValue];
	[character processAttributeSkills];
	
	[self updateStringValues];
}

@end
