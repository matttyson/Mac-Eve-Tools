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

 #import "SkillSearchView.h"
#import "SkillTree.h"

/*
	Datasource for the View that allows you to select skills to add to the plan
		(from a characters skill set)
 
	Datasource for the skill search view
 */

@interface SkillSearchCharacterDatasource : NSObject <SkillSearchDatasource> {
	NSDictionary *characterSkills;
	SkillTree *st;
	NSString *searchString; //the string we are searching for;
	NSMutableArray *searchSkills; //the list of skills we found
	Character *character;
}

//-(NSMenu*) outlineView:(NSOutlineView*)outlineView menuForTableColumnItem:(NSTableColumn*)column byItem:(id)item

-(SkillSearchCharacterDatasource*) init; 
-(NSString*) skillSearchName;

-(void) setCharacter:(Character*)skills;
//-(void) setCharacterSkills:(NSDictionary*)skills;
-(void) setSkillTree:(SkillTree*)tree;

-(void) skillSearchFilter:(id)sender;

@end
