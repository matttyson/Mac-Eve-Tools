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

#import "SqliteDatabase.h"

@class CCPCategory;
@class CCPGroup;
@class CCPType;
@class METShip;

@interface CCPDatabase : SqliteDatabase {
	
}

/*
	-1, nil or NO will be returned on error
 */

-(CCPDatabase*) initWithPath:(NSString*)dbpath;

-(CCPCategory*) category:(NSInteger)categoryID;
/*return all categories*/
-(NSArray*) categoriesInDB;
-(NSInteger) categoryCount;

-(CCPGroup*) group:(NSInteger)groupID;
/*return an array of all the groups that exist in the category*/
-(NSArray*) groupsInCategory:(NSInteger)categoryID;
-(NSInteger) groupCount:(NSInteger)categoryID;

-(CCPType*) type:(NSInteger)typeID;
/*An array of all types in that group*/
-(NSArray*) typesInGroup:(NSInteger)groupID;
-(NSInteger) typeCount:(NSInteger)groupID;

-(NSArray*) prereqForType:(NSInteger) typeID;

/*given a typeID, what is it's parent typeID and metaGroup ?*/
-(BOOL) parentForTypeID:(NSInteger)typeID parentTypeID:(NSInteger*)parent metaGroupID:(NSInteger*)metaGroup;

/*get the metaLevel for the given typeID*/
-(NSInteger) metaLevelForTypeID:(NSInteger)typeID;

-(BOOL) isPirateShip:(NSInteger)typeID;

-(NSDictionary*) typeAttributesForTypeID:(NSInteger)typeID;


/*given the typeID, return a ship object*/
-(METShip*) shipForTypeID:(NSInteger)typeID;

@end
