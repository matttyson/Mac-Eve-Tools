//
//  SkillPlannerPrefView.m
//  Mac Eve Tools
//
//  Created by Sebastian on 20.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SkillPlannerPrefViewController.h"
#import "ColumnConfigManager.h"
#import "macros.h"
#import "PlannerColumn.h"


@implementation SkillPlannerPrefViewController

@synthesize columnList, columnTable, defaultButton;

- (NSString *)title
{
	return NSLocalizedString(@"Skill Planner", @"Skill Planner settings");
}

- (NSString *)identifier
{
	return @"SkillPlannerPrefView";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"icon22_41"];
}

-(void) buildColumnList
{
	if(self.columnList != nil){
		[self.columnList removeAllObjects];
	}
	else {
		self.columnList = [[NSMutableArray alloc] init];
	}

	[self.columnList addObjectsFromArray:[[ColumnConfigManager manager] columns]];
}

#define PLAN_CONFIG_TYPE @"MTSkillConfigColumn"

-(void)awakeFromNib
{
	[self.columnTable registerForDraggedTypes:[NSArray arrayWithObject:PLAN_CONFIG_TYPE]];
	[self buildColumnList];
}

-(void)dealloc
{
	[self.columnList release];
	[super dealloc];
}

#pragma mark Tableview datasource

- (BOOL)tableView:(NSTableView *)aTableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
     toPasteboard:(NSPasteboard*)pboard
{
	NSUInteger row = [rowIndexes firstIndex];
	
	id<NSCoding> object = [self.columnList objectAtIndex:row];
	
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
	for(PlannerColumn *pcol in self.columnList){
		if([[pcol identifier]isEqualToString:[object identifier]]){
			removeRow = i;
			break;
		}
		i++;
	}
	
	if(removeRow != -1){
		[self.columnList removeObjectAtIndex:removeRow];
	}
	
	
		//insert the new row
	if(row >= [columnList count]){
		[self.columnList addObject:object];
	}else{
		[self.columnList insertObject:object atIndex:row];
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

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [self.columnList count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	PlannerColumn *column = [self.columnList objectAtIndex:row];
	
	if([[tableColumn identifier]isEqualToString:@"NAME"]){
		return column.columnName;
	}
	
	if([[tableColumn identifier]isEqualToString:@"ACTIVE"]){		
		if(column.active){
			return [NSNumber numberWithInteger:NSOnState];
		}else{
			return [NSNumber numberWithInteger:NSOffState];
		}
	}
	return nil;
}

-(IBAction) resetToDefaults:(id)sender
{
	ColumnConfigManager *manager = [ColumnConfigManager manager];
	[manager resetConfig];
	
		//[self buildColumnList];
	[self.columnList removeAllObjects];
	[self.columnList addObjectsFromArray:[manager columns]];
	
	[self.columnTable reloadData];
}

- (void) willBeClosed {
	if(columnList != nil){
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:columnList];
		[defaults setObject:data forKey:SKILL_PLAN_CONFIG];
		[defaults synchronize];
	}
}

- (void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if ([[tableColumn identifier] isEqual:@"ACTIVE"] ==  TRUE) {
		PlannerColumn *column = [self.columnList objectAtIndex:row];
		column.active = !column.active;
	}
}

@end
