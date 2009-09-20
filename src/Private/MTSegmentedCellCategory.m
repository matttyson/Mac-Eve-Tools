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

#import "MTSegmentedCellCategory.h"


@implementation NSSegmentedCell (MTSegmentedCellCategory) 

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
