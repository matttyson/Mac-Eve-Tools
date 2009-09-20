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

#import <Cocoa/Cocoa.h>

#import "macros.h"

@class CCPType;

/*
	we group ships by races, and filter by tech level
	we filter modules by tech level
 */

@interface METSubGroup : NSObject {
	NSArray *types; //array of type objects
	NSString *groupName; //name of the group;
	CCPMetaGroup metaGroup;
	CCPRace race;
}

@property (readonly,nonatomic) NSString* groupName;
@property (readonly,nonatomic) CCPMetaGroup metaGroup;
@property (readonly,nonatomic) CCPRace race;

-(id) initWithName:(NSString*)name 
		  andTypes:(NSArray*)array 
	  forMetaGroup:(CCPMetaGroup)group 
		  withRace:(CCPRace)race;

-(NSInteger) typeCount;
-(CCPType*) typeAtIndex:(NSInteger)index;


@end
