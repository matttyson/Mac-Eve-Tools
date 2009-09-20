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

#import <Cocoa/Cocoa.h>
#import "Skill.h"
#import "SkillGroup.h"

#import <libxml/tree.h>
#import <libxml/parser.h>

/*
	This represents the tree of availabe skills in the game.  It could be the entire skill tree for the game
	Or the skills of a particular character.
 
	It needs to be able to find the skill group for a particular skill
 */


@interface SkillTree : NSObject <NSCopying> {
	/*this stores the skill groups as a key-value pair, keyed on groupID*/
	NSMutableDictionary *skillGroups;
	NSArray *skillGroupArray;
	
	/*all the skills in the tree, keyed on typeID*/
	NSMutableDictionary *skills;
	NSDictionary *skillSet; /*immutable object used for skill planning*/
	NSInteger skillPointTotal; /*the total amount of skill points for this group*/
}


-(SkillTree*) initWithXml:(NSString*)xmlPath;
-(SkillTree*) init;

/*returns a skill object for the skill id number*/
-(Skill*) skillForId:(NSNumber*)skillID;
-(Skill*) skillForIdInteger:(NSInteger)skillID;

/*search for a skill by skill name.  This is not efficent*/
-(Skill*) skillForName:(NSString*)skillName;

-(NSInteger) skillPointTotal;
-(NSUInteger) skillCount;
-(NSInteger) skillsAtV;

/*find a skill group given the group id number*/
-(SkillGroup*) groupForId:(NSNumber*)groupID;
-(SkillGroup*) skillGroupAtIndex:(NSUInteger)index;
-(NSUInteger) skillGroupCount;

-(void) addSkillGroup:(SkillGroup*)group;
-(BOOL) addSkill:(Skill*)skill toGroup:(NSNumber*)groupID;

-(NSDictionary*) skillSet; /*all the skills in the tree, keyed on typeid*/

#pragma mark NSOutlineView datasource

-(id) outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(id)item;
-(NSInteger) outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item;
-(BOOL) outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item;
-(id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;

-(NSString*) outlineView:(NSOutlineView *)ov 
		  toolTipForCell:(NSCell *)cell 
					rect:(NSRectPointer)rect 
			 tableColumn:(NSTableColumn *)tc 
					item:(id)item 
		   mouseLocation:(NSPoint)mouseLocation;


#pragma mark NSOutlineView Delegate

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item;

#pragma mark -

@end
