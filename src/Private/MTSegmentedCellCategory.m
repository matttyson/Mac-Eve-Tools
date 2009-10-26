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

#import "MTSegmentedCellCategory.h"


@implementation NSSegmentedCell (MTSegmentedCellCategory) 

-(void) removeCellWithTag:(NSInteger)tag
{
	NSInteger count = [self segmentCount];
	for(NSInteger i = 0; i < count; i++){
		NSInteger segTag = [self tagForSegment:i];
		if(segTag == tag){
			[self removeCellAtIndex:i];
			break;
		}
	}
}

-(void) removeCellAtIndex:(NSInteger)index
{
	NSInteger count = [self segmentCount];
	
	for(NSInteger i = index; i < count; i++){
		if(i + 1 == count){
			break;
		}
		[self setTag:[self tagForSegment:i+1] forSegment:i];
		[self setLabel:[self labelForSegment:i+1] forSegment:i];
		[self setMenu:[self menuForSegment:i+1] forSegment:i];
	}
	[self setSegmentCount:count-1];
}

@end

@implementation NSSegmentedControl (MTSegmentedControlCategory)

-(void) rightMouseDown:(NSEvent *)theEvent
{
	/*
	if(!([theEvent type] == NSRightMouseDown)){
		//If not a right mouse down event, let the class handle this normally.
		[super mouseDown:theEvent];	
		return;
	}
	NSPoint window_loc = [theEvent locationInWindow];
	
	//NSPoint local = [self convertPoint:window_loc fromView:nil];
	
	NSEvent *event = [NSEvent mouseEventWithType:NSLeftMouseDown
										location:window_loc
								   modifierFlags:0 
									   timestamp:[NSDate timeIntervalSinceReferenceDate]
									windowNumber:[[self window]windowNumber] 
										 context:[[self window]graphicsContext]
									 eventNumber:0
									  clickCount:1
										pressure:0.0f];
	*/
	//we don't need any of the above shit, we can just take the right mouse event
	//and reroute it to the left mouse event.
	[self mouseDown:theEvent];
	
	//[NSMenu popUpContextMenu:<#(NSMenu *)menu#> withEvent:<#(NSEvent *)event#> forView:<#(NSView *)view#>
}

@end

