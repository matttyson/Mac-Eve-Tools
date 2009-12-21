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


#import "MTSkillButtonCell.h"


@implementation MTSkillButtonCell

@synthesize notesButtonAction;
@synthesize plusButtonAction;
@synthesize minusButtonAction;

-(NSImage*) plusButtonImage
{
	return [NSImage imageNamed:@"green.tiff"];
}

-(NSImage*) minusButtonImage
{
	return [NSImage imageNamed:@"red.tiff"];
}

-(NSImage*) infoButtonImage
{
	return [NSImage imageNamed:@"yellow.tiff"];
}

////////////////////////


/*
	Each button can be a maximum of 10x10 pixels with a 2 pixel buffer between it and
 the next image.
 */

-(NSRect) plusButtonRect:(NSRect)bounds
{
	NSRect box = bounds;
	
	//box.origin.x = bounds.size.width - 50.0;	
	box.origin.y += (bounds.size.height / 2.0) - (15.0 / 2.0);
	
	box.size.width = 15.0;
	box.size.height = 15.0;
	
	return box;
}

-(NSRect) minusButtonRect:(NSRect)bounds
{
	NSRect box = bounds;
	
	//box.origin.x = (bounds.size.width - 35.0) + 2.0;
	box.origin.x += +17.0;
	box.origin.y += (bounds.size.height / 2.0) - (15.0 / 2.0);

	box.size.width = 15.0;
	box.size.height = 15.0;
	
	return box;
}

-(NSRect) infoButtonRect:(NSRect)bounds
{
	
	NSRect box = bounds;
	
	//box.origin.x = (bounds.size.width - 20.0) + 2.0;
	box.origin.x += 15.0 + 15.0 + 2.0;
	box.origin.y += (bounds.size.height / 2.0) - (15.0 / 2.0);
	
	box.size.width = 15.0;
	box.size.height = 15.0;
	
	return box;
}

