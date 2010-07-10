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

#import "PlanView2Datasource.h"

#import "SkillPlan.h"
#import "Character.h"
#import "Helpers.h"
#import "GlobalData.h"
#import "Config.h"

#import <assert.h>

@implementation PlanView2Datasource

@synthesize planId;
@synthesize mode;

-(id) init
{
	if(self = [super init]){
		masterSkillSet = [[[[GlobalData sharedInstance]skillTree] skillSet]retain];
		mode = SPMode_none;
	}
	return self;
}

-(void) dealloc
{
	[masterSkillSet release];
	[super dealloc];
}

-(void) setViewDelegate:(id<PlanView2Delegate>)delegate
{
	viewDelegate = delegate;
}

-(Character*) character
{
	return character;
}
-(void) setCharacter:(Character*)c
{
	[character release];
	character = [c retain];
}

-(SkillPlan*) currentPlan
{
	if(mode != SPMode_plan){
		return nil;
	}
	return [character skillPlanById:planId];
}

-(void) removeSkillsFromPlan:(NSArray*)skillIndexes
{
	SkillPlan *plan = [self currentPlan];
	[plan removeSkillArrayFromPlan:skillIndexes];
	[plan savePlan];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	switch (mode) {
		case SPMode_none:
			return 0;
		case SPMode_overview:
			return [character skillPlanCount];
		case SPMode_plan:
			return [[character skillPlanById:planId]skillCount];
		default:
			assert(0);
			break;
	}
	return 0;	
}

-(id) tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSInteger)rowIndex
{
	SkillPlan *skillPlan;
	/*Fetch the skill plan we are displaying*/
	if(mode == SPMode_overview){
		skillPlan = [character skillPlanAtIndex:rowIndex];
	}else{
		skillPlan = [character skillPlanById:planId];
	}
	
	if([[aTableColumn identifier]isEqualToString:COL_POV_NAME]){
		return [skillPlan planName];
	}else if([[aTableColumn identifier]isEqualToString:COL_POV_SKILLCOUNT]){
		return [NSNumber numberWithInteger:[skillPlan skillCount]];
	}else if([[aTableColumn identifier]isEqualToString:COL_POV_TIMELEFT]){
		return stringTrainingTime([skillPlan trainingTime]); 
	}
	
	/*Skill PLAN view datasource methods*/
	SkillPair *sp = [skillPlan skillAtIndex:rowIndex];
	Skill *s = [masterSkillSet objectForKey:[sp typeID]];
	
	if([[aTableColumn identifier] isEqualToString:COL_PLAN_SKILLNAME]){
		return [NSString stringWithFormat:@"%@ %@",[s skillName],romanForInteger([sp skillLevel])];
	}else if([[aTableColumn identifier] isEqualToString:COL_PLAN_SPHR]){
		return [skillPlan spHrForSkill:rowIndex];
	}else if([[aTableColumn identifier] isEqualToString:COL_PLAN_TRAINING_TIME]){
		NSInteger trainingTime = (NSInteger)[[skillPlan skillTrainingFinish:rowIndex]
											 timeIntervalSinceDate:[skillPlan skillTrainingStart:rowIndex]];
		if(trainingTime == 0){
			return NSLocalizedString(@"Complete",@"Skill planner. Training Time column.  Skill has finished training.");
		}else{
			return stringTrainingTime(trainingTime);
		}
	}else if([[aTableColumn identifier] isEqualToString:COL_PLAN_TRAINING_TTD]){
		NSInteger trainingTime = (NSInteger)[[skillPlan skillTrainingFinish:rowIndex]
											 timeIntervalSinceDate:[skillPlan skillTrainingStart:0]];
		return stringTrainingTime(trainingTime);
	}else if([[aTableColumn identifier] isEqualToString:COL_PLAN_CALSTART]){
		/*the date and time that this skill will start training*/
		return [[GlobalData sharedInstance]formatDate:[skillPlan skillTrainingStart:rowIndex]];
	}else if([[aTableColumn identifier] isEqualToString:COL_PLAN_CALFINISH]){
		return [[GlobalData sharedInstance]formatDate:[skillPlan skillTrainingFinish:rowIndex]];
	}else if([[aTableColumn identifier] isEqualToString:COL_PLAN_PERCENT]){
		
		/*push this into the skill plan class?*/
		if([character isTraining]){
			/*if the skill we are looking at is the currently training skill*/
			if([[sp typeID]integerValue] == [character integerForKey:CHAR_TRAINING_TYPEID]){
				/*if it is the currently training level*/
				if([sp skillLevel] == [character integerForKey:CHAR_TRAINING_LEVEL]){
					/*calculate the percentage completed*/
					NSInteger currentSP = [character currentSPForTrainingSkill];
					NSInteger startSP = totalSkillPointsForLevel([sp skillLevel]-1,[s skillRank]);
					NSInteger finishSP = totalSkillPointsForLevel([sp skillLevel],[s skillRank]);
					CGFloat percentCompleted = 
						skillPercentCompleted(startSP,
											  finishSP,
											  currentSP) * 100.0;
					long int intPercent = xlround(percentCompleted);
					return [NSString stringWithFormat:@"%ld%%",MIN(intPercent,100l)];
				}
			}
		}
		CGFloat percentCompleted = [character percentCompleted:[sp typeID]
													 fromLevel:[sp skillLevel]-1 
													   toLevel:[sp skillLevel]];
		long int intPercent = xlround(percentCompleted * 100.0);
		
		return [NSString stringWithFormat:@"%ld%%",MIN(intPercent,100l)];
	}
	return nil;
}

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(NSInteger)rowIndex
{
	SkillPlan *plan = [character skillPlanAtIndex:rowIndex];
	NSString *oldName = [[plan planName]retain];
	[plan setPlanName:anObject];
	if(![character renameSkillPlan:plan]){ //verify that the name change succeded
		[plan setPlanName:oldName];//rename failed. restore old name.
	}
	[oldName release];
}

