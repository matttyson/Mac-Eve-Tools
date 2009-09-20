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

#import "MTTableViewCategory.h"


@implementation  NSTableView (MTTableView)

/*delegate -(NSMenu*) tableView:(NSTableView*) menuForTableColumn:(NSTableColumn*) row:(NSInteger)row */

-(NSMenu*) menuForEvent:(NSEvent*)event
{
	NSMenu *menu = nil;
	//NSLog(@"%@",event);
	if(([event type] == NSRightMouseDown) || 
	   (([event type] == NSLeftMouseDown) && ([event modifierFlags] & NSControlKeyMask)) ){
		id data = [self dataSource];
		if([data respondsToSelector:@selector(tableView:menuForTableColumn:row:)]){
			NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
			NSInteger row = [self rowAtPoint:point];
			NSInteger col = [self columnAtPoint:point];
			
			if((row != -1) && (col != -1)){
				NSTableColumn *tableColumn = [[self tableColumns] objectAtIndex:col];
				
				//Maybe redo this to use NSInvocation to get rid of the stupid warning.
				menu = [data tableView:self menuForTableColumn:tableColumn row:row];
			}
		}
	}
	return menu;
}

-(void) sizeToFitColumns
{
	NSInteger rows = [[self dataSource]numberOfRowsInTableView:self];
	
	if(rows == 0){
		return;
	}
	
	for(NSTableColumn *c in [self tableColumns]){
		CGFloat width = [[c headerCell]cellSize].width;
		for(NSInteger i = 0; i < rows; i++){
			NSCell *cell = [c dataCellForRow:i];
			NSSize cellSize = [cell cellSize];
			if(cellSize.width > width){
				width = cellSize.width;
			}
		}
		[c setMinWidth:width];
		[c setWidth:width];
	}
	[self display];
}



@end


@implementation NSOutlineView (MTOutlineView)

//delegate -(NSMenu*) outlineView:(NSOutlineView*) menuForTableColumnItem:(NSTableColumn*) byItem:(id)item

-(NSMenu*) menuForEvent:(NSEvent*)event
{
	NSMenu *menu = nil;
	if(([event type] == NSRightMouseDown) || 
		(([event type] == NSLeftMouseDown) && ([event modifierFlags] & NSControlKeyMask)) ){
		id data = [self dataSource];
		if( [data respondsToSelector:@selector(outlineView:menuForTableColumnItem:byItem:)] ){
			NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
			NSInteger row = [self rowAtPoint:point];
			NSInteger col = [self columnAtPoint:point];
			
			if((row != -1) && (col != -1)){
				//NSLog(@"%@ row %ld",[self itemAtRow:row],row);
				
				NSTableColumn *tableColumn = [[self tableColumns] objectAtIndex:col];
				
				menu = [data outlineView:self menuForTableColumnItem:tableColumn byItem:[self itemAtRow:row]];
			}
		}
	}
	return menu;
}

@end


