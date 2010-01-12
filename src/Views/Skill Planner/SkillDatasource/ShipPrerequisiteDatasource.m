//
//  ShipPrerequisiteDatasource.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 9/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ShipPrerequisiteDatasource.h"

#import "CCPType.h"
#import "Character.h"
#import "Config.h"
#import "GlobalData.h"
#import "SkillPair.h"
#import "Skill.h"

@implementation ShipPrerequisiteDatasource


-(void)dealloc
{
	[ship release];
	[character release];
	[super dealloc];
}

-(ShipPrerequisiteDatasource*) initWithShip:(CCPType*)type forCharacter:(Character*)ch;
{
	if(self = [super init]){
		ship = [type retain];
		character = [ch retain];
	}
	return self;
}


-(NSInteger)outlineView:(NSOutlineView *)outlineView 
	numberOfChildrenOfItem:(id)item
{
	if(item == nil){
		return [[ship prereqs]count];
	}
	
	return [[[[[GlobalData sharedInstance]skillTree] skillForId:[(SkillPair*)item typeID]]prerequisites]count];
	
	/*item should be a skill.  return all the dependicies of this skill*/	
}

- (id)outlineView:(NSOutlineView *)outlineView 
			   child:(NSInteger)index 
			  ofItem:(id)item
{
	if(item == nil){
		return [[ship prereqs]objectAtIndex:index];
	}
	
	return [[[[[GlobalData sharedInstance]skillTree] skillForId:[(SkillPair*)item typeID]]prerequisites]objectAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
			  byItem:(id)item
{
	NSString *textValue = [item roman];
	
	Skill *s = [[character st]skillForId:[(SkillPair*)item typeID]];
	NSMutableAttributedString *str = [[[NSMutableAttributedString alloc]initWithString:textValue]autorelease];
	
	NSColor *color;
	if(s == nil){
		color = [NSColor redColor];
	}else if([s skillLevel] < [item skillLevel]){
		color = [NSColor orangeColor];
	}else{
		color = [NSColor blueColor];
	}
	[str addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0,[str length])];
	return str;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView 
   isItemExpandable:(id)item
{
	Skill *s = [[[GlobalData sharedInstance]skillTree] skillForId:[(SkillPair*)item typeID]];
	return [[s prerequisites]count] > 0;
}




@end
