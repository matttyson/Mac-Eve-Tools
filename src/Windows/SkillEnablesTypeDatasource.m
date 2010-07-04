//
//  SkillEnablesTypeDatasource.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 4/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "macros.h"
#import "SkillEnablesTypeDatasource.h"
#import "GlobalData.h"
#import "METDependSkill.h"
#import "CCPDatabase.h"

@implementation SkillEnablesTypeDatasource

-(SkillEnablesTypeDatasource*) initWithSkill:(NSInteger)typeID
{
	if((self = [super init])){
		skillTypeID = typeID;
		
		CCPDatabase *db = [[GlobalData sharedInstance] database];
		
		enabledTypes = [[db dependenciesForSkillByCategory:typeID]retain];
		
		if(enabledTypes != nil){
			NSInteger count = [enabledTypes count];
			dependSkillArray = malloc(sizeof(NSArray*) * count);
			categoryNameArray = malloc(sizeof(NSString*) * count);
			
			[enabledTypes getObjects:dependSkillArray andKeys:categoryNameArray];
		}
	}
	return self;
}

-(void)dealloc
{
	free(dependSkillArray);
	free(categoryNameArray);
	[enabledTypes release];
	[super dealloc];
}

// Datasource methods
- (NSInteger)outlineView:(NSOutlineView *)outlineView 
  numberOfChildrenOfItem:(id)item
{
	if(item == nil){
		return [enabledTypes count];
	}
	
	if([item isKindOfClass:[METDependSkill class]]){
		return 0;
	}
	
	NSInteger index = [item integerValue];
	NSArray *ary = dependSkillArray[index];
	return [ary count];
}

- (id)outlineView:(NSOutlineView *)outlineView 
			child:(NSInteger)index 
		   ofItem:(id)item
{
	if(item == nil){
		return [NSNumber numberWithInteger:index];
	}
	
	NSInteger parentIndex = [item integerValue];
	NSArray *dskill = dependSkillArray[parentIndex];
	return [dskill objectAtIndex:index];
}

-(NSInteger) outlineView:(NSOutlineView*)
  numberOfChildrenOfItem:(id)item
{
	if(item == nil){
		return [enabledTypes count];
	}
	
	return [item count];
	
}

- (id)outlineView:(NSOutlineView *)outlineView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
		   byItem:(id)item
{
	if([item isKindOfClass:[NSNumber class]]){
		return categoryNameArray[[item integerValue]];
	}
	
	if([item isKindOfClass:[METDependSkill class]]){
		if([[tableColumn identifier]isEqualToString:COL_DEP_NAME]){
			return [item itemName];
		}else{
			return [NSNumber numberWithInteger:[item itemSkillPreLevel]];
		}
	}
	
	return @"oops";
}

- (BOOL)outlineView:(NSOutlineView *)outlineView 
   isItemExpandable:(id)item
{
	if([item isKindOfClass:[METDependSkill class]]){
		return NO;
	}
	return YES;
}


@end
