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
@class CCPGroup;

/*
	Contains a list of groups that belong to that category, sorted in alphabetical order
 */

@interface CCPCategory : NSObject {
	NSInteger categoryID;
	NSInteger graphicID;
	NSString *categoryName;
	
	CCPDatabase *database;
	
	NSArray *groups;
	NSInteger groupCount;
}

@property (readonly, nonatomic) NSInteger categoryID;
@property (readonly, nonatomic) NSInteger graphicID;
@property (readonly, nonatomic) NSString* categoryName;

-(NSInteger) groupCount;
-(CCPGroup*) groupAtIndex:(NSInteger)groupIndex;
-(CCPGroup*) groupByID:(NSInteger)gID;


-(CCPCategory*) initWithCategory:(NSInteger)categoryID 
						 graphic:(NSInteger)graphicID 
							name:(NSString*)categoryName
						database:(CCPDatabase*)db;

@end
