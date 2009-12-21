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

-(void) buildColumnList
{
	if(columnList != nil){
		[columnList release];
	}
	
	ColumnConfigManager *manager = [ColumnConfigManager manager];
	columnList = [[manager columns]mutableCopy];
}

-(id) init
{
	if((self = [super initWithNibName:@"SkillPlannerConfig" bundle:nil])){
		name = @"Skill Planner";
		[self buildColumnList];
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

-(IBAction) resetToDefaults:(id)sender
{
	ColumnConfigManager *manager = [ColumnConfigManager manager];
	[manager resetConfig];
	
	//[self buildColumnList];
	[columnList removeAllObjects];
	[columnList addObjectsFromArray:[manager columns]];
	
	[columnTable reloadData];
}


@end
