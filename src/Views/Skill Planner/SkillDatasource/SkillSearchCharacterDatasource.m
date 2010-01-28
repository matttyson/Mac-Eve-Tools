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

#import "SkillPair.h"
#import "SkillSearchCharacterDatasource.h"
#import "Helpers.h"
#import "macros.h"
#import "Config.h"
#import "Character.h"
#import "GlobalData.h"

@implementation SkillSearchCharacterDatasource



-(SkillSearchCharacterDatasource*) init
{
	if(self = [super init]){
		//[st = [Config GetInstance]->st retain];
		st = nil;
		searchSkills = [[NSMutableArray alloc]init];
	}
	
	return self;
}

-(void) dealloc
{
	NSLog(@"%@ dealloc",[self className]);
	[st release];
	[characterSkills release];
	[searchSkills release];
	[super dealloc];
}


-(NSString*) skillSearchName
{
	return @"Skills";
}

-(void) setSkillTree:(SkillTree*)tree
{
	if(st != nil){
		[st release];
	}
	st = [tree retain];
}

-(void) setCharacter:(Character*)skills
{
	if(character != nil){
		[character release];
	}
	
	character = [skills retain];
	if(characterSkills != nil){
		[characterSkills release];
	}
	
	characterSkills = [[skills skillSet]retain];
}
/*
-(void) setCharacterSkills:(NSDictionary*)skills
{
	if(characterSkills != nil){
		[characterSkills release];
	}
	
	characterSkills = [skills retain];
}
*/

/*delegate methods for the skill tree plan*/
/*pass them on normally to the global skill tree, but intercept the one that determines current skill level*/
-(id) outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(id)item
{
	if(searchString != nil){
		return [searchSkills objectAtIndex:index];
	}
	return [st outlineView:outlineView child:index ofItem:item];
}

-(NSInteger) outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item
{
	if(searchString != nil && item == nil){
		return [searchSkills count];
	}else{
		return [st outlineView:outlineView numberOfChildrenOfItem:item];
	}
}

-(BOOL) outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item
{
	return [st outlineView:outlineView isItemExpandable:item];
}

-(id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	Skill *s;
	
	/*TODO: there seems to be a crash here.*/
	if([item isKindOfClass:[Skill class]]){
		if((s = [characterSkills objectForKey:[item typeID]]) != nil){
			/*the character has the skill*/
			return [NSString stringWithFormat:@"%@ (%@)",[item skillName],romanForInteger([s skillLevel])];
		}
	}
	
	return [st outlineView:outlineView objectValueForTableColumn:tableColumn byItem:item];
}

#pragma mark drag and drop support

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
{	
	id obj = [items objectAtIndex:0];
	
	if(![obj isKindOfClass:[Skill class]]){
		return NO;
	}
	
	NSInteger skillLevel = 0;
	
	Skill *s = [characterSkills objectForKey:[obj typeID]];
	if(s != nil){
		skillLevel = [s skillLevel];
	}
	if(skillLevel > 4){
		return NO;
	}
	
	[pboard declareTypes:[NSArray arrayWithObject:MTSkillArrayPBoardType] owner:self];
	
	NSMutableData *data = [[NSMutableData alloc]initWithCapacity:0];
	
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
	[archiver setOutputFormat:NSPropertyListBinaryFormat_v1_0];
	
	SkillPair *pair = [[[SkillPair alloc]initWithSkill:[obj typeID] level:skillLevel+1]autorelease];
	NSArray *array = [NSArray arrayWithObject:pair];
	
	[archiver encodeObject:array];
	
	[archiver finishEncoding];
	
	[pboard setData:data forType:MTSkillArrayPBoardType];
	
	[archiver release];
	[data release];
	
	return YES;
}

-(NSMenu*) outlineView:(NSOutlineView*)outlineView 
menuForTableColumnItem:(NSTableColumn*)column 
				byItem:(id)item
{
	if(![item isKindOfClass:[Skill class]]){
		return nil;
	}
	
	NSInteger startingLevel = 0;
	
	Skill *s = [characterSkills objectForKey:[item typeID]];
	
	if(s != nil){
		//if the character has the skill, make the starting level the next one to train.
		startingLevel = [s skillLevel];
	}else{
		s = [[[GlobalData sharedInstance]skillTree]skillForId:[item typeID]];
	}
	NSMenu *menu = [[[NSMenu alloc]initWithTitle:@"Menu"]autorelease];
	NSMenuItem *menuItem;
	
	menuItem = [[NSMenuItem alloc]initWithTitle:[s skillName] action:@selector(displaySkillWindow:) keyEquivalent:@""];
	[menuItem setRepresentedObject:item];
	[menu addItem:menuItem];
	[menuItem release];
	
	if(startingLevel > 4){
		return menu;
	}
	
	[menu addItem:[NSMenuItem separatorItem]];
	
	for(NSInteger i = startingLevel+1; i <= 5; i++){
		SkillPair *sp = [[SkillPair alloc]initWithSkill:[item typeID] level:i];
		NSString *title = [NSString stringWithFormat:@"Train to level %ld",i];
		menuItem = [[NSMenuItem alloc]initWithTitle:title action:@selector(menuAddSkillClick:) keyEquivalent:@""];
		[menuItem setRepresentedObject:sp];
		[sp release];
		[menu addItem:menuItem];
		[menuItem release];
	}
	
	return menu;
}

/*display a tooltip*/
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
	
	[str appendString:[item skillName]];
	[str appendFormat:@"\n\nAttributes: %@/%@\n",
		strForAttrCode([item primaryAttr]),strForAttrCode([item secondaryAttr])];
	
	NSInteger skillLevel = [[[character skillTree]skillForId:[item typeID]]skillLevel];
	[str appendFormat:@"Training Time: %@\n\n",stringTrainingTime([character trainingTimeInSeconds:[item typeID]
																	fromLevel:skillLevel toLevel:skillLevel+1])];
	[str appendString:[item skillDescription]];
	return str;
}


/*we've been given a search string.  display only skills which match the filter*/
-(void) skillSearchFilter:(id)sender
{
	NSString *searchValue = [[sender cell]stringValue];
	
	if([searchValue length] == 0){
		[searchString release];
		searchString = nil;
		[searchSkills removeAllObjects];
		return;
	}
	
	[searchSkills removeAllObjects];
	[searchString release];
	searchString = [searchValue retain];
	
	//find the skills that match the string value, add them to the list of skill.
	NSDictionary *skills = [st skillSet];
	NSEnumerator *e = [skills objectEnumerator];
	Skill *s;
	while((s = [e nextObject]) != nil){
		NSRange r = [[s skillName]rangeOfString:searchValue options:NSCaseInsensitiveSearch];
		if(r.location != NSNotFound){
			[searchSkills addObject:s];
		}
	}
}

@end
