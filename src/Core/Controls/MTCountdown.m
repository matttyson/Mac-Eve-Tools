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

#import "MTCountdown.h"
#import "macros.h"
#import "Helpers.h"

@implementation MTCountdown

-(void) tick
{
	if(realInterval > 0){
		realInterval--;
		
		[self setNeedsDisplay:YES];
	}
}

- (id)initWithFrame:(NSRect)FrameRect
{
	if(self = [super initWithFrame:FrameRect]){
		active = NO;
		complete = NO;
		visible = YES;
	}
	return self;
}

-(void) setInterval:(NSInteger)inter
{
	if(inter > 0){
		realInterval = (NSInteger) inter;
	}
}

-(void) drawRect:(NSRect)rect
{	
	NSRect bounds = [self bounds];
		
	NSString *countdown;
	
	if(visible){
		countdown = stringTrainingTime2(realInterval,TTF_All);
	}else{
		countdown = @"";
	}
	[self setStringValue:countdown];
	
	[super drawRect:bounds];
}


-(void) setVisible:(BOOL)vis
{
	visible = vis;
	
	if(!active){
		[self setNeedsDisplay:YES];
	}
}

@end
