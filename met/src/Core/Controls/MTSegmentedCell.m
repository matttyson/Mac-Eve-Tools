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

#import "MTSegmentedCell.h"


@implementation MTSegmentedCell

- (void)drawSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView *)controlView
{
//	if(segment == 0){
//		return;
//	}
	if(close_img == nil){
		//close_img == [[NSImage imageNamed:@"close.tiff"]retain]; <-- why the fuck won't this work?
		close_img = [[NSImage alloc]initWithContentsOfFile:
					 [[NSBundle mainBundle] pathForResource:@"close" ofType:@"tiff"]];
		[close_img setFlipped:NO];
		close_size = [close_img size];
		
	}
	
	NSRect close_loc = frame;
	close_loc.size.width = close_size.width;
	close_loc.size.height = close_size.height;
	close_loc.origin.y = 6.5 ;// (frame.size.height / 2) - (close_size.height / 2);
	close_loc.origin.x = 1.0;
	
	[close_img drawInRect:close_loc fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
//	CGFloat offset = close_loc.origin.x + close_size.width + 3;
	frame.origin.x = close_loc.origin.x + close_size.width;
	//[self setWidth:(frame.size.width + close_size.width + 3) forSegment:segment];
	[super drawSegment:segment inFrame:frame withView:controlView];
}

-(BOOL) mouseInClose:(NSInteger)segment theEvent:(NSEvent*)event
{
	return NO;
}

-(void) removeCellWithTag:(NSInteger)tag
{
	NSInteger count = [self segmentCount];
	for(NSInteger i = 0; i < count; i++){
		if([self tagForSegment:i] == tag){
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
	}
	[self setSegmentCount:count-1];
}

@end
