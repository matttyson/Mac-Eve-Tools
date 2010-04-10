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

#import "MTEveSkillQueueHeader.h"
#import "Helpers.h"
#import "SkillPlan.h"
#import "Character.h"
#import "MTEveSkillQueueCell.h"
#import "Config.h"
#import "SkillTree.h"
#import "macros.h"

@implementation MTEveSkillQueueHeader



#define VIEW_PADDING 3.0

-(void)awakeFromNib
{
	
}


-(void) secondTimerTick:(id)sender
{
	
}

-(CGFloat) descenderOffsetForText:(NSAttributedString*)text
{
	NSFont *font = [text attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
	if(font == nil){
		font = [NSFont systemFontOfSize:0.0];
	}
	CGFloat descender = [font descender];
	return descender;
}

-(NSRect) rectForFinishDate:(NSRect)bounds text:(NSAttributedString*)text
{
	NSSize textSize = [text size];
	CGFloat descender = [self descenderOffsetForText:text];
	NSRect result = NSMakeRect(bounds.origin.x - 0.5,
							   bounds.origin.y + VIEW_PADDING + descender, 
							   textSize.width, textSize.height);
	
	
	return result;
}


-(NSRect) rectForProgressBar:(NSRect)bounds aboveText:(NSAttributedString*)text
{
	//should be 19 pixels in height
	NSRect result = NSMakeRect(bounds.origin.x,
							   bounds.origin.y + [text size].height + 1.0,
							   bounds.size.width,
							   19.0);
	return result;
}

-(NSRect) rectForHourMarks:(NSRect)bounds progressRect:(NSRect)progress
{
	NSRect result = NSMakeRect(progress.origin.x,progress.origin.y + progress.size.height + 1.0,
							   progress.size.width,19.0);
	return result;
}

-(void) drawText:(NSRect)bounds text:(NSAttributedString*)text
{
	[text drawInRect:bounds];
	//[text drawAtPoint:bounds.origin];
}

-(void) drawHourMarkings:(NSRect)bounds
{
	/*draw the hour markings on the screen. a 5px long line*/
		
	CGFloat width = bounds.size.width;
	CGFloat spacing = (width / 25.0);
	spacing = spacing + (spacing / 25.0);
	NSPoint start = bounds.origin;
	NSPoint end = NSMakePoint(bounds.origin.x,bounds.origin.y + 5.0);
	
	[[NSColor blackColor]set];
	NSBezierPath *path = [[NSBezierPath alloc]init];
	[path setLineWidth:1.0];
	
	NSPoint s = NSMakePoint(0.0,start.y);
	NSPoint e = NSMakePoint(0.0,end.y);
	
	for(NSInteger i = 0; i < 25; i++){
		s.x = xround(start.x)+0.5;
		e.x = s.x;
		
		[path moveToPoint:s];
		[path lineToPoint:e];
		[path stroke];
		[path closePath];
		
		start.x += spacing;
		end.x += spacing;
	}
	[path release];
	
	NSRect textRect;
	NSSize textSize;
	NSAttributedString *astr = [[[NSAttributedString alloc]initWithString:@"0"]autorelease];
	textSize = [astr size];
	textRect = NSMakeRect(bounds.origin.x - (textSize.width / 2.0),
						  bounds.origin.y + 6.0, textSize.width,textSize.height);
	[astr drawInRect:textRect];
	
	astr = [[[NSAttributedString alloc]initWithString:@"12"]autorelease];
	textSize = [astr size];
	textRect = NSMakeRect((bounds.origin.x + (spacing * 12.0)) - (textSize.width / 2.0),
						  bounds.origin.y + 6.0, 
						  textSize.width,textSize.height);
	[astr drawInRect:textRect];
	
	astr = [[[NSAttributedString alloc]initWithString:@"24"]autorelease];
	textSize = [astr size];
	textRect = NSMakeRect((bounds.origin.x + (spacing * 24.0)) - (textSize.width / 2.0),
						  bounds.origin.y + 6.0, 
						  textSize.width,textSize.height);
	[astr drawInRect:textRect];
	
	//[skillPlanView setNeedsDisplay:YES];
}

/*
-(void) shadeProgressBar:(NSRect)bounds
{
	NSRect drawRect = bounds;
	
	drawRect.size.height /= 2;
	drawRect.origin.y += drawRect.size.height;
	
	[[[NSColor blackColor]colorWithAlphaComponent:0.10]set];
	
	[NSBezierPath fillRect:drawRect];
}
*/


-(void) shadeProgressBar:(NSRect)drawRect
{	
	drawRect.size.height = xfloor(drawRect.size.height / 2.0);
	
	[[[NSColor whiteColor]colorWithAlphaComponent:0.15]set];
	[NSBezierPath fillRect:drawRect];
}


-(void) drawProgressBar:(NSRect)bounds
{
	NSColor *color = progressColor1;
	
	[color set];
	
	NSInteger count = [plan skillCount];
	
	SkillTree *st = [character skillTree];
	
	NSRect drawArea = bounds;
	
	CGFloat width = bounds.size.width; //The amount of width left
	CGFloat totalWidth = bounds.size.width; //The total width of the box
	
	NSInteger totalTime = 0;
	
	for(NSInteger i = 0; i < count; i++){
		SkillPair *pair = [plan skillAtIndex:i];
		Skill *s = [st skillForId:[pair typeID]];
		NSInteger skillLevel = [pair skillLevel];
		NSInteger time = [character trainingTimeInSeconds:[s typeID]
												fromLevel:skillLevel-1
												  toLevel:skillLevel];
		
		if(time == 0){
			continue;
		}
		
		totalTime += time;
		
		/*calculate time as a percentage of 24 hrs*/
		CGFloat percentage = (time / (CGFloat)SEC_DAY);
		
		/*draw x percent of the total width*/
		CGFloat drawLength = xceil(totalWidth * percentage);
		
//		CGFloat lengthWithOffset = drawArea.size.width + drawLength + drawArea.origin.x;
		
		drawArea.size.width = MIN(drawLength, width);
		[color set];
		[NSBezierPath fillRect:drawArea];
		
		if(drawArea.size.width == totalWidth){
			//Terminate early if we exceed 24 hours
			[self shadeProgressBar:bounds];
			break;
		}
		
		drawArea.origin.x += drawArea.size.width;
		width -= drawArea.size.width;
		
		if(color == progressColor1){
			color = progressColor2;
		}else{
			color = progressColor1;
		}
	}
	bounds.size.width = bounds.size.width - width;
	[self shadeProgressBar:bounds];
}

-(void) drawStringEndingAtPoint:(const NSPoint*)endPoint 
						   text:(NSAttributedString*)text
{
	NSSize textSize = [text size];
	NSPoint startPoint = NSMakePoint(endPoint->x - textSize.width, endPoint->y);
	NSRect area = NSMakeRect(endPoint->x - textSize.width, endPoint->y, textSize.width, textSize.height);
	
	[text drawInRect:area];
}

-(void) drawCountdown:(const NSPoint*)endPoint
{
	//NSString *str = stringTrainingTime2([plan trainingTime:YES],TTF_All);	
	NSString *str = stringTrainingTime2(planTrainingTime, TTF_All);
//	NSLog(@"%@",str);
	NSAttributedString *astr = [[NSAttributedString alloc]initWithString:str];
	
	[self drawStringEndingAtPoint:endPoint text:astr];
	
	[astr release];
}

-(NSRect) getDrawFrame:(const NSRect*)rect
{
	NSRect newRect = NSMakeRect(0.0, 0.0, rect->size.width, rect->size.height);
	
	newRect.origin.x += 5.0;
	newRect.size.width -= 10.0;
	
	return newRect;
}

-(void) tick
{
	planTrainingTime--;

	[self setNeedsDisplay:YES];
}

-(NSInteger)timeRemaining
{
	return planTrainingTime;
}

-(void) setTimeRemaining:(NSInteger)timeRemaining
{
	planTrainingTime = timeRemaining;
}

- (void)drawRect:(NSRect)rect {
	// Drawing code here.
	if(plan == nil){
		return;
	}
	
	if(!active){
		return;
	}
	
	NSRect newRect = [self getDrawFrame:&rect];
	
	NSInteger trainingTime = [plan trainingTime:YES];
	NSString *str;
	NSMutableAttributedString *astr;
	NSRect drawRect;
	
	if(trainingTime != 0){
		NSPoint textEndPoint = NSMakePoint(newRect.size.width, newRect.origin.y);
		[self drawCountdown:&textEndPoint];
	}
	
	NSDate *finishDate = [plan skillTrainingFinish:[plan skillCount]-1];
	if(trainingTime == 0){
		str = @"Completed";
	}else{
		str = [dFormat stringFromDate:finishDate];
	}
		
	astr = [[[NSMutableAttributedString alloc]initWithString:str]autorelease];
	drawRect = [self rectForFinishDate:newRect text:astr];
	if(NSContainsRect(rect,drawRect)){
		[self drawText:drawRect text:astr];
	}
	
	drawRect = [self rectForProgressBar:newRect aboveText:astr];
	if(NSContainsRect(rect,drawRect)){
		[self drawProgressBar:drawRect];
	}
	
	drawRect = [self rectForHourMarks:newRect progressRect:drawRect];
	if(NSContainsRect(rect,drawRect)){
		[self drawHourMarkings:drawRect];
	}
}

-(BOOL) isFlipped
{
	return YES;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		progressColor1 = [[NSColor colorWithDeviceRed:56.0/255.0 green:117.0/255.0 blue:215.0/255.0 alpha:1.0]retain];
		progressColor2 = [[NSColor colorWithDeviceRed:20.0/255.0 green:61.0/255.0 blue:153.0/255.0 alpha:1.0]retain];
		
		dFormat = [[NSDateFormatter alloc]init];
		[dFormat setFormatterBehavior:NSDateFormatterBehavior10_4];
		[dFormat setDateStyle:NSDateFormatterFullStyle];
		[dFormat setTimeStyle:NSDateFormatterShortStyle];
	}
	return self;
}
		

-(SkillPlan*) skillPlan
{
	return plan;
}

-(Character*) character
{
	return character;
}
-(void) setCharacter:(Character*)c
{
	if(character != nil){
		[character release];
	}
	character = [c retain];
	[self setNeedsDisplay:YES];
}

-(void) setSkillPlan:(SkillPlan*)skillPlan
{
	
	if(plan != nil){
		[plan release];
	}
	
	plan = [skillPlan retain];
	[self setNeedsDisplay:YES];
}

-(void) infoButtonAction:(NSTableView*)sender
{
	
}
-(void) dealloc
{
	[progressColor1 release];
	[progressColor2 release];
	[dFormat release];
	[super dealloc];
}

-(void) hideTableView
{

}

-(BOOL) hidden
{
	return active;
}
-(void) setHidden:(BOOL)hidden
{
	active = !hidden;
	[super setHidden:hidden];
}


@end
