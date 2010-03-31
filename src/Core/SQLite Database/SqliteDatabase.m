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

#import "SqliteDatabase.h"

#import <sqlite3.h>

@implementation SqliteDatabase

-(SqliteDatabase*) initWithPath:(NSString*)dbPath
{
	if(self = [super init]){
		
		databasePath = [dbPath retain];
		path = strdup([dbPath fileSystemRepresentation]);
		pathLength = strlen(path);
	}
	return self;
}

-(void) dealloc
{
	[self closeDatabase];
	free(path);
	[databasePath release];
	[super dealloc];
}

-(void) openDatabase
{
	if(db == NULL){
		int rc  = sqlite3_open(path,&db);
		if(rc != SQLITE_OK){
			NSLog(@"%@ error: %s",[self className],sqlite3_errmsg(db));
			[self closeDatabase];
		}
	}
}
-(void) closeDatabase
{	
	if(db != NULL){
		int rc;
				
		if((rc = sqlite3_close(db)) != SQLITE_OK){
			NSLog(@"%@ error: (%d) %s",[self className],rc,sqlite3_errmsg(db));
		}
		db = NULL;
	}
}

-(NSInteger) performCount:(const char*)query
{
	int rows,cols;
	int rc;
	BOOL isNull = (db == NULL);
	NSInteger count = 0;
	char **results;
	char *errormsg;
	
	if(isNull){
		[self openDatabase];
	}
	
	rc = sqlite3_get_table(db,query,&results,&rows,&cols,&errormsg);
	if(rc == SQLITE_OK){
		count = strtol(results[0],NULL,10);
		sqlite3_free_table(results);
	}
	
	if(isNull){
		[self closeDatabase];
	}
	return count;
}

-(BOOL) beginTransaction
{
	const char query[] = "BEGIN;";
	char *errmsg;
	
	int rc = sqlite3_exec(db,query,NULL,NULL,&errmsg);
	if(errmsg != NULL){
		[self logError:errmsg];
	}
	return (rc == SQLITE_OK);
}

-(BOOL) commitTransaction
{
	const char query[] = "COMMIT;";
	char *errmsg;
	
	int rc = sqlite3_exec(db,query,NULL,NULL,&errmsg);
	if(errmsg != NULL){
		[self logError:errmsg];
	}
	
	return (rc == SQLITE_OK);
}

-(BOOL) rollbackTransaction
{
	const char query[] = "ROLLBACK;";
	char *errmsg;
	
	int rc = sqlite3_exec(db,query,NULL,NULL,&errmsg);
	if(errmsg != NULL){
		[self logError:errmsg];
	}
	return (rc == SQLITE_OK);
}

-(void) logError:(char*)errmsg
{
	if(errmsg != NULL){
		NSLog(@"SQL Error: %s",errmsg);
		sqlite3_free(errmsg);
	}
}

@end