-(NSMenu*) tableView:(NSTableView*)table 
  menuForTableColumn:(NSTableColumn*)column 
				 row:(NSInteger)row
{
	/*
	 this right click is to remove skills from the skill plan.  we have to figure out if removing the skill being removed
	 from the plan has prerequisites, and remove them as well.
	 */
	
	if(row == -1){
		return nil;
	}
	
	NSMenu *menu = nil;
	SkillPlan *skillPlan = nil;
	NSMenuItem *item = nil;
	NSNumber *planRow = [NSNumber numberWithInteger:row];
	
	menu = [[[NSMenu alloc]initWithTitle:@""]autorelease];

	if(mode == SPMode_plan){
		
		skillPlan = [character skillPlanById:planId];
		
		if(skillPlan == nil){
			return nil;
		}
		
		SkillPair *sp = [skillPlan skillAtIndex:row];
		Skill *s = [masterSkillSet objectForKey:[sp typeID]];
		
		
		item = [[NSMenuItem alloc]initWithTitle:[s skillName] 
										 action:@selector(displaySkillWindow:) 
								  keyEquivalent:@""];
		[item setRepresentedObject:s];
		[menu addItem:item];
		[item release];
		
		[menu addItem:[NSMenuItem separatorItem]];
		
		item = [[NSMenuItem alloc]initWithTitle:[NSString stringWithFormat:
												 NSLocalizedString(@"Remove %@ %@",@"Remove <SkillName> <SkillLevel>"),[s skillName],
															 romanForInteger([sp skillLevel])]
													 action:@selector(removeSkillFromPlan:)
											  keyEquivalent:@""];
		[item setRepresentedObject:planRow];
		[menu addItem:item];
		[item release];
		
		/*
		 If the skill is not planned to a level higher than the current level
		 then add the option to right-click and train to a particular level.
		 */
		
//		if([sp skillLevel] < 5){
		
		NSInteger queuedIndex;
		NSInteger queuedMax = [[self currentPlan]maxLevelForSkill:[sp typeID] atIndex:&queuedIndex];
		
		if(queuedMax < 5){
			for(NSInteger i = queuedMax + 1; i <= 5; i++){
				item = [[NSMenuItem alloc]initWithTitle:
						[NSString stringWithFormat:
						 NSLocalizedString(@"Train to level %@",@"Train skill to level"),romanForInteger(i) ]
												 action:@selector(trainSkillToLevel:)
										  keyEquivalent:@""];
				
				SkillPair *newPair = [[SkillPair alloc]initWithSkill:[sp typeID] level:i];
				
				[item setRepresentedObject:newPair];
				[menu addItem:item];
				[item release];
				[newPair release];
			}
		}
		
	}else if(mode == SPMode_overview){
		skillPlan = [character skillPlanAtIndex:row];
		
		if(skillPlan == nil){
			return nil;
		}
		
		item = [[NSMenuItem alloc]initWithTitle:[skillPlan planName] 
										 action:@selector(activatePlanAtRow:) 
								  keyEquivalent:@""];
		[item setRepresentedObject:planRow];
		[menu addItem:item];
		[item release];
		
		[menu addItem:[NSMenuItem separatorItem]];
		 
		item = [[NSMenuItem alloc]initWithTitle:NSLocalizedString(@"Delete",@"Delete a skill plan")
													action:@selector(removeSkillPlanFromOverview:)
											  keyEquivalent:@""];
		[item setRepresentedObject:planRow];
		[menu addItem:item];
		[item release];
		
		item = [[NSMenuItem alloc]initWithTitle:NSLocalizedString(@"Rename",@"Rename a skill plan")
										 action:@selector(renameSkillPlan:) 
								  keyEquivalent:@""];
		[item setRepresentedObject:planRow];
		[menu addItem:item];
		[item release];
	}
	
	return menu;
}

