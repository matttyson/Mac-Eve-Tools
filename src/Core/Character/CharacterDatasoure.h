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


/*
	Character datasouce for the skill tree view. currently just wraps the skilltree object
 */

#import <Cocoa/Cocoa.h>

#import "Character.h"

@interface Character (CharacterDatasoure)

/*NSTableView delegate methods*/
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
/*outlineview delegates*/
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item;


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

@end
