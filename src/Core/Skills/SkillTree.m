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

#import "SkillTree.h"

#import <libxml/tree.h>
#import <libxml/parser.h>
#import "XMLhelpers.h"
#import "Helpers.h"
#import "macros.h"

/*Methods for building a reference skilltree from the XML listing all skill*/

@implementation SkillTree

-(void)dealloc
{
	[skillGroups release];
	[skills release];
	[skillGroupArray release];
	[skillSet release];
	
	[super dealloc];
}

-(SkillTree*) init
{
	if(self = [super init])
	{
		skillGroups = [[NSMutableDictionary alloc]init];
		skills = [[NSMutableDictionary alloc]init];
	}
	return self;
}


-(SkillTree*) copyWithZone:(NSZone*)zone
{
	SkillTree *st = [[SkillTree allocWithZone:zone]init];
	if(st != nil){
		[st->skillGroups release];
		[st->skills release];
		
		st->skillGroups = [skillGroups mutableCopy];
		st->skills = [skills mutableCopy];
		st->skillGroupArray = nil;
		st->skillPointTotal = 0;
	}
	
	return st;
}

-(SkillTree*) initWithXml:(NSString*)xmlPath
{
	NSLog(@"Skill Tree from XML has been removed. use the DB Export");
	[self doesNotRecognizeSelector:_cmd];
}

-(Skill*) skillForIdInteger:(NSInteger)skillID
{
	return [self skillForId:[NSNumber numberWithInteger:skillID]];
}

-(Skill*) skillForId:(NSNumber*)skillID
{
	return [skills objectForKey:skillID]; 
}

-(BOOL) skillExistsForId:(NSInteger)skillID
{
	Skill *s = [self skillForIdInteger:skillID];
	return s == nil;
}


/*
 This is ineffiecent due to skills being keyed on TypeID and not skill name.
 A dictionary with mulitple keys would be useful.
 */
-(Skill*) skillForName:(NSString*)skillName
{
	Skill *s = nil;
	NSEnumerator *e = [skills objectEnumerator];
	
	while((s = [e nextObject]) != nil){
		if([[s skillName]isEqualToString:skillName]){
			return s;
		}
	}
	return nil;
}

-(NSInteger) skillPointTotal
{
	if(skillPointTotal == 0){
		NSEnumerator *e = [skillGroups objectEnumerator];
		SkillGroup *sg;
		while((sg = [e nextObject]) != nil){
			skillPointTotal += [sg groupSPTotal];
		}
	}
	return skillPointTotal;
}

-(NSInteger) skillsAtV
{
	NSInteger levelV = 0;
	NSEnumerator *e = [skills objectEnumerator];
	Skill *s;
	while((s = [e nextObject]) != nil){
		if([s skillLevel] == 5){
			levelV++;
		}
	}
	return levelV;
}

-(NSUInteger) skillCount
{
	return [skills count];
}

-(SkillGroup*) skillGroupAtIndex:(NSUInteger)index;
{
	if(skillGroupArray == nil){
		/*get the skill array, sort them alphabeticly*/
		skillGroupArray = [[[skillGroups allValues]sortedArrayUsingSelector:@selector(sortByName:)]retain];
	}
	
	return [skillGroupArray objectAtIndex:index];
}

-(SkillGroup*) groupForId:(NSNumber*)groupID
{
	return [skillGroups objectForKey:groupID];
}
-(void) addSkillGroup:(SkillGroup*)group
{
	[skillGroups setObject:group forKey:[group groupID]];
	
	/*invalidate the old cached sorted array*/
	if(skillGroupArray != nil){
		[skillGroupArray release];
		skillGroupArray = nil;
	}
	
	/* add all the skills to the gobal array?*/
}


-(NSUInteger) skillGroupCount
{
	return [skillGroups count];
}

-(BOOL) addSkill:(Skill*)skill toGroup:(NSNumber*)groupID
{
	SkillGroup *sg = [skillGroups objectForKey:groupID];
	if(sg == nil){
		NSLog(@"Skill Group %@ does not exist",groupID);
		return NO;
	}
	
	[sg addSkill:skill];
	[skills setObject:skill forKey:[skill typeID]];
	skillPointTotal = 0;
	
	if(skillSet != nil){
		[skillSet release];
		skillSet = nil;
	}
	return YES;
}


#pragma mark NSOutlineView datasource

-(NSInteger) outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item
{
	if(item == nil){
		return [self skillGroupCount];
	}else if([item isKindOfClass:[SkillGroup class]]){
		return [item skillCount];
	}
	return 0;
}

-(BOOL) outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item
{
	if([item isKindOfClass:[SkillGroup class]]){
		if([item skillCount] > 0){
			return YES;
		}
	}
	return NO;
}


/*
 if item is nil, return the root item.
 */
-(id) outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(id)item
{
	if(item == nil){
		return [self skillGroupAtIndex:index];
	}else if([item isKindOfClass:[SkillGroup class]]){
		return [item getSkillAtIndex:index];
	}
	return nil;
}


- (id)outlineView:(NSOutlineView *)outlineView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
		   byItem:(id)item
{
	//NSLog(@"%@",[tableColumn identifier] );
	
	if([item isKindOfClass:[SkillGroup class]]){
		if([[tableColumn identifier] isEqualToString:COL_SKILL_NAME]){
			return [item groupName];
		}else if([[tableColumn identifier] isEqualToString:COL_SKILL_POINTS]){
			return [NSNumber numberWithInteger:[item groupSPTotal]]; 
		}
	}else if([item isKindOfClass:[Skill class]]){
		if([[tableColumn identifier] isEqualToString:COL_SKILL_NAME]){
			return [item skillName];
		}else if([[tableColumn identifier] isEqualToString:COL_SKILL_CURLEVEL]){
			return [NSNumber numberWithInteger:[item skillLevel]];
		}else if([[tableColumn identifier] isEqualToString:COL_SKILL_RANK]){
			return [NSNumber numberWithInteger:[item skillRank]];
		}else if([[tableColumn identifier] isEqualToString:COL_SKILL_POINTS]){
			return [NSNumber numberWithInteger:[item skillPoints]];
		}
	}
	
	//NSLog(@"id: %@ class %@",[tableColumn identifier],[item class]);
	return nil;
}

- (NSString *)outlineView:(NSOutlineView *)ov 
		   toolTipForCell:(NSCell *)cell 
					 rect:(NSRectPointer)rect 
			  tableColumn:(NSTableColumn *)tc 
					 item:(id)item 
			mouseLocation:(NSPoint)mouseLocation
{
	if(![item isKindOfClass:[Skill class]]){
		return nil;
	}
	NSMutableString *str = [[[NSMutableString alloc]init]autorelease];
	[str appendFormat:@"Skill: %@\n\n",[item skillName]];
	[str appendFormat:@"Description: %@",[item skillDescription]];
	return str;
}

#pragma mark NSOutlineView delegate

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	return NO;
}

-(NSDictionary*) skillSet
{
	if(skillSet == nil){
		skillSet = [[NSDictionary dictionaryWithDictionary:skills]retain];
	}
	return skillSet;
}


@end
