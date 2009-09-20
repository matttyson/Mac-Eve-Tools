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

#import "CCPDatabase.h"
#import "CCPGroup.h"
#import "CCPCategory.h"
#import "CCPType.h"
#import "Helpers.h"
#import "macros.h"
#import "SkillPair.h"

#import <sqlite3.h>


@implementation CCPDatabase

-(CCPDatabase*) initWithPath:(NSString*)dbpath
{
	if(self = [super initWithPath:dbpath]){
		[self openDatabase];
	}
	return self;
}

-(void) dealloc
{
	[self closeDatabase];
	[super dealloc];
}

-(CCPCategory*) category:(NSInteger)categoryID
{
	const char query[] = 
		"SELECT categoryID, categoryName, graphicID FROM invCategories WHERE categoryID = ? "
		"ORDER BY categoryName;";
	sqlite3_stmt *read_stmt;
	int rc;
	
	
	rc = sqlite3_prepare_v2(db,query,(int)sizeof(query),&read_stmt,NULL);
	if(rc != SQLITE_OK){
		NSLog(@"%s: sqlite error\n",__func__);
		return nil;
	}
	
	sqlite3_bind_nsint(read_stmt,1,categoryID);
	
	CCPCategory *cat = nil;
	
	if(sqlite3_step(read_stmt) == SQLITE_ROW){
		NSInteger cID = sqlite3_column_nsint(read_stmt,0);
		const unsigned char *str = sqlite3_column_text(read_stmt,1);
		NSString *cName = [NSString stringWithUTF8String:(const char*)str];
		NSInteger gID = sqlite3_column_nsint(read_stmt,2);
	
		cat = [[CCPCategory alloc]initWithCategory:cID
										   graphic:gID 
											  name:cName
										  database:self];
		[cat autorelease];
	}
	
	sqlite3_finalize(read_stmt);
	
	return cat;
}

-(NSInteger) categoryCount
{
	const char query[] = "SELECT COUNT(*) FROM invCategories;";
	return [self performCount:query];
}

-(NSArray*) categoriesInDB
{
	return nil;
}

#pragma mark groups

-(NSInteger) groupCount:(NSInteger)categoryID
{
	NSLog(@"Insert code here");
	return 0;
}

-(CCPGroup*) group:(NSInteger)groupID
{
	const char query[] = "SELECT groupID, categoryID, groupName, graphicID FROM invGroups WHERE groupID = ?;";
	sqlite3_stmt *read_stmt;
	CCPGroup *group = nil;
	int rc;

	rc = sqlite3_prepare_v2(db,query,(int)sizeof(query),&read_stmt,NULL);
	if(rc != SQLITE_OK){
		NSLog(@"%s: sqlite error\n",__func__);
		return nil;
	}
	
	sqlite3_bind_nsint(read_stmt,1,groupID);
	
	if(sqlite3_step(read_stmt) == SQLITE_ROW){
		NSInteger groupID,categoryID,graphicID;
		NSString *groupName;
		const char *str;
		
		groupID = sqlite3_column_nsint(read_stmt,0);
		categoryID = sqlite3_column_nsint(read_stmt,1);
		//str = sqlite3_column_text(read_stmt,2);
		groupName = sqlite3_column_nsstr(read_stmt,2);
		graphicID = sqlite3_column_nsint(read_stmt,3);
		
		group = [[CCPGroup alloc] initWithGroup:groupID
									   category:categoryID 
										graphic:graphicID
									  groupName:groupName
									   database:self];
		[group autorelease];
	}
	
	sqlite3_finalize(read_stmt);
	
	return group;
}


-(NSArray*) groupsInCategory:(NSInteger)categoryID
{
	const char query[] = 
		"SELECT groupID, categoryID, groupName, graphicID " 
		"FROM invGroups WHERE categoryID = ? "
		"ORDER BY groupName;";
	sqlite3_stmt *read_stmt;
	int rc;
	
	rc = sqlite3_prepare_v2(db,query,(int)sizeof(query),&read_stmt,NULL);
	if(rc != SQLITE_OK){
		NSLog(@"%s: sqlite error\n",__func__);
		return nil;
	}
	
	sqlite3_bind_nsint(read_stmt,1,categoryID);
	
	NSMutableArray *array = [[[NSMutableArray alloc]init]autorelease];
	
	while(sqlite3_step(read_stmt) == SQLITE_ROW){
		NSInteger groupID,categoryID,graphicID;
		NSString *groupName = nil;
		CCPGroup *group;
		
		groupID = sqlite3_column_nsint(read_stmt,0);
		categoryID = sqlite3_column_nsint(read_stmt,1);
		groupName = sqlite3_column_nsstr(read_stmt,2);
		graphicID = sqlite3_column_nsint(read_stmt,3);
		
		group = [[CCPGroup alloc]initWithGroup:groupID
									  category:categoryID 
									   graphic:graphicID
									 groupName:groupName
									  database:self];
		[array addObject:group];
		[group release];		
	}
	
	sqlite3_finalize(read_stmt);
	
	return array;
}

#pragma mark typeSMInt

-(NSInteger) typeCount:(NSInteger)groupID
{
	const char query[] = "SELECT COUNT(*) FROM invTypes WHERE typeID = ?;";
	NSLog(@"Insert code here");
	return 0;
}

-(CCPType*) type:(NSInteger)typeID
{
	NSLog(@"Insert code here");
	return nil;
}

