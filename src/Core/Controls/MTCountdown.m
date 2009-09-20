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

@interface MTCountdown (MTCountdownPrivate)

-(void) timeRemaining;
-(void) tick:(NSTimer*)theTimer;

@end

@implementation MTCountdown (MTCountdownPrivate)

-(void) tick:(NSTimer*)theTimer
{
	realInterval--;
	
	if(realInterval == 0){
		[self deactivate];
	}
	[self setNeedsDisplay:YES];
}

-(void) timeRemaining
{
	NSInteger remain = realInterval;
	
	if(realInterval <= 0){
		return;
	}
	
	days = realInterval / SEC_DAY;
	remain = remain - (days * SEC_DAY);
	
	hours = remain / SEC_HOUR;
	remain = remain - (hours * SEC_HOUR);
	
	min = remain / SEC_MINUTE;
	sec = remain - (min * SEC_MINUTE);
}

@end

@implementation MTCountdown

- (id)initWithFrame:(NSRect)FrameRect
{
	if(self = [super initWithFrame:FrameRect]){
		active = NO;
		complete = NO;
		visible = YES;
	}
	return self;
}

-(void) setInterval:(NSTimeInterval)inter
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
		[self timeRemaining];
		countdown = [NSString stringWithFormat:@"%ldd %ldh %ldm %lds",days,hours,min,sec];
	}else{
		countdown = @"";
	}
	[self setStringValue:countdown];
	
	[super drawRect:bounds];
}

-(void) activate
{
	if(active){ //retard detection
		return;
	}
	active = YES;
	assert(timer == nil);
	
	timer = [NSTimer scheduledTimerWithTimeInterval:1.0
					 target:self
					selector:@selector(tick:)
					 userInfo:nil
					 repeats:YES];
}

-(void) deactivate
{
	active = NO;
	if(timer != nil){
		[timer invalidate];
		timer = nil;
	}
}

-(void) setVisible:(BOOL)vis
{
	visible = vis;
	
	if(!active){
		[self setNeedsDisplay:YES];
	}
}

@end
