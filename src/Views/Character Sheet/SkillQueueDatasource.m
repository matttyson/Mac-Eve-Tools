//
//  SkillQueueDatasource.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 10/04/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SkillQueueDatasource.h"

#import "SkillPlan.h"
#import "Skill.h"
#import "SkillPair.h"
#import "MTEveSkillQueueCell.h"
#import "Character.h"

@implementation SkillQueueDatasource

@synthesize character;
@synthesize plan;
@synthesize firstSkillCountdown;

-(SkillQueueDatasource*)init
{
	self = [super init];
	
	if(self){
		plan = nil;
		character = nil;
	}
	
	return self;
}

-(void)dealloc
{
	[plan release];
	[character release];
	[super dealloc];
}

-(void)tick
{
	if(firstSkillCountdown > 0){
		firstSkillCountdown--;
	}
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [plan skillCount];
}


- (id)tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSInteger)rowIndex
{
	return nil;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	return 36.0;
}


- (void)tableView:(NSTableView *)aTableView 
  willDisplayCell:(id)aCell 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(NSInteger)rowIndex
{
	if(plan == nil){
		return;
	}
	if(character == nil){
		return;
	}
	if([aCell isKindOfClass:[MTEveSkillQueueCell class]]){
		MTEveSkillQueueCell *cell = aCell;
		SkillPair *pair = [plan skillAtIndex:rowIndex];
		
		NSNumber *typeID = [pair typeID];
		NSInteger skillLevel = [pair skillLevel];
		
		[cell setSkill:[[character skillTree]skillForId:typeID]];
		[cell setPair:pair];
		
		NSInteger trainTime;
		
		if(rowIndex == 0){
			/*
			 This is a hack for getting the completion times to line
			 up properly with all the other completion times on the character sheet page.
			 */
			trainTime = firstSkillCountdown;
		}else{
			trainTime = [character trainingTimeInSeconds:typeID 
											   fromLevel:skillLevel-1 
												 toLevel:skillLevel 
								 accountForTrainingSkill:YES];
		}
		[cell setTimeLeft:trainTime];
		
		if(rowIndex == 0){
			CGFloat progress = [character percentCompleted:[pair typeID] fromLevel:skillLevel-1 toLevel:skillLevel];
			[cell setPercentCompleted:progress];
		}else{
			
			Skill *s = [[character skillTree]skillForId:typeID];
			if(s == nil){
				[cell setPercentCompleted:0];
			}else{
				[cell setPercentCompleted:
				 [character percentCompleted:typeID fromLevel:skillLevel-1 toLevel:skillLevel]
				 ];
			}
		}
	}
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
	return NO;
}

- (BOOL)tableView:(NSTableView *)aTableView 
shouldEditTableColumn:(NSTableColumn *)aTableColumn 
			  row:(NSInteger)rowIndex
{
	return NO;
}

@end