-(void) drawButtons:(NSRect)bounds
{
	NSRect drawArea;
	NSImage *drawImage;
	
	drawArea = [self plusButtonRect:bounds];
	drawImage = [self plusButtonImage];
	[drawImage drawInRect:drawArea fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	drawArea = [self minusButtonRect:bounds];
	drawImage = [self minusButtonImage];
	[drawImage drawInRect:drawArea fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];

	drawArea = [self infoButtonRect:bounds];
	drawImage = [self infoButtonImage];
	[drawImage drawInRect:drawArea fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

-(void) drawInteriorWithFrame:(NSRect)bounds inView:(NSView *)controlView
{
	/*
	 draw the text normally, but we need to clip it to make room for the
	 buttons.
	 
	*/
	
	NSRect newRect = bounds;
	
	/*
	 properly calculate the real size and have the superclass draw the text.
	 
	 once that is done we can then draw the buttons after where the text ends.
	 
	 */
	newRect.size.width -= 50.0;
	
	/*draw the text that would normally appear.*/
	[super drawInteriorWithFrame:newRect inView:controlView];
	
	
	NSRect drawRect = bounds;
	
	drawRect.origin.x += newRect.size.width;
	drawRect.size.width = 50.0;
	
	/*drawRect is the rect where we can start drawing the buttons*/
	
	/*a hitbox will need to be calculated for each item.*/
	
	[self drawButtons:bounds];
}

/*
-(BOOL) hitPlusButton:(NSPoint)mousePoint
{
	//NSRect plusRect = [self plusButtonR
}
*/


+ (BOOL)prefersTrackingUntilMouseUp
{
	// NSCell returns NO for this by default. If you want to have trackMouse:inRect:ofView:untilMouseUp:
	// always track until the mouse is up, then you MUST return YES. Otherwise, strange things will happen.
	return YES;
}


/*
 This function can tell is when the mouse enteres a box, i think.
 */


-(BOOL) trackMouse:(NSEvent *)theEvent 
			inRect:(NSRect)cellFrame 
			ofView:(NSView *)controlView 
	  untilMouseUp:(BOOL)flag
{	
	[self setControlView:controlView];
	
	NSRect plusRect = [self plusButtonRect:cellFrame];
	NSRect minusRect = [self minusButtonRect:cellFrame];
	NSRect notesRect = [self infoButtonRect:cellFrame];
	
	while([theEvent type] != NSLeftMouseUp){
		
		
		NSPoint point;
		
		point = [controlView convertPoint:[theEvent locationInWindow] fromView:nil];
		
		mouseDownInPlusButton  = NSMouseInRect(point, plusRect,  [controlView isFlipped]);
		mouseDownInMinusButton = NSMouseInRect(point, minusRect, [controlView isFlipped]);
		mouseDownInNotesButton = NSMouseInRect(point, notesRect, [controlView isFlipped]);
		
		/*get the next event*/
		theEvent = [[controlView window] nextEventMatchingMask:
					(NSLeftMouseUpMask | NSLeftMouseDraggedMask | NSMouseEnteredMask | NSMouseExitedMask)];
	}
	
	if(mouseDownInPlusButton){
		mouseDownInPlusButton = NO;
		if(plusButtonAction){
			[NSApp sendAction:plusButtonAction to:[self target] from:[self controlView]];
		}
	}
	
	if(mouseDownInMinusButton){
		mouseDownInMinusButton = NO;
		if(minusButtonAction){
			[NSApp sendAction:minusButtonAction to:[self target] from:[self controlView]];
		}
	}
	
	if(mouseDownInNotesButton){
		mouseDownInNotesButton = NO;
		if(notesButtonAction){
			[NSApp sendAction:notesButtonAction to:[self target] from:[self controlView]];
		}
	}
	
	return YES;
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
	
    NSPoint point = [controlView convertPoint:[event locationInWindow] fromView:nil];
	
	NSRect hitBox = [self plusButtonRect:cellFrame];
    if (NSMouseInRect(point, hitBox, [controlView isFlipped])) {
        return NSCellHitContentArea | NSCellHitTrackableArea;
    }

	hitBox = [self minusButtonRect:cellFrame];
    if (NSMouseInRect(point, hitBox, [controlView isFlipped])) {
        return NSCellHitContentArea | NSCellHitTrackableArea;
    }

	hitBox = [self infoButtonRect:cellFrame];
    if (NSMouseInRect(point, hitBox, [controlView isFlipped])) {
        return NSCellHitContentArea | NSCellHitTrackableArea;
    }
	
    return NSCellHitNone;
}

/*
// Mouse movement tracking -- we have a custom NSOutlineView subclass that automatically lets us add mouseEntered:/mouseExited: support to any cell!
- (void)addTrackingAreasForView:(NSView *)controlView 
						 inRect:(NSRect)cellFrame 
				   withUserInfo:(NSDictionary *)userInfo 
				  mouseLocation:(NSPoint)mouseLocation
{
    NSRect infoButtonRect = [self infoButtonRect:cellFrame];
	
    NSTrackingAreaOptions options = NSTrackingEnabledDuringMouseDrag | NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways;
	
    BOOL mouseIsInside = NSMouseInRect(mouseLocation, infoButtonRect, [controlView isFlipped]);
    if (mouseIsInside) {
        options |= NSTrackingAssumeInside;
        [controlView setNeedsDisplayInRect:cellFrame];
    }
	
    // We make the view the owner, and it delegates the calls back to the cell after it is properly setup for the corresponding row/column in the outlineview
    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:infoButtonRect options:options owner:controlView userInfo:userInfo];
    [controlView addTrackingArea:area];
    [area release];
}

- (void)mouseEntered:(NSEvent *)event {
    iMouseHoveredInInfoButton = YES;
    [(NSControl *)[self controlView] updateCell:self];
}

- (void)mouseExited:(NSEvent *)event {
    iMouseHoveredInInfoButton = NO;
    [(NSControl *)[self controlView] updateCell:self];
}
*/


/*the init, copy and dealloc functions must all be properly implemented.*/
-(id) init
{
	if((self = [super init])){
		[self setLineBreakMode:NSLineBreakByTruncatingTail];
	}
	return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	id object = [super initWithCoder:aDecoder];
	if(object != nil){
		[object setLineBreakMode:NSLineBreakByTruncatingTail];
	}
	return object;
}

-(id) copyWithZone:(NSZone*)zone
{
	MTSkillButtonCell *cell = [super copyWithZone:zone];
	
	if(cell != nil){
		cell->notesButtonAction = self->notesButtonAction;
		cell->plusButtonAction = self->plusButtonAction;
		cell->minusButtonAction = self->minusButtonAction;
		
		cell->mouseDownInPlusButton = NO;
		cell->mouseDownInMinusButton = NO;
		cell->mouseDownInNotesButton = NO;
		
		cell->mouseInPlusButton = NO;
		cell->mouseInMinusButton = NO;
		cell->mouseInNotesButton = NO;
	}
	
	return cell;
}

-(void) dealloc
{
	[super dealloc];
}

@end
