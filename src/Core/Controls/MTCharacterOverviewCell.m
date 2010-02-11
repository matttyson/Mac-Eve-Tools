//
//  MTCharacterOverviewCell.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 25/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MTCharacterOverviewCell.h"
#import "macros.h"
#import "Helpers.h"

@implementation MTCharacterOverviewCell

@synthesize portrait;
@synthesize isk;
@synthesize skillPoints;
@synthesize charName;
@synthesize skillName;
@synthesize finishDate;

@synthesize queueTimeLeft;
@synthesize skillTimeLeft;
@synthesize queueLength;

@synthesize isTraining;


#define PORTRAIT_PADDING 2.0
#define PORTRAIT_SIZE 96.0

-(void) createFormatters
{
	iskFormat = [[NSNumberFormatter alloc]init];
	[iskFormat setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[iskFormat setNumberStyle:NSNumberFormatterCurrencyStyle];
	[iskFormat setPositiveSuffix:@" ISK"];
	[iskFormat setNegativeSuffix:@" ISK"];
	[iskFormat setPositivePrefix:@""];
	[iskFormat setNegativePrefix:@"-"];
	
	spFormat = [[NSNumberFormatter alloc]init];
	[spFormat setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[spFormat setNumberStyle:NSNumberFormatterDecimalStyle];
	[spFormat setPositiveSuffix:@" SP"];
	
	dateFormat = [[NSDateFormatter alloc]init];
	[dateFormat setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormat setDateStyle:NSDateFormatterLongStyle];
	[dateFormat setTimeStyle:NSDateFormatterMediumStyle];
}

-(id) init
{
	if((self = [super init])){
		[self createFormatters];
	}
	return self;
}

-(id) initWithCoder:(NSCoder*)coder
{
	self = [super initWithCoder:coder];
	if(self){
		[self createFormatters];
	}
	return self;
}

-(id) copyWithZone:(NSZone*)zone
{
	MTCharacterOverviewCell *cell = [super copyWithZone:zone];
	if(cell != nil){
		cell->iskFormat = [iskFormat retain];
		cell->spFormat = [spFormat retain];
		cell->dateFormat = [dateFormat retain];
		
		/*
		 clear these out, we don't want to retain them or keep them 
		 across cells.  the old values will be released in the dealloc call.
		 */
		cell->portrait = nil;
		cell->isk = nil;
		cell->skillName = nil;
		cell->charName = nil;
	}
	return cell;
}

-(void) dealloc
{
	[iskFormat release];
	[spFormat release];
	[dateFormat release];
	
	[portrait release];
	[isk release];
	[skillName release];
	[charName release];
	[super dealloc];
}

-(NSRect) portraitRectForBounds:(NSRect)bounds
{
	NSRect result = bounds;
	
	result.origin.y += PORTRAIT_PADDING;
	result.origin.x += PORTRAIT_PADDING;
	
	result.size.width = PORTRAIT_SIZE;
	result.size.height = PORTRAIT_SIZE;
	
	CGFloat widthCentre = PORTRAIT_SIZE - NSWidth(result);
	if(widthCentre > 0){
		result.origin.x += xround(widthCentre / 2.0);
	}
	CGFloat heightCentre = PORTRAIT_SIZE - NSWidth(result);
	if(heightCentre > 0){
		result.origin.y += xround(heightCentre / 2.0);
	}
	
	return result;
}

-(void) drawInteriorWithFrame:(NSRect)bounds inView:(NSView *)controlView
{
	NSRect drawRect = NSZeroRect;
	NSPoint drawPoint;
	NSString *str;
	NSMutableAttributedString *astr;
	
	NSRect portraitFrame = [self portraitRectForBounds:bounds];
	
	//Flip the image and unflip when done.
	if([controlView isFlipped]){
		[portrait setFlipped:YES];
	}
	
	// Draw the character portrait.
	[portrait drawInRect:portraitFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	if([controlView isFlipped]){
		[portrait setFlipped:NO];
	}
	
	drawPoint.x = PORTRAIT_SIZE + (PORTRAIT_PADDING * 2.0) + 5.0;
	drawPoint.y = 0.0;
	
	drawRect.origin.x = drawPoint.x;
	
	NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
	[ctx saveGraphicsState];

	NSAffineTransform *xform = [NSAffineTransform transform];
	[xform translateXBy:bounds.origin.x yBy:bounds.origin.y];
	[xform concat];
	
	// Character name
	astr = [[[NSMutableAttributedString alloc]initWithString:charName]autorelease];
	[astr drawAtPoint:drawPoint];
	
	// Skill Points
	str = [spFormat stringFromNumber:[NSNumber numberWithInteger:skillPoints]];
	astr = [[[NSMutableAttributedString alloc]initWithString:str]autorelease];
	drawPoint.y = 16.0;
	[astr drawAtPoint:drawPoint];
	
	// ISK
	str = [iskFormat stringFromNumber:isk];
	astr = [[[NSMutableAttributedString alloc]initWithString:str]autorelease];
	drawPoint.y = 32.0;
	[astr drawAtPoint:drawPoint];
	
	if(isTraining){
		// Currently Training.
		
		// Skill Name
		str = [NSString stringWithFormat:@"%@ (%@)",skillName,stringTrainingTime(skillTimeLeft)];
		astr = [[[NSMutableAttributedString alloc]initWithString:str]autorelease];
		drawRect.size = [astr size];
		drawRect.origin.y = 48.0;
		if((drawRect.size.width + drawRect.origin.x) > (bounds.size.width)){
			drawRect.size.width = (bounds.size.width - drawRect.origin.x);
		}
		[astr drawInRect:drawRect];
		
		//Queue
		str = [NSString stringWithFormat:
			   NSLocalizedString(@"%ld skills queued (%@)",@"Character selection menu. keep translation short."),queueLength,
			   stringTrainingTime(queueTimeLeft)];
		astr = [[[NSMutableAttributedString alloc]initWithString:str]autorelease];
		drawPoint.y = 64.0;
		[astr drawAtPoint:drawPoint];
		
		//Finish dates
		str = [dateFormat stringFromDate:finishDate];
		astr = [[[NSMutableAttributedString alloc]initWithString:str]autorelease];
		drawRect.size = [astr size];
		drawRect.origin.y = 80.0;
		if((drawRect.size.width + drawRect.origin.x) > (bounds.size.width)){
			drawRect.size.width = (bounds.size.width - drawRect.origin.x);
		}
		[astr drawInRect:drawRect];
	}
	
	[ctx restoreGraphicsState];
}

@end
