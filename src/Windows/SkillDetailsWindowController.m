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

#import "SkillDetailsWindowController.h"
#import "GlobalData.h"
#import "Character.h"
#import "Skill.h"
#import "Helpers.h"
#import "macros.h"
#import "SkillPair.h"

@implementation SkillDetailsWindowController

//@synthesize character;
//@synthesize skill;

-(void) awakeFromNib
{
	[skillPrerequisites setIndentationMarkerFollowsCell:YES];
}

-(void) setSkill:(Skill*)s forCharacter:(Character*)c
{
	if(skill != nil){
		[skill release];
	}
	skill = [s retain];
	
	if(character != nil){
		[character release];
	}
	character = [c retain];
}

+(void) displayWindowForSkill:(Skill*)s forCharacter:(Character*)c
{
	/*Not a leak*/
	SkillDetailsWindowController *wc = [[SkillDetailsWindowController alloc]init];
	[wc setSkill:s forCharacter:c];
	[[wc window]makeKeyAndOrderFront:nil];
}

+(void) displayWindowForTypeID:(NSNumber*)tID forCharacter:(Character*)c
{
	Skill *s = [[[GlobalData sharedInstance]skillTree] skillForId:tID];
	[SkillDetailsWindowController displayWindowForSkill:s forCharacter:c];
}

-(id) init
{
	if(self = [super initWithWindowNibName:@"SkillDetails"]){
		
	}
	return self;
}

-(void) dealloc
{
	[skillPrerequisites setDataSource:nil];
	[skillPoints setDataSource:nil];
	[skillTrainingTimes setDataSource:nil];
	
	[skill release];
	[character release];
	[super dealloc];
}


-(void) setLabels
{
	[skillName setStringValue:[skill skillName]];
	[skillName sizeToFit];
	
	[skillRank setIntegerValue:[skill skillRank]];
	[skillRank sizeToFit];
	
	[skillGroup setStringValue:[[[[GlobalData sharedInstance]skillTree] groupForId:[skill groupID]]groupName]];
	[skillGroup sizeToFit];
	
	[skillPrimaryAttr setStringValue:strForAttrCode([skill primaryAttr])];
	[skillPrimaryAttr sizeToFit];
	
	[skillSecondaryAttr setStringValue:strForAttrCode([skill secondaryAttr])];
	[skillSecondaryAttr sizeToFit];
	
	[pilotLevel setIntegerValue:[skill skillLevel]];
	[pilotLevel sizeToFit];
	
	[pilotPoints setIntegerValue:[skill skillPoints]];
	[pilotPoints sizeToFit];
	
	[pilotTimeToLevel setStringValue:
	 stringTrainingTime(
			[character trainingTimeInSeconds:[skill typeID] fromLevel:[skill skillLevel] toLevel:[skill skillLevel]+1]
						)];
	[pilotTimeToLevel sizeToFit];
	
	[pilotTrainingRate setStringValue:
			[NSString stringWithFormat:@"%ld SP/hr",
			[character spPerHour:[skill primaryAttr]
				   secondary:[skill secondaryAttr]]]];
	[pilotTrainingRate sizeToFit];
	
	[skillDescription setStringValue:[skill skillDescription]];
	//[skillDescription sizeToFit];
	
	[skillPrerequisites setDelegate:self];
	[skillPoints setDelegate:self];
	[skillTrainingTimes setDelegate:self];
}

-(void) setDatasource
{
	[skillPrerequisites setDataSource:self];
	[skillPoints setDataSource:self];
	[skillTrainingTimes setDataSource:self];
}

-(void) windowDidLoad
{
	if(character == nil){
		return;
	}
	if(skill == nil){
		return;
	}
	
	[self setLabels];
	[self setDatasource];
	
	[[self window]setTitle:[NSString stringWithFormat:@"%@ - %@",[[self window]title],[skill skillName]]];
	
	[skillPrerequisites expandItem:nil expandChildren:YES];
	
	[[NSNotificationCenter defaultCenter] 
		addObserver:self
		selector:@selector(windowWillClose:)
		name:NSWindowWillCloseNotification
		object:[self window]];
	
}

