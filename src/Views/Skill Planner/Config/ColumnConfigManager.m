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


#import "ColumnConfigManager.h"

#import "macros.h"

#define SKILL_PLAN_CONFIG @"skill_plan_config"

@implementation ColumnConfigManager

-(id) init
{
	if((self = [super init])){
		[self readConfig];
	}
	return self;
}

-(void)dealloc
{
	[columnList release];
	[super dealloc];
}

+(ColumnConfigManager*) manager
{
	return [[[ColumnConfigManager alloc]init]autorelease];
}

-(NSArray*) buildDefaultColumnList
{
	PlannerColumn *col;
	NSMutableArray *array = [[[NSMutableArray alloc]init]autorelease];
	
	col = [[PlannerColumn alloc]initWithName:NSLocalizedString(@"Skill Name",@"Skill plan column header")
								  identifier:COL_PLAN_SKILLNAME 
									  status:YES
									   width:175.0f];
	[array addObject:col];
	[col release];
	
	col = [[PlannerColumn alloc]initWithName:NSLocalizedString(@"Training Time",@"Skill plan column header")
								  identifier:COL_PLAN_TRAINING_TIME
									  status:YES
									   width:95.0f];
	[array addObject:col];
	[col release];
	
	col = [[PlannerColumn alloc]initWithName:NSLocalizedString(@"Running Total",@"Skill plan column header")
								  identifier:COL_PLAN_TRAINING_TTD
									  status:NO
									   width:90.0f];
	[array addObject:col];
	[col release];
	
	col = [[PlannerColumn alloc]initWithName:NSLocalizedString(@"SP/Hr",@"Skill plan column header")
								  identifier:COL_PLAN_SPHR
									  status:NO
									   width:50.0f];
	[array addObject:col];
	[col release];
	
	col = [[PlannerColumn alloc]initWithName:NSLocalizedString(@"Start Date",@"Skill plan column header")
								  identifier:COL_PLAN_CALSTART
									  status:YES
									   width:125.0f];
	[array addObject:col];
	[col release];
	
	col = [[PlannerColumn alloc]initWithName:NSLocalizedString(@"Finish Date",@"Skill plan column header")
								  identifier:COL_PLAN_CALFINISH
									  status:NO
									   width:125.0f];
	[array addObject:col];
	[col release];
	
	col = [[PlannerColumn alloc]initWithName:NSLocalizedString(@"Progress",@"Skill plan column header")
								  identifier:COL_PLAN_PERCENT
									  status:YES
									   width:50.0f];
	[array addObject:col];
	[col release];
	
	/*
	col = [[PlannerColumn alloc]initWithName:@"Buttons"
								  identifier:COL_PLAN_BUTTONS 
									  status:NO
									   width:50.0f];
	[array addObject:col];
	[col release];
	*/
	return array;
}

-(void) readConfig
{
	if(columnList != nil){
		[columnList release];
		columnList = nil;
	}
	
	//Create the default list
	
	//load up the saved list and merge the two.
	//Note: if new columns are added then they will never be seen.  fix this.
	
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SKILL_PLAN_CONFIG];
	if(data != nil){
		NSArray *ary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		columnList = [ary mutableCopy];
	}else{
		//Column list has been built from defaults.
		columnList = [[self buildDefaultColumnList]retain];
	}
}

-(void) writeConfig
{
	if(columnList != nil){
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:columnList];
		
		[defaults setObject:data forKey:SKILL_PLAN_CONFIG];
		
		[defaults synchronize];
	}
}

-(void) eraseConfig
{
	[[NSUserDefaults standardUserDefaults]removeObjectForKey:SKILL_PLAN_CONFIG];
	[[NSUserDefaults standardUserDefaults]synchronize];
}

-(void) resetConfig
{
	[self eraseConfig];
	[self readConfig];
}

-(PlannerColumn*) columnForIdentifer:(NSString*)identifier
{
	for(PlannerColumn *pcol in columnList){
		if([[pcol identifier]isEqualToString:identifier]){
			return pcol;
		}
	}
	NSLog(@"%@ not found in columnList",identifier);
	return nil;
}

-(BOOL) setWidth:(CGFloat)width forColumn:(NSString*)columnId
{
	PlannerColumn *pcol = [self columnForIdentifer:columnId];
	if(pcol == nil){
		return NO;
	}
	
	[pcol setColumnWidth:(float)width];
	[self writeConfig];
	return YES;
}

-(BOOL) setOrder:(NSInteger)position forColumn:(NSString*)columnId
{
	return NO;
}

-(NSArray*) columns
{
	return [[columnList copy]autorelease];
}

-(BOOL) moveColumn:(NSInteger)from toPosition:(NSInteger)to
{
	
}

@end
