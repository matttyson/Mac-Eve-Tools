//
//  SkillPrerequisiteDatasource.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 12/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SkillPrerequisiteDatasource.h"


#import "Skill.h"
#import "SkillPair.h"
#import "SkillTree.h"
#import "macros.h"
#import "GlobalData.h"

@implementation SkillPrerequisiteDatasource


-(id) initWithSkill:(NSArray*)s forCharacter:(Character*)ch;
{
	if((self = [super init])){
		skills = [s retain];
		character = [ch retain];
		
		tree = [[GlobalData sharedInstance]skillTree];
	}
	return self;
}

-(void) dealloc
{
	[skills release];
	[character release];
	[super dealloc];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView 
  numberOfChildrenOfItem:(id)item
{
	if(item == nil){
		return [skills count];
	}
	
	return [[[tree skillForId:[item typeID]]prerequisites]count];
}

- (id)outlineView:(NSOutlineView *)outlineView 
			child:(NSInteger)index 
		   ofItem:(id)item
{
	if(item == nil){
		return [skills objectAtIndex:index];
	}
	
	return [[[tree skillForId:[item typeID]]prerequisites]objectAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
		   byItem:(id)item
{
	SkillPair *pair;
	NSString *textValue;
	
	if([item isKindOfClass:[Skill class]]){
		pair = [[[SkillPair alloc]initWithSkill:[item typeID] level:[item skillLevel]]autorelease];
		textValue = [item skillName];
	}else{
		pair = item;
		textValue = [item roman];
	}
	
	/*if the character has the skill use blue text, otherwise red. green is too hard to read.*/
	Skill *s = [[character skillTree]skillForId:[pair typeID]];
	NSMutableAttributedString *str = [[[NSMutableAttributedString alloc]initWithString:textValue]autorelease];
	
	NSColor *color;
	if(s == nil){
		color = [NSColor redColor];
	}else if([s skillLevel] < [pair skillLevel]){
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
	Skill *s = [tree skillForId:[item typeID]];
	return [[s prerequisites]count] > 0;
}



@end
