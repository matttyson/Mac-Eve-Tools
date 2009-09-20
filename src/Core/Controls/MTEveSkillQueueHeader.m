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

-(NSRect) rectForCountdown:(NSRect)bounds text:(NSAttributedString*)text
{
	NSSize textSize = [text size];
	CGFloat descender = [self descenderOffsetForText:text];
	NSRect result = NSMakeRect(bounds.size.width - textSize.width + VIEW_PADDING,
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
	
	SkillTree *st = [character st];
	
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

- (void)drawRect:(NSRect)rect {
	// Drawing code here.
	if(plan == nil){
		return;
	}
	
	if(!active){
		return;
	}
	
	NSRect newRect = NSMakeRect(0.0, 0.0, rect.size.width, rect.size.height);
	
	newRect.origin.x += 5.0;
	newRect.size.width -= 10.0;
	
	/*FIXME TODO this may return a NULL string, which breaks everything*/
	NSInteger trainingTime = [plan trainingTime:YES];
	NSString *str;
	NSMutableAttributedString *astr;
	NSRect drawRect;
	
	if(trainingTime == 0){
		//the skill queue has one skill in it, which has finished training
		str = @"Completed";
	}else{
		str = stringTrainingTime2([plan trainingTime:YES],TTF_All);	
		astr = [[[NSMutableAttributedString alloc]initWithString:str]autorelease];
		drawRect = [self rectForCountdown:newRect text:astr];
		if(NSContainsRect(rect, drawRect)){
			[self drawText:drawRect text:astr];
		}
	}
	
	NSDateFormatter *f = [[[NSDateFormatter alloc]init]autorelease];
	[f setFormatterBehavior:NSDateFormatterBehavior10_4];
	[f setDateStyle:NSDateFormatterFullStyle];
	[f setTimeStyle:NSDateFormatterShortStyle];
	
	NSDate *finishDate = [plan skillTrainingFinish:[plan skillCount]-1];
	if(trainingTime == 0){
		str = @"Completed";
	}else{
		str = [f stringFromDate:finishDate];
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
        // Initialization code here.
		progressColor1 = [[NSColor colorWithDeviceRed:56.0/255.0 green:117.0/255.0 blue:215.0/255.0 alpha:1.0]retain];
		progressColor2 = [[NSColor colorWithDeviceRed:20.0/255.0 green:61.0/255.0 blue:153.0/255.0 alpha:1.0]retain];
		
		NSAttributedString *attr = [[[NSAttributedString alloc]initWithString:@"test"]autorelease];
		NSRect temp = [self rectForFinishDate:frame text:attr];
		temp = [self rectForHourMarks:frame progressRect:temp];
		/*This isn't right, it uses some hardcoded values which happen to work, fix later.*/
		temp.size.height = frame.size.height - temp.origin.y - 29.0;
		temp.size.width = frame.size.width - 7.0;
		temp.origin.y += 29.0;
		temp.origin.x = 4.0;
		
		scrollView = [[NSScrollView alloc]initWithFrame:temp];
		[scrollView setFocusRingType:NSFocusRingTypeNone];
		[scrollView setHasVerticalScroller:YES];
		[scrollView setHasHorizontalScroller:YES];
		[scrollView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
		[scrollView setAutoresizesSubviews:YES];
		[scrollView setAutohidesScrollers:YES];
		
		/*
		 This should be removed and done seperatly, instead of one big frame.
		 The skill queue progress bar should be one view, the NSTableView should be
		 in a seperate class. not here
		 */
		skillPlanView = [[NSTableView alloc]initWithFrame:[scrollView frame]];
		[skillPlanView setFocusRingType:NSFocusRingTypeNone];
		[skillPlanView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
		[skillPlanView setAllowsColumnSelection:YES];		
		[skillPlanView setDelegate:self];
		[skillPlanView setDataSource:self];
		[skillPlanView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
		[skillPlanView setRowHeight:38.0];
		
		[scrollView setDocumentView:skillPlanView];
		
		[self addSubview:scrollView positioned:NSWindowAbove relativeTo:nil];
		
		MTEveSkillQueueCell *cell = [[MTEveSkillQueueCell alloc]init];
		
		[cell setMode:Mode_Skill];
		[cell setTarget:self];
		
		NSNumberFormatter *f = [[NSNumberFormatter alloc]init];
		[f setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];
		[cell setFormatter:f];
		[f release];
		
		[cell setTarget:self];
		
		NSTableColumn *col = [[NSTableColumn alloc]initWithIdentifier:@"SKILL_QUEUE"];
		[[col headerCell]setStringValue:@"Training Queue"];
		[col setDataCell:cell];
		[col setMaxWidth:500.0];
		[col setWidth:[scrollView frame].size.width];
		[col setEditable:NO];
		[skillPlanView addTableColumn:col];
		[col release];
		[cell release];
		
		plan = nil;
		character = nil;
		
		[scrollView setHidden:NO];
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
	[skillPlanView noteNumberOfRowsChanged];
	[skillPlanView reloadData];
	[self setNeedsDisplay:YES];
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if(plan == nil){
		return 0;
	}
	if(character == nil){
		return 0;
	}
	
	return [plan skillCount];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return nil;
}

-(void) infoButtonAction:(NSTableView*)sender
{
	
}

- (void)tableView:(NSTableView *)aTableView 
  willDisplayCell:(id)aCell 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(NSInteger)rowIndex
{
	if(plan == nil){
		return;
	}
	if(character == nil){
		return;
	}
	if([aCell isKindOfClass:[MTEveSkillQueueCell class]]){
		MTEveSkillQueueCell *cell = aCell;
		SkillPair *pair = [plan skillAtIndex:rowIndex];
		
		NSNumber *typeID = [pair typeID];
		NSInteger skillLevel = [pair skillLevel];
		
		[cell setSkill:[[character st]skillForId:typeID]];
		[cell setPair:pair];
		
		NSInteger trainTime = [character trainingTimeInSeconds:typeID 
													 fromLevel:skillLevel-1 
													   toLevel:skillLevel 
									   accountForTrainingSkill:YES];
		[cell setTimeLeft:trainTime];
		
		if(rowIndex == 0){
			//NSInteger points = [character currentSPForTrainingSkill];
			//NSInteger pointsForLevel = totalSkillPointsForLevel(skillLevel, [[tree skillForId:typeID]skillRank]);
			//CGFloat progress = ((CGFloat)points / (CGFloat)pointsForLevel);
			CGFloat progress = [character percentCompleted:[pair typeID] fromLevel:skillLevel-1 toLevel:skillLevel];
			[cell setPercentCompleted:progress];
		}else{
			
			Skill *s = [[character st]skillForId:typeID];
			if(s == nil){
				[cell setPercentCompleted:0];
			}else{
				[cell setPercentCompleted:
					[character percentCompleted:typeID fromLevel:skillLevel-1 toLevel:skillLevel]
				 ];
			}
		}
		/*calculate the start and finish times for the cell as percentages*/
	//	NSInteger startLoc = 0;
	//	NSInteger finishLoc = 0;
	}
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
	return NO;
}

-(void) dealloc
{
	[progressColor1 release];
	[progressColor2 release];
	[skillPlanView release];
	[scrollView release];
	[super dealloc];
}

-(void) hideTableView
{
	[skillPlanView setHidden:YES];
	[skillPlanView display];
}

-(BOOL) hidden
{
	return active;
}
-(void) setHidden:(BOOL)hidden
{
	active = !hidden;
	[super setHidden:hidden];
	[scrollView setHidden:hidden];
	[skillPlanView setHidden:hidden];
}


@end