/*table view datasource methods*/
- (BOOL)tableView:(NSTableView *)aTableView 
shouldEditTableColumn:(NSTableColumn *)aTableColumn 
			  row:(NSInteger)rowIndex
{
	return NO;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if(aTableView == skillPoints){
		return 5;
	}else if(aTableView == skillTrainingTimes){
		return 5;
	}
	return 0;
}

- (id)tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSInteger)rowIndex
{
	if(aTableView == skillPoints){
		if([[aTableColumn identifier]isEqualToString:SD_LEVEL]){
			return [NSNumber numberWithInteger:rowIndex + 1];
		}else if([[aTableColumn identifier]isEqualToString:SD_SP_LEVEL]){
			return [NSNumber numberWithInteger:[skill totalSkillPointsForLevel:rowIndex + 1]];
		}else if([[aTableColumn identifier]isEqualToString:SD_SP_DIFF]){
			return [NSNumber numberWithInteger:
					[skill totalSkillPointsForLevel:rowIndex+1] - 
					[skill totalSkillPointsForLevel:rowIndex]];
		}
	}else if(aTableView == skillTrainingTimes){
		if([[aTableColumn identifier]isEqualToString:SD_LEVEL]){
			return [NSNumber numberWithInteger:rowIndex + 1];
		}else if([[aTableColumn identifier]isEqualToString:SD_TIME]){
			return stringTrainingTime([character trainingTimeInSeconds:[skill typeID]
									  fromLevel:rowIndex
										toLevel:rowIndex+1
						accountForTrainingSkill:NO]);
		}else if([[aTableColumn identifier]isEqualToString:SD_TOTAL]){
			NSInteger time = 0;
			
			for(NSInteger i = 0; i <= rowIndex; i++){
				time += [character trainingTimeInSeconds:[skill typeID]
									fromLevel:i
									toLevel:i+1
					accountForTrainingSkill:NO];
			}
			return stringTrainingTime(time);
			
		}else if([[aTableColumn identifier]isEqualToString:SD_FROM_NOW]){
			if([skill skillLevel] > rowIndex){
				return @"Already Trained";
			}
			NSInteger time = 0;
			
			for(NSInteger i = [skill skillLevel]; i < rowIndex+1; i++){
				time += [character trainingTimeInSeconds:[skill typeID]
											   fromLevel:i
												 toLevel:i+1
								 accountForTrainingSkill:NO];
			}
			return stringTrainingTime(time);
			
		}
	}
	return nil;
}
/*outline view*/

- (BOOL)outlineView:(NSOutlineView *)outlineView 
shouldEditTableColumn:(NSTableColumn *)tableColumn 
			   item:(id)item
{
	return NO;
}

/*
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
	return NO;
}
*/
- (NSInteger)outlineView:(NSOutlineView *)outlineView 
  numberOfChildrenOfItem:(id)item
{
	if(item == nil){
		//return [[skill prerequisites]count];
		return 1;
	}
	
	return [[[[[GlobalData sharedInstance]skillTree] skillForId:[item typeID]]prerequisites]count];
}

- (id)outlineView:(NSOutlineView *)outlineView 
			child:(NSInteger)index 
		   ofItem:(id)item
{
	if(item == nil){
		return skill;
	}
	
	return [[[[[GlobalData sharedInstance]skillTree] skillForId:[item typeID]]prerequisites]objectAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
		   byItem:(id)item
{
	SkillPair *pair;
	NSString *textValue;
	
	if([item isKindOfClass:[Skill class]]){
		pair = [[[SkillPair alloc]initWithSkill:[skill typeID] level:[skill skillLevel]]autorelease];
		textValue = [skill skillName];
	}else{
		pair = item;
		textValue = [item roman];
	}
	
	/*if the character has the skill use blue text, otherwise red. green is too hard to read.*/
	Skill *s = [[character st]skillForId:[pair typeID]];
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
	Skill *s = [[[GlobalData sharedInstance]skillTree] skillForId:[item typeID]];
	return [[s prerequisites]count] > 0;
}

-(void) windowWillClose:(NSNotification*)note
{
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	[self autorelease];
}

@end