-(NSArray*) typesInGroup:(NSInteger)groupID
{
	const char query[] = 
		"SELECT typeID, groupID, graphicID, raceID, marketGroupID,radius, mass, volume, capacity,"
		"basePrice, typeName, description FROM invTypes WHERE groupID = ? "
		"ORDER BY typeName;";
	sqlite3_stmt *read_stmt;
	int rc;
	
	rc = sqlite3_prepare_v2(db,query,(int)sizeof(query),&read_stmt,NULL);
	if(rc != SQLITE_OK){
		NSLog(@"%s: sqlite error\n",__func__);
		return nil;
	}
	
	sqlite3_bind_nsint(read_stmt,1,groupID);
	
	NSMutableArray *array = [[[NSMutableArray alloc]init]autorelease];
	
	while(sqlite3_step(read_stmt) == SQLITE_ROW){
		CCPType *type = [[CCPType alloc]
						 initWithType:sqlite3_column_nsint(read_stmt,0)
						 group:sqlite3_column_nsint(read_stmt,1)
						 graphic:sqlite3_column_nsint(read_stmt,2)
						 race:sqlite3_column_nsint(read_stmt,3)
						 marketGroup:sqlite3_column_nsint(read_stmt,4)
						 radius:sqlite3_column_double(read_stmt,5)
						 mass:sqlite3_column_double(read_stmt,6)
						 volume:sqlite3_column_double(read_stmt,7)
						 capacity:sqlite3_column_double(read_stmt,8)
						 basePrice:sqlite3_column_double(read_stmt,9)
						 typeName:sqlite3_column_nsstr(read_stmt,10)
						 typeDesc:sqlite3_column_nsstr(read_stmt,11)
						 database:self];
		
		[array addObject:type];
		[type release];		
	}
	
	sqlite3_finalize(read_stmt);
	
	return array;
}

-(NSArray*) prereqForType:(NSInteger)typeID
{
	const char query[] = 
		"SELECT skillTypeID, skillLevel FROM typePrerequisites WHERE typeID = ? ORDER BY skillOrder;";
	sqlite3_stmt *read_stmt;
	int rc;
	
	rc = sqlite3_prepare_v2(db,query,(int)sizeof(query),&read_stmt,NULL);
	if(rc != SQLITE_OK){
		NSLog(@"%s: sqlite error\n",__func__);
		return nil;
	}
	
	sqlite3_bind_nsint(read_stmt,1,typeID);
	
	NSMutableArray *array = [[[NSMutableArray alloc]init]autorelease];
	
	while(sqlite3_step(read_stmt) == SQLITE_ROW){
		NSInteger skillTypeID = sqlite3_column_nsint(read_stmt,0);
		NSInteger skillLevel = sqlite3_column_nsint(read_stmt,1);
		SkillPair *pair = [[SkillPair alloc]initWithSkill:
						   [NSNumber numberWithInteger:skillTypeID] 
												level:skillLevel];
		[array addObject:pair];
		[pair release];
	}
	
	sqlite3_finalize(read_stmt);
	
	return array;
}

-(BOOL) parentForTypeID:(NSInteger)typeID parentTypeID:(NSInteger*)parent metaGroupID:(NSInteger*)metaGroup
{
	const char query[] = 
		"SELECT parentTypeID, metaGroupID FROM invMetaTypes WHERE typeID = ?;";
	sqlite3_stmt *read_stmt;
	int rc;
	
	rc = sqlite3_prepare_v2(db,query,(int)sizeof(query),&read_stmt,NULL);
	if(rc != SQLITE_OK){
		NSLog(@"%s: sqlite error\n",__func__);
		return NO;
	}
	
	sqlite3_bind_nsint(read_stmt,1,typeID);
	
	while(sqlite3_step(read_stmt) == SQLITE_ROW){
		if(parent != NULL){
			*parent = sqlite3_column_nsint(read_stmt,0);
		}
		if(metaGroup != NULL){
			*metaGroup = sqlite3_column_nsint(read_stmt,1);
		}
	}
	
	sqlite3_finalize(read_stmt);
	
	return YES;
}

-(NSInteger) metaLevelForTypeID:(NSInteger)typeID
{
	NSInteger metaLevel = -1;
	const char query[] =
		"SELECT COALESCE(valueInt,valueFloat) FROM dgmTypeAttributes WHERE attributeID = 633 AND typeID = ?;";
	sqlite3_stmt *read_stmt;
	int rc;
	
	rc = sqlite3_prepare_v2(db,query,(int)sizeof(query),&read_stmt,NULL);
	if(rc != SQLITE_OK){
		NSLog(@"%s: sqlite error\n",__func__);
		return -1;
	}
	
	sqlite3_bind_nsint(read_stmt,1,typeID);
	
	while(sqlite3_step(read_stmt) == SQLITE_ROW){
		metaLevel = sqlite3_column_nsint(read_stmt,0);
	}
	
	sqlite3_finalize(read_stmt);
	
	return metaLevel;
}

-(BOOL) isPirateShip:(NSInteger)typeID
{
	BOOL result = NO;
	
	const char query[] = 
		"SELECT COALESCE(valueInt,valueFloat) FROM dgmTypeAttributes WHERE attributeID = 793 AND typeID = ?;";
	sqlite3_stmt *read_stmt;
	int rc;
	
	rc = sqlite3_prepare_v2(db,query,(int)sizeof(query), &read_stmt, NULL);
	if(rc != SQLITE_OK){
		NSLog(@"%s: sqlite error\n",__func__);
		return -1;
	}
	
	sqlite3_bind_nsint(read_stmt,1,typeID);
	
	while(sqlite3_step(read_stmt) == SQLITE_ROW){
		result = YES;
	}
	
	sqlite3_finalize(read_stmt);
	
	return result;
}
//elect ta.*,at.attributeName from dgmTypeAttributes ta INNER JOIN dgmAttributeTypes at ON ta.attributeID = at.attributeID where typeID = 17636;

@end