-(BOOL) shouldHighlightCell:(NSInteger)rowIndex
{
	if([character isTraining]){
		SkillPlan *plan = [character skillPlanById:planId];
		SkillPair *sp = [plan skillAtIndex:rowIndex];
		if([[sp typeID]integerValue] == [character integerForKey:CHAR_TRAINING_TYPEID]){
			if([sp skillLevel] == [character integerForKey:CHAR_TRAINING_LEVEL]){
				return YES;
			}
		}
	}
	return NO;
}

-(void) addSkillArrayToActivePlan:(NSArray*)skillArray
{
	if(mode == SPMode_plan){
		SkillPlan *plan = [character skillPlanById:planId];
		[plan addSkillArrayToPlan:skillArray];
	}
}

#pragma mark Drag and drop methods
- (BOOL)tableView:(NSTableView *)tv 
writeRowsWithIndexes:(NSIndexSet *)rowIndexes 
	 toPasteboard:(NSPasteboard*)pboard 
{
	[pboard declareTypes:[NSArray arrayWithObject:MTSkillIndexPBoardType] owner:self];
	
	id array;
	NSMutableData *data = [[NSMutableData alloc]initWithCapacity:0];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
	
	[archiver setOutputFormat:NSPropertyListBinaryFormat_v1_0];
	
	NSUInteger count = [rowIndexes count];
	
	if(count == 1){
		array = [NSArray arrayWithObject:[NSNumber numberWithInteger:[rowIndexes firstIndex]]];
	}else{
		array = [[[NSMutableArray alloc]initWithCapacity:count]autorelease];
		
		NSUInteger *indexBuffer = malloc(sizeof(NSUInteger) * count);
		
		[rowIndexes getIndexes:indexBuffer maxCount:count inIndexRange:nil];
		
		for(NSUInteger i=0; i < count; i++){
			[array addObject:[NSNumber numberWithInteger:(NSInteger)indexBuffer[i]]];
		}
		
		free(indexBuffer);
	}
	
	[archiver encodeObject:array forKey:DRAG_SKILLINDEX];
	
	[archiver finishEncoding];
	
	[pboard setData:data forType:MTSkillIndexPBoardType];
	
	[archiver release];
	[data release];
	
	return YES;
}


- (NSDragOperation)tableView:(NSTableView *)aTableView
				validateDrop:(id < NSDraggingInfo >)info
				 proposedRow:(NSInteger)row 
	   proposedDropOperation:(NSTableViewDropOperation)operation
{
	if(mode == SPMode_overview){
		return NSDragOperationCopy;
	}
	
	if([info draggingSource] == aTableView){
		[aTableView setDropRow:row dropOperation:NSTableViewDropAbove];
		return NSDragOperationMove;
	}
	
	return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)aTableView 
	   acceptDrop:(id < NSDraggingInfo >)info 
			  row:(NSInteger)row 
	dropOperation:(NSTableViewDropOperation)operation
{
	SkillPlan *plan = [character skillPlanById:planId];
	
	if([info draggingSource] == aTableView){
		/*We are reording skills within a plan*/
		NSData *data = [[info draggingPasteboard]dataForType:MTSkillIndexPBoardType];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
		NSArray *indexArray = [unarchiver decodeObjectForKey:DRAG_SKILLINDEX];
		
		[unarchiver finishDecoding];
		[unarchiver release];
		
		BOOL rc = [plan moveSkill:indexArray to:row];
		
		if(rc){
			[plan savePlan];
			[viewDelegate refreshPlanView];
			[aTableView deselectAll:self];
		}
		
		return rc;
		
	}else{
		/*
		 this is a copy array type.  If we are in overview mode, append skills to the existing plan,
		 or create a new plan, if is not dropped on an existing plan.
		 
		 if it is not overview mode, append to the current planId
		 */
		NSData *data = [[info draggingPasteboard]dataForType:MTSkillArrayPBoardType];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
		
		NSArray *array = [unarchiver decodeObject];
		
		[unarchiver finishDecoding];
		[unarchiver release];
		
		if(mode == SPMode_plan){
			/*we are looking at a skill plan - append skills to the plan*/
			[plan addSkillArrayToPlan:array];
			[plan savePlan];
			[viewDelegate refreshPlanView];
			return YES;
		}else if(mode == SPMode_overview){
			if(operation == NSTableViewDropOn){
				/*find the plan we are dropping on, append skills to this plan*/
				//SkillPlan *dropPlan = [character skillPlanAtIndex:row];
				[plan addSkillArrayToPlan:array];
				[plan savePlan];
				[aTableView setNeedsDisplayInRect:[aTableView frameOfCellAtColumn:1 row:row]];
				[aTableView setNeedsDisplayInRect:[aTableView frameOfCellAtColumn:2 row:row]];
				return YES;
			}else if(operation == NSTableViewDropAbove){
				return NO;
			}
		}
	}
	return NO;
}

@end
