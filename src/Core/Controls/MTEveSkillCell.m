/*
 
 File: ImagePreviewCell.h
 
 Abstract: ImagePreviewCell class declaration.
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. 
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated. 
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2006-2007 Apple Inc. All Rights Reserved. 
 */ 

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
	Icons of note: 38_193.  tick, cross, circle
	38_208: info button
 */

//
//  MTEveSkillCell.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 18/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MTEveSkillCell.h"

#import "Skill.h"
#import "SkillGroup.h"

#import "Helpers.h"

#import "macros.h"

@implementation MTEveSkillCell

@synthesize mode;
@synthesize skillInfoButtonAction;
@synthesize group;
@synthesize timeLeft;
@synthesize currentSP;


-(void)dealloc
{
	[skillBook release];
	[skillBookV release];
	[infoIcon release];
	[truncateStyle release];
	[formatter release];
	
	[skill release];
	[group release];
	
	[super dealloc];
}

-(void) setupStaticData
{
	skillBook = [[NSImage imageNamed:@"skill.png"]retain];
	skillBookV = [[NSImage imageNamed:@"skillv.png"]retain];
	infoIcon = [[NSImage imageNamed:@"info.png"]retain];
	
	truncateStyle = [[NSMutableParagraphStyle defaultParagraphStyle]mutableCopy];
	[truncateStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	
	formatter = [[NSNumberFormatter alloc]init];
	[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	if((self = [super initWithCoder:aDecoder])){
		[self setupStaticData];
	}
	return self;
}

-(id) init
{
	if((self = [super init])){
		[self setupStaticData];
	}
	return self;
}

-(id) copyWithZone:(NSZone *)zone
{
	MTEveSkillCell *cell = [super copyWithZone:zone];
	if(cell != nil){
		cell->skillBook = [skillBook retain];
		cell->skillBookV = [skillBookV retain];
		cell->infoIcon = [infoIcon retain];
		cell->truncateStyle = [truncateStyle retain];
		cell->formatter = [formatter retain];
		
		cell->skill = nil;
		cell->group = nil;
		
		//leave the other values as junk data, they will be overwritten later
	}
	return cell;
}

-(CGFloat) percentCompleted
{
	return percentCompleted;
}
-(void) setPercentCompleted:(CGFloat)perC
{
	percentCompleted = MIN(perC,1.0);
}

-(Skill*) skill
{
	return skill;
}

-(void) setSkill:(Skill*)s
{
	if(skill != nil){
		[skill release];
	}
	skill = [s retain];
	
	skillLevel = [skill skillLevel];
}

#define PADDING_BEFORE_IMAGE 5.0
#define PADDING_BETWEEN_TITLE_AND_IMAGE 4.0
#define VERTICAL_PADDING_FOR_IMAGE 3.0
#define INFO_IMAGE_SIZE 13.0
#define PADDING_AROUND_INFO_IMAGE 2.0
#define IMAGE_SIZE 32.0

#define BOOK_RIGHT_PADDING 5.5

#define INFO_RIGHT_PADDING 8.0

#define BOX_RIGHT_PADDING ( INFO_RIGHT_PADDING + 5.5 )
#define BOX_TOP_PADDING 8.5

#define BOX_WIDTH 47.0
#define BOX_HEIGHT 9.0

#define BLOCK_WIDTH 8.0
#define BLOCK_HEIGHT 6.0

#define PROGRESS_HEIGHT 5.0
#define PROGRESS_WIDTH BOX_WIDTH

#define BOX_PROGRESS_PADDING 2.0

#define PROGRESS_ZONE_WIDTH 47.0
#define PROGRESS_ZONE_HEIGHT (BOX_HEIGHT + PROGRESS_HEIGHT + BOX_PROGRESS_PADDING)




#define PROGRESS_BAR_HEIGHT 2.0

#define TEXT_RIGHT_PADDING 5.0



/*stolen from ImagePreviewCell from the PhotoSearch example*/
- (NSRect)imageRectForBounds:(NSRect)bounds {
    NSRect result = bounds;
    result.origin.y += VERTICAL_PADDING_FOR_IMAGE;
    result.origin.x += PADDING_BEFORE_IMAGE;
    if (skillBook != nil) { 
        // Take the actual image and center it in the result
        result.size = [skillBook size];
        CGFloat widthCenter = IMAGE_SIZE - NSWidth(result);
        if (widthCenter > 0) {
            result.origin.x += xround(widthCenter / 2.0);
        }
        CGFloat heightCenter = IMAGE_SIZE - NSHeight(result);
        if (heightCenter > 0) {
            result.origin.y += xround(heightCenter / 2.0);
        }
    } else {
        result.size.width = result.size.height = IMAGE_SIZE;
    }
    return result;
}


// Level 4 etc (text string) bounding box
-(NSRect) skillTimeLeftRect:(const NSRect* restrict)bounds 
			   skillBoxRect:(const NSRect* restrict)skillBoxRect
				  topString:(NSAttributedString* restrict)topStr
{
	NSSize size = [topStr size];
	NSRect result = NSMakeRect(skillBoxRect->origin.x - TEXT_RIGHT_PADDING - size.width,
							   skillBoxRect->origin.y - 2.0,
							   size.width, bounds->size.height);
	return result;
}


//2d 20h 38m 15s etc (text string) bounding box
-(NSRect) skillTimeLeftRect:(const NSRect* restrict)bounds 
			   skillBoxRect:(const NSRect* restrict)skillBoxRect
			   bottomString:(NSAttributedString* restrict)topStr
{
	NSSize size = [topStr size];
	NSRect result = NSMakeRect(skillBoxRect->origin.x - TEXT_RIGHT_PADDING - size.width,
							   skillBoxRect->origin.y + BOX_HEIGHT + 4.0,
							   size.width, bounds->size.height);
	return result;
}

-(void) setColourForLevel:(NSInteger)level
{
	[[NSColor blackColor]set];
}

/*bounds of the progress zone*/
-(void) drawSkillProgressLevels:(NSRect)bounds
{
	NSRect skillBlock;
	/*maybe i should have done this in reverse and used a switch statment?*/
		
	if(skillLevel > 0){
		skillBlock = NSMakeRect(bounds.origin.x + 1.5,
								bounds.origin.y + 1.5,
								BLOCK_WIDTH,BLOCK_HEIGHT);
		[self setColourForLevel:1];
		[NSBezierPath fillRect:skillBlock];
	}
	if(skillLevel > 1){
		skillBlock = NSMakeRect(skillBlock.origin.x + 1.0 + BLOCK_WIDTH,
								skillBlock.origin.y,
								BLOCK_WIDTH,BLOCK_HEIGHT);
		[self setColourForLevel:2];
		[NSBezierPath fillRect:skillBlock];
	}
	if(skillLevel > 2){
		skillBlock = NSMakeRect(skillBlock.origin.x + 1.0 + BLOCK_WIDTH,
								skillBlock.origin.y,
								BLOCK_WIDTH,BLOCK_HEIGHT);
		[self setColourForLevel:3];
		[NSBezierPath fillRect:skillBlock];
	}
	if(skillLevel > 3){
		skillBlock = NSMakeRect(skillBlock.origin.x + 1.0 + BLOCK_WIDTH,
								skillBlock.origin.y,
								BLOCK_WIDTH,BLOCK_HEIGHT);
		[self setColourForLevel:4];
		[NSBezierPath fillRect:skillBlock];
	}
	
	if(skillLevel > 4){
		skillBlock = NSMakeRect(skillBlock.origin.x + 1.0 + BLOCK_WIDTH,
								skillBlock.origin.y,
								BLOCK_WIDTH,BLOCK_HEIGHT);
		[self setColourForLevel:5];
		[NSBezierPath fillRect:skillBlock];
	}
}

-(void) drawSkillCompletionProgress:(NSRect)bounds
{
	bounds.size.width = (bounds.size.width - 3.0) * percentCompleted;
	[NSBezierPath fillRect:bounds];
}


/*
	Give the location of the rect for drawing the skill
	box rectangle
 */
-(NSRect) skillBoxRect:(const NSRect* restrict)bounds 
			  infoRect:(const NSRect* restrict)infoRect
			   yOffset:(CGFloat)yOffset
{
	NSRect result;
	
	result.origin.x = infoRect->origin.x - PROGRESS_ZONE_WIDTH - BOX_RIGHT_PADDING;
	
	result.size.width = BOX_WIDTH;
	result.size.height = BOX_HEIGHT;
	
	result.origin.y = bounds->origin.y + (bounds->size.height / 2.0) - (PROGRESS_ZONE_HEIGHT / 2.0) - yOffset;
	
	return result;
}

/*draw the rectangle that surrounds the skill progress bar*/
-(NSRect) skillProgressRect:(const NSRect* restrict)bounds
				   infoRect:(const NSRect* restrict)infoRect
					yOffset:(CGFloat)yOffset
{
	NSRect result;
	
	result.origin.x = infoRect->origin.x - PROGRESS_ZONE_WIDTH - BOX_RIGHT_PADDING;
	
	result.size.width = PROGRESS_WIDTH;
	result.size.height = PROGRESS_HEIGHT;
	
	result.origin.y = (bounds->origin.y + (bounds->size.height / 2.0) - 0.5) + yOffset;
	
	return result;
}


-(void) drawSkillProgressBoxes:(NSRect)bounds
{
	/*
	 measurements in width x height
	 individual boxes should be 8 x 6
	 one pixel blank around each block.
	 one pixel border around the lot
	 total size is 48 * 10
	 
	 progress bar is 2 pixels. one pixel gap, one pixel border
	 48 x 6
	 
	 text should be 10 pixels to the left of the box
	*/
	
	/*
	NSRect progressBorder = bounds;
	progressBorder.origin.y += 5.0 + BOX_HEIGHT;
	progressBorder.size.height = PROGRESS_HEIGHT;
	[NSBezierPath strokeRect:progressBorder];
	*/
	
	[[NSColor blackColor]set];
	[NSBezierPath strokeRect:bounds];
	[self drawSkillProgressLevels:bounds];
	
}

-(void) drawSkillProgressBar:(NSRect)bounds
{
	/*
	 draw the inner portion of the progress bar.  
	 we cut off a pixel either side to make the border effect
	 */
	[[NSColor blackColor]set];
	[NSBezierPath strokeRect:bounds];
	
	bounds.origin.y += 1.5;
	bounds.origin.x += 1.5;
	bounds.size.height -= 3.0;
	
	[self drawSkillCompletionProgress:bounds];
}

- (NSRect) infoButtonRect:(NSRect)bounds;
{
    NSRect result = bounds;
    result.origin.y += VERTICAL_PADDING_FOR_IMAGE;
    result.origin.x = result.size.width - INFO_RIGHT_PADDING - [infoIcon size].width;
    if (infoIcon != nil) { 
        // Take the actual image and center it in the result
        result.size = [infoIcon size];
        CGFloat widthCenter = IMAGE_SIZE - NSWidth(result);
        if (widthCenter > 0) {
            result.origin.x += xround(widthCenter / 2.0);
        }
        CGFloat heightCenter = IMAGE_SIZE - NSHeight(result);
        if (heightCenter > 0) {
            result.origin.y += xround(heightCenter / 2.0);
        }
    } else {
        result.size.width = result.size.height = IMAGE_SIZE;
    }
	return result;
}

- (NSRect)upperRectForBounds:(const NSRect* restrict)bounds 
				   andString:(NSAttributedString* restrict)title 
{
    NSRect result = *bounds;
    // The x origin is easy
    result.origin.x += PADDING_BEFORE_IMAGE + IMAGE_SIZE + PADDING_BETWEEN_TITLE_AND_IMAGE;
    // The y origin should be inline with the image
    result.origin.y += VERTICAL_PADDING_FOR_IMAGE;
    // Set the width and the height based on the texts real size. Notice the nil check! Otherwise, the resulting NSSize could be undefined if we messaged a nil object.
    if (title != nil) {
        result.size = [title size];
    } else {
        result.size = NSZeroSize;
    }
    // Now, we have to constrain us to the bounds. The max x we can go to has to be the same as the bounds, but minus the info image location
    CGFloat maxX = NSMaxX(*bounds) - (PADDING_AROUND_INFO_IMAGE + INFO_IMAGE_SIZE + PADDING_AROUND_INFO_IMAGE);
    CGFloat maxWidth = maxX - NSMinX(result);
    if (maxWidth < 0) maxWidth = 0;
    // Constrain us to these bounds
    result.size.width = MIN(NSWidth(result), maxWidth);
    return result;
}


-(NSMutableAttributedString*) buildSubtitleString
{
	NSString *str;
	NSMutableAttributedString *astr;
	
	//Skill points and points to next level
	if(skillLevel == 5){
		str = [NSString stringWithFormat:@"SP: %@",
			   [formatter stringFromNumber:[NSNumber numberWithInteger:[skill skillPoints]]]
			   ];
	}else{
		str = [NSString stringWithFormat:@"SP: %@/%@",
			   [formatter stringFromNumber:[NSNumber numberWithInteger:currentSP]],
			   [formatter stringFromNumber:[NSNumber numberWithInteger:[skill totalSkillPointsForLevel:skillLevel+1]]]
			   ];
	}
	astr = [[[NSMutableAttributedString alloc]initWithString:str]autorelease];
	NSRange strrange = {0,[str length]};
	[astr addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:12.0] range:strrange ];
	return astr;
}

-(void) drawSubtitleInRect:(NSRect)bounds 
				 theString:(NSAttributedString*)astr
{
	[astr drawInRect:bounds];
}

- (NSRect)rectForSubTitleBasedOnTitleRect:(NSRect)titleRect 
								 inBounds:(NSRect)bounds 
								forString:(NSAttributedString*)subTitle {
   // NSAttributedString *subTitle = [self attributedSubTitle];
	if (subTitle != nil) {
		titleRect.origin.y += titleRect.size.height;
		titleRect.size.width = [subTitle size].width;
		// Make sure it doesn't go past the bounds
		CGFloat amountPast = NSMaxX(titleRect) - NSMaxX(bounds);
		if (amountPast > 0) {
			titleRect.size.width -= amountPast;
		}
		return titleRect;
	} else {
		return NSZeroRect;
	}
}

-(void) drawGroupInterior:(NSRect)bounds inView:(NSView*)controlView
{
	NSString *str = 
	[NSString stringWithFormat:@"  %@  -  skills: %lu,  points: %@",
		[group groupName],[group skillCount],
		[formatter stringFromNumber:[NSNumber numberWithInteger:[group groupSPTotal]]]];
	
	NSMutableAttributedString *astr = [[[NSMutableAttributedString alloc]initWithString:str]autorelease];
	NSRect strRect = [self titleRectForBounds:bounds];
	[astr drawInRect:strRect];
}

-(void) drawInfoIcon:(NSRect)bounds
{
	[infoIcon drawInRect:bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

/*
	Draws the "Level x" string next to the progress boxes
	returns the location at which it starts drawing.
 */
-(CGFloat) drawTrainingToLevel:(CGFloat)xFinishPoint 
					yBaseline:(CGFloat)yBaseline
{
	NSString *str;
	NSMutableAttributedString *astr;
		
	/*draw the training to level;*/
	str = [NSString stringWithFormat:@"Level %ld",skillLevel];
	astr = [[[NSMutableAttributedString alloc]initWithString:str]autorelease];
	
	NSRange strrange = NSMakeRange(0,[str length]);
	[astr addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:10.0] range:strrange];
	
	NSSize strSize = [astr size];
	
	NSRect bounds = NSMakeRect(xFinishPoint - strSize.width, yBaseline, strSize.width, strSize.height);
	[astr drawInRect:bounds];
	
	return bounds.origin.x;
}

-(CGFloat) drawTimeLeftString:(CGFloat)xFinishPoint
					yBaseline:(CGFloat)yBaseline
{
	NSRect bounds = NSZeroRect;
	NSMutableAttributedString *timeStr = nil;
	if(timeLeft > 0){
		timeStr = [[[NSMutableAttributedString alloc]initWithString:
					stringTrainingTime2(timeLeft,TTF_All)]
					autorelease];
		NSRange strrange = NSMakeRange(0,[timeStr length]);
		[timeStr addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:10.0] range:strrange];
	}
	
	if(timeStr != nil){
		NSSize strSize = [timeStr size];
		bounds = NSMakeRect(xFinishPoint - strSize.width, yBaseline, strSize.width, strSize.height);
		[timeStr drawInRect:bounds];
		return bounds.origin.x;
	}
	
	return xFinishPoint;
}


-(void) drawSkillInterior:(NSRect)bounds inView:(NSView*)controlView
{
	NSString *str = nil;
	NSMutableAttributedString *astr = nil;
	NSImage *book = [skill skillLevel] == 5 ? skillBookV : skillBook;
	NSRange strrange;
	
	[book setFlipped:[controlView isFlipped]];
	[infoIcon setFlipped:[controlView isFlipped]];
	
	NSRect imageRect = [self imageRectForBounds:bounds];
	[book drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	//draw info icon	
	NSRect infoRect = [self infoButtonRect:bounds];
	[self drawInfoIcon:infoRect];
	
	/*DRAW SKILL TIME LEFT & PROGRESS BOXES*/
	
	/*skill box recctangle*/
	NSRect skillBoxRect = [self skillBoxRect:&bounds infoRect:&infoRect yOffset:3.5];
	[self drawSkillProgressBoxes:skillBoxRect];
	
	NSRect skillProgressRect = [self skillProgressRect:&bounds infoRect:&infoRect yOffset:7.0];
	[self drawSkillProgressBar:skillProgressRect];
	
	/*Draw the Level X string, next to the progress boxes*/
	CGFloat topMaxX = [self drawTrainingToLevel:skillBoxRect.origin.x - 3.5 yBaseline:skillBoxRect.origin.y - 1.0];
	
	CGFloat bottomMaxX = [self drawTimeLeftString:skillBoxRect.origin.x - 3.5 yBaseline:skillBoxRect.origin.y + 15.0];
	
	/*FINISHED DRAWING SKILL PROGRESS BOXES*/
	
	
	/*DRAW SKILL NAME AND SKILL POINTS*/
	//Skill name and rank
	NSString *skillName = [skill skillName];
	if(skillName == nil){
		NSLog(@"nil skill name");
	}
	str = [NSString stringWithFormat:@"%@ (%ldx)",[skill skillName],[skill skillRank]];
	astr = [[[NSMutableAttributedString alloc]initWithString:str]autorelease];
	/*this needs to be calculated with regard to the skill progress boxes*/  
	//Skill name rect (upper rect)
	NSRect upperRect = [self upperRectForBounds:&bounds andString:astr];
	
	/*clamp width so it does not run over topMaxX*/
	
	if(upperRect.size.width > (topMaxX - upperRect.origin.x))
	{
		upperRect.size.width = topMaxX - upperRect.origin.x;
		strrange = NSMakeRange(0,[astr length]);
		/*this will get created once for every cell that is drawn. fix later;*/

		
		[astr addAttribute:NSParagraphStyleAttributeName value:truncateStyle range:strrange];		
	}
	
	[astr drawInRect:upperRect];
	
	//Skill point display rect (subtitle rect)
	astr = [self buildSubtitleString];
	

	//Skill points subtitle block
	NSRect subRect = [self rectForSubTitleBasedOnTitleRect:upperRect inBounds:bounds forString:astr];
	
	if(subRect.size.width > (bottomMaxX - subRect.origin.x)){
		
		subRect.size.width = bottomMaxX - subRect.origin.x;
		
		strrange = NSMakeRange(0,[astr length]);
		[astr addAttribute:NSParagraphStyleAttributeName value:truncateStyle range:strrange];
	}
	
	[self drawSubtitleInRect:subRect theString:astr];
}

- (void)drawInteriorWithFrame:(NSRect)bounds inView:(NSView *)controlView
{
	//[super drawInteriorWithFrame:bounds inView:controlView];
	if(mode == Mode_Group){
		[self drawGroupInterior:bounds inView:controlView];
	}else{
		[self drawSkillInterior:bounds inView:controlView];
	}
}

+ (BOOL)prefersTrackingUntilMouseUp {
    // NSCell returns NO for this by default. If you want to have trackMouse:inRect:ofView:untilMouseUp:
	// always track until the mouse is up, then you MUST return YES. Otherwise, strange things will happen.
    return YES;
}

- (BOOL)trackMouse:(NSEvent *)theEvent 
			inRect:(NSRect)cellFrame 
			ofView:(NSView *)controlView 
	  untilMouseUp:(BOOL)flag 
{
	
    [self setControlView:controlView];
	
    NSRect infoButtonRect = [self infoButtonRect:cellFrame];
    while ([theEvent type] != NSLeftMouseUp) {
        // This is VERY simple event tracking. We simply check to see if the mouse is in the "i" button or not and dispatch entered/exited mouse events
        NSPoint point = [controlView convertPoint:[theEvent locationInWindow] fromView:nil];
        BOOL mouseInButton = NSMouseInRect(point, infoButtonRect, [controlView isFlipped]);
        if (iMouseDownInInfoButton != mouseInButton) {
            iMouseDownInInfoButton = mouseInButton;
            [controlView setNeedsDisplayInRect:cellFrame];
        }
        if ([theEvent type] == NSMouseEntered || [theEvent type] == NSMouseExited) {
            [NSApp sendEvent:theEvent];
        }
        // Note that we process mouse entered and exited events and dispatch them to properly handle updates
        theEvent = [[controlView window] nextEventMatchingMask:(NSLeftMouseUpMask | NSLeftMouseDraggedMask | NSMouseEnteredMask | NSMouseExitedMask)];
    }
	
    // Another way of implementing the above code would be to keep an NSButtonCell as an ivar, and simply call trackMouse:inRect:ofView:untilMouseUp: on it, if the tracking area was inside of it. 
	
    if (iMouseDownInInfoButton) {
        // Send the action, and redisplay
        iMouseDownInInfoButton = NO;
        [controlView setNeedsDisplayInRect:cellFrame];
        if (skillInfoButtonAction) {
            [NSApp sendAction:skillInfoButtonAction to:[self target] from:[self controlView]];
        }
    }
	
    // We return YES since the mouse was released while we were tracking. Not returning YES when you processed the mouse up is an easy way to introduce bugs!
    return YES;
}

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

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
	
    NSPoint point = [controlView convertPoint:[event locationInWindow] fromView:nil];
	
    // How about the info button?
    NSRect infoButtonRect = [self infoButtonRect:cellFrame];
    if (NSMouseInRect(point, infoButtonRect, [controlView isFlipped])) {
        return NSCellHitContentArea | NSCellHitTrackableArea;
    } 
	
    return NSCellHitNone;
}

@end
