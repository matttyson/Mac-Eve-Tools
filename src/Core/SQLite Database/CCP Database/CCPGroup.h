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

@class CCPDatabase;
@class CCPType;
@class METSubGroup;

@interface CCPGroup : NSObject {
	NSInteger groupID;
	NSInteger categoryID;
	NSInteger graphicID;
	NSString *groupName;
	
	/*the types that belong to this group*/
	NSArray *types;
	NSInteger count;
	
	CCPDatabase *database;
	
	NSMutableArray *subGroups;
}

@property (readonly, nonatomic) NSInteger groupID;
@property (readonly, nonatomic) NSInteger categoryID;
@property (readonly, nonatomic) NSInteger graphicID;
@property (readonly, nonatomic) NSString* groupName;

-(NSInteger) subGroupCount;
-(METSubGroup*) subGroupAtIndex:(NSInteger)index;

/*the number of types in this group*/
-(NSInteger) typeCount;
-(CCPType*) typeAtIndex:(NSInteger)index;
-(CCPType*) typeByID:(NSInteger)tID;

-(CCPGroup*) initWithGroup:(NSInteger)gID
				  category:(NSInteger)cID
				   graphic:(NSInteger)gaID
				 groupName:(NSString*)gName
				  database:(CCPDatabase*)db;

@end
