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

#import "MTSkillProgressCell.h"


@implementation MTSkillProgressCell

- (void)setObjectValue:(id < NSCopying >)object
{
	if(object == nil){
		level = -1;
		progress = -1;
		return;
	}
	level = [[(NSArray*)object objectAtIndex:0]integerValue];
	progress = [[(NSArray*)object objectAtIndex:1]integerValue];

	/*
	if(level == 5){
		progress = 100;
	}
	*/
}

-(void) drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	if(level == -1){
		return;
	}
	NSGraphicsContext *context = [NSGraphicsContext currentContext];
	
	[context saveGraphicsState];
	
	[[NSBezierPath bezierPathWithRect:cellFrame]addClip];
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform translateXBy:cellFrame.origin.x  yBy:cellFrame.origin.y];
	[transform concat];
	
	///[[NSColor darkGrayColor]set];
	
	[[NSColor colorWithDeviceWhite:0.15 alpha:1.0]set];
	
	NSSize size = cellFrame.size;
	
	/*
	 NSRect NSMakeRect (
	 CGFloat x,
	 CGFloat y,
	 CGFloat w,
	 CGFloat h
	 );
	 */
	
	//draw the skill level bar
	NSRect skillLevelRect = NSMakeRect(0.5,0.5 ,size.width - 1 ,size.height / 2 - 1.5);
	[[NSBezierPath bezierPathWithRect:skillLevelRect]stroke];
	//draw the percentage complete bar.
	[[NSBezierPath bezierPathWithRect:NSMakeRect(0.5,size.height/2 ,size.width - 1 ,size.height / 2 - 1.5)]stroke];

	
	// draw a skill block. there needs to be 5 inside a rect. one pixel boundary between each
	/*
		6 pixel boundaries. width of each block is ((width - 4) - 6)
	 */
	
	CGFloat width = (size.width - 4 - 6) / 5;
	NSRect block;
	
	if(level < 1){
		[[NSColor grayColor]set];
	}
	block = NSMakeRect(2, 2, width, 4);
	[[NSBezierPath bezierPathWithRect:block]fill];
	
	if(level < 2){
		[[NSColor grayColor]set];
	}
	block = NSMakeRect(2 + width + 1, 2, width, 4);
	[[NSBezierPath bezierPathWithRect:block]fill];

	if(level < 3){
		[[NSColor grayColor]set];
	}
	block = NSMakeRect(2 + (width*2) + 2 , 2, width, 4);
	[[NSBezierPath bezierPathWithRect:block]fill];

	if(level < 4){
		[[NSColor grayColor]set];
	}
	block = NSMakeRect(2 + (width*3) + 3, 2, width, 4);
	[[NSBezierPath bezierPathWithRect:block]fill];

	if(level < 5){
		[[NSColor grayColor]set];
	}
	block = NSMakeRect(2 + (width*4) + 4, 2, width+2, 4);
	[[NSBezierPath bezierPathWithRect:block]fill];

	[[NSColor colorWithDeviceWhite:0.15 alpha:1.0]set];
	
	CGFloat len = ((CGFloat)progress / 100.0) * (size.width - 4);
	[[NSBezierPath bezierPathWithRect:NSMakeRect(2,size.height/2 + 1.5 ,/*size.width - 4*/len, size.height / 2 - 4.5)]fill];
	
	[context restoreGraphicsState];
}

@end
