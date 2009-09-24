//
//  SkillPlanConfig.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 23/09/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SkillPlanConfig.h"
#import "PlannerColumn.h"
#import "macros.h"

#define SKILL_PLAN_CONFIG @"skill_plan_config"

@implementation SkillPlanConfig

-(NSArray*) buildDefaultColumnList
{
	PlannerColumn *col;
	NSMutableArray *array = [[[NSMutableArray alloc]init]autorelease];
	
	col = [[PlannerColumn alloc]initWithName:@"Skill Name" 
								  identifier:COL_PLAN_SKILLNAME 
									  status:YES
									   width:175.0f];
	[array addObject:col];
	[col release];
	
	col = [[PlannerColumn alloc]initWithName:@"Training Time"
								  identifier:COL_PLAN_TRAINING_TIME
									  status:YES
									   width:90.0f];
	[array addObject:col];
	[col release];
	
	col = [[PlannerColumn alloc]initWithName:@"Running Total"
								  identifier:COL_PLAN_TRAINING_TTD
									  status:NO
									   width:90.0f];
	[array addObject:col];
	[col release];
	
	col = [[PlannerColumn alloc]initWithName:@"SP/Hr"
								  identifier:COL_PLAN_SPHR
									  status:NO
									   width:50.0f];
	[array addObject:col];
	[col release];
	
	col = [[PlannerColumn alloc]initWithName:@"Start Date"
								  identifier:COL_PLAN_CALSTART
									  status:YES
									   width:125.0f];
	[array addObject:col];
	[col release];
	
	col = [[PlannerColumn alloc]initWithName:@"Finish Date"
								  identifier:COL_PLAN_CALFINISH
									  status:NO
									   width:125.0f];
	[array addObject:col];
	[col release];
	
	col = [[PlannerColumn alloc]initWithName:@"Progress"
								  identifier:COL_PLAN_PERCENT
									  status:YES
									   width:50.0f];
	[array addObject:col];
	[col release];
	
	return array;
}

-(void) readDefaults
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if(columnList != nil){
		[columnList release];
	}
	
	NSData *data = [defaults objectForKey:SKILL_PLAN_CONFIG];
	if(data != nil){
		NSArray *ary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		columnList = [ary mutableCopy];
	}else{
		//Nothing has been saved, read in the defaults.
		columnList = [[self buildDefaultColumnList]retain];
	}
	
	//Note - will need to 
}

-(void) writeDefaults
{	
	if(columnList != nil){
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:columnList];
		
		[defaults setObject:data forKey:SKILL_PLAN_CONFIG];
	}
}

-(id) init
{
	if((self = [super initWithNibName:@"SkillPlannerConfig" bundle:nil])){
		name = @"Skill Planner";
		columnList = [[self buildDefaultColumnList]retain];
		[self readDefaults];
	}
	return self;
}


#define PLAN_CONFIG_TYPE @"MTSkillConfigColumn"

-(void)awakeFromNib
{
	[columnTable setDataSource:self];
	
	[columnTable registerForDraggedTypes:[NSArray arrayWithObject:PLAN_CONFIG_TYPE]];
//	[columnTable setDragging
}

-(void)dealloc
{
	[columnList release];
	[super dealloc];
}

#pragma mark Tableview datasource

- (BOOL)tableView:(NSTableView *)aTableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
     toPasteboard:(NSPasteboard*)pboard
{
	NSUInteger row = [rowIndexes firstIndex];
	
	id<NSCoding> object = [columnList objectAtIndex:row];
	
	NSArray *pBoardTypes = [NSArray arrayWithObject:PLAN_CONFIG_TYPE];
	[pboard declareTypes:pBoardTypes owner:self];
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
	
	[pboard setData:data forType:PLAN_CONFIG_TYPE];
	
	return YES;
}

- (BOOL)tableView:(NSTableView *)aTableView 
	   acceptDrop:(id < NSDraggingInfo >)info 
			  row:(NSInteger)row 
	dropOperation:(NSTableViewDropOperation)operation
{
	if(operation != NSTableViewDropOn){
		return NO;
	}
	
	PlannerColumn *object = [NSKeyedUnarchiver unarchiveObjectWithData:
							 [[info draggingPasteboard]dataForType:PLAN_CONFIG_TYPE]];
	
	
	//remove the old row
	NSInteger i = 0;
	NSInteger removeRow = -1;
	for(PlannerColumn *pcol in columnList){
		if([[pcol identifier]isEqualToString:[object identifier]]){
			removeRow = i;
			break;
		}
		i++;
	}
	
	if(removeRow != -1){
		[columnList removeObjectAtIndex:removeRow];
	}
	
	
	//insert the new row
	if(row >= [columnList count]){
		[columnList addObject:object];
	}else{
		[columnList insertObject:object atIndex:row];
	}
	
	[aTableView reloadData];
	
	return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView 
				validateDrop:(id < NSDraggingInfo >)info 
				 proposedRow:(NSInteger)row 
	   proposedDropOperation:(NSTableViewDropOperation)operation
{
	[aTableView setDropRow:row dropOperation:NSTableViewDropOn];
	return NSDragOperationMove;
}


@end
