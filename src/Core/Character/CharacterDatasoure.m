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
#import "CharacterDatasoure.h"
#import "CharacterPrivate.h"
#import "Config.h"
#import "Helpers.h"

#define VIEW_CHAR_SHEET 3
#define VIEW_CHAR_TRAINING 1
#define VIEW_CHAR_SKILLS 2
#define VIEW_CHAR_ATTRS 4

#define VIEW_CHAR_ATTR_ROWS 5
#define VIEW_CHAR_TRAINING_ROWS 3


@implementation Character (CharacterDatasoure)

#pragma mark Table datasource methods

#pragma mark Delegates

/*prevent editing of the cells*/

- (BOOL)tableView:(NSTableView *)aTableView 
shouldEditTableColumn:(NSTableColumn *)aTableColumn 
			  row:(NSInteger)rowIndex
{
	return NO;
}
- (BOOL)outlineView:(NSOutlineView *)outlineView 
shouldEditTableColumn:(NSTableColumn *)tableColumn 
			   item:(id)item
{
	return NO;
}

#pragma mark SkillTree OutlineView

-(id) outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(id)item
{
	return [skillTree outlineView:outlineView child:index ofItem:item]; 
}
-(NSInteger) outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item
{
	return [skillTree outlineView:outlineView numberOfChildrenOfItem:item];
}

-(BOOL) outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item
{
	return [skillTree outlineView:outlineView isItemExpandable:item];
}
-(id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
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
	[str appendFormat:@"%@\n\n",[item skillName]];
	
	NSInteger trainingTime = [self trainingTimeInSeconds:[item primaryAttr] 
											   secondary:[item secondaryAttr] 
											 skillPoints:skillPointsForLevel([item skillLevel]+1,[item skillRank])];
	[str appendFormat:@"Attributes: %@/%@\n",strForAttrCode([item primaryAttr]),strForAttrCode([item secondaryAttr])];
	
	if([item skillLevel]+1 < 5){
		[str appendFormat:@"Training Time: %@\n",stringTrainingTime(trainingTime)];
	}
	[str appendFormat:@"\n%@",[item skillDescription]];
	
	return str;
}


@end
