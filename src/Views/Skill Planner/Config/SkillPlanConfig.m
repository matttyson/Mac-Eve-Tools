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

#import "SkillPlanConfig.h"
#import "PlannerColumn.h"
#import "macros.h"

#import "ColumnConfigManager.h"



@implementation SkillPlanConfig

/*

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
									   width:95.0f];
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
	
	//Create the default list
	
	//load up the saved list and merge the two.
	//Note: if new columns are added then they will never be seen.  fix this.
	
	NSData *data = [defaults objectForKey:SKILL_PLAN_CONFIG];
	if(data != nil){
		NSArray *ary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		columnList = [ary mutableCopy];
	}else{
		columnList = [[self buildDefaultColumnList]retain];
	}
}
*/


/*this is still a bit hacky*/

-(void) writeDefaults
{	
	if(columnList != nil){
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:columnList];
		
		[defaults setObject:data forKey:SKILL_PLAN_CONFIG];
		
		[defaults synchronize];
	}
}

-(id) init
{
	if((self = [super initWithNibName:@"SkillPlannerConfig" bundle:nil])){
		name = @"Skill Planner";
		
		manager = [[ColumnConfigManager alloc]init];
		columnList = [[manager columns]mutableCopy];
	}
	return self;
}


#define PLAN_CONFIG_TYPE @"MTSkillConfigColumn"

-(void)awakeFromNib
{
	[columnTable setDataSource:self];
	
	[columnTable registerForDraggedTypes:[NSArray arrayWithObject:PLAN_CONFIG_TYPE]];
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
