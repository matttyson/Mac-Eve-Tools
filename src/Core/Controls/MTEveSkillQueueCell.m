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

#import "MTEveSkillQueueCell.h"


#import "SkillPair.h"
#import "Skill.h"

@implementation MTEveSkillQueueCell

@synthesize startLoc;
@synthesize finishLoc;

-(void) initStaticData
{
	skillPendingColor = [[NSColor colorWithDeviceRed:56.0/255.0 green:117.0/255.0 blue:215.0/255.0 alpha:1.0]retain];	
}

-(id) init
{
	if(self = [super init]){
		[self initStaticData];
	}
	return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	if((self = [super initWithCoder:aDecoder])){
		[self initStaticData];		
	}
	return self;
}

-(void) dealloc
{
	[skillPendingColor release];
	[pair release];
	[super dealloc];
}

-(id) copyWithZone:(NSZone *)zone
{
	MTEveSkillQueueCell *cell = [super copyWithZone:zone];
	if(cell != nil){
		cell->skillPendingColor = [skillPendingColor retain];
		
		cell->pair = nil;
	}
	return cell;
}

-(SkillPair*) pair
{
	return pair;
}

-(void) setPair:(SkillPair*)skillPair
{
	if(pair != nil){
		[pair release];
	}
	
	pair = [skillPair retain];
	
	realSkillLevel = skillLevel;
	skillLevel = [pair skillLevel];
}

-(NSRect) rectForProgressBar:(NSRect)bounds
{
	NSRect result = bounds;
	
	bounds.origin.y = bounds.size.height - 3;
	return result;
}

-(void) setColourForLevel:(NSInteger)level
{
	if(level > realSkillLevel){
		[skillPendingColor set];
	}else{
		[[NSColor blackColor]set];
	}
}

- (void)drawInteriorWithFrame:(NSRect)bounds inView:(NSView *)controlView
{
	[super drawInteriorWithFrame:bounds inView:controlView];
}

#pragma mark Overridden methods

-(NSAttributedString*) buildSubtitleString
{
	return nil;
}

-(void) drawSubtitleInRect:(NSRect)bounds theString:(NSAttributedString*)astr
{
	
}

-(void) drawInfoIcon:(NSRect)bounds
{
	
}

- (NSRect) infoButtonRect:(NSRect)bounds
{
	NSRect result = bounds;
	result.origin.x = bounds.size.width;
	return result;
}

@end
