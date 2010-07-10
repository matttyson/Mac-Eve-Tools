//
//  AttributeModifierDatasource.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 29/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AttributeModifierDatasource.h"

#import "macros.h"

#import "Character.h"
#import "SkillPlan.h"

#import "SkillPointAttributeTotal.h"
#import "SkillPointAttributeQueue.h"

#import "Helpers.h"

@implementation AttributeModifierDatasource

-(AttributeModifierDatasource*) initWithQueue:(SkillPointAttributeQueue*)queue 
								 forCharacter:(Character*)ch;
{
	self = [super init];
	if(self != nil){
		character = [ch retain];
		attrQueue = [queue retain];
	}
	
	return self;
}

-(void)dealloc
{
	[character release];
	[attrQueue release];
	[super dealloc];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [attrQueue count];
}

-(id) tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSInteger)rowIndex
{
	if([[aTableColumn identifier]isEqualToString:COL_PLAN_TRAINING_TIME]){
		NSInteger trainingTime = [attrQueue trainingTimeForIndex:rowIndex withCharacter:character];
		return stringTrainingTime(trainingTime);
	}else if([[aTableColumn identifier]isEqualToString:COL_PLAN_POINTS]){
		return [NSNumber numberWithInteger:[attrQueue skillPointsForIndex:rowIndex]];
	}else if([[aTableColumn identifier]isEqualToString:COL_PLAN_ATTRIBUTES]){
		return [NSString stringWithFormat:@"%@ / %@",
				strForAttrCode([attrQueue primaryAttributeForIndex:rowIndex]),
				strForAttrCode([attrQueue secondaryAttributeForIndex:rowIndex])];
	}
	return @"";
}

@end
