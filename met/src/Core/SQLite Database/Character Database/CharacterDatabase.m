//
//  CharacterDatabase.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 6/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CharacterDatabase.h"
#import "SkillPlan.h"
#import "CharacterDatabasePrivate.h"
#import "Character.h"
#import "macros.h"

/*database to store information about a character*/

#import <sqlite3.h>


/*
	main table
 
 int version ;database schema version
 varchar character_name ; name of the character

	skill plan overview table

 int plan_id; plan id
 varchar plan_name;
 
	skill plan table
 int plan_id; the plan this skill belongs to
 int type_order; the order of this skill in the plan
 int type_id; the skills typeid (as used by the eve skill list xml sheet)
 int level; the rank we are training to
 
 */



@implementation CharacterDatabase



//const char existenceTest[] = "SELECT count(*) FROM sqlite_master WHERE tbl_name='master';";


-(BOOL) createDatabase
{
	char *errmsg;
	char *strbuf;
	const char createMasterTable[] = "CREATE TABLE master (version INTEGER, character_name VARCHAR(32));";
	const char populateMasterTable[] = "INSERT INTO master (version,character_name) VALUES (%d,%Q);";
	const char createSkillPlanOverviewTable[] = 
			"CREATE TABLE skill_plan_overview (plan_id INTEGER PRIMARY KEY, plan_name VARCHAR(64), UNIQUE(plan_name));";
	const char createSkillPlanTable[] =
			"CREATE TABLE skill_plan (plan_id INTEGER, type_order INTEGER, type_id INTEGER, level INTEGER);";
	int rc;
	
	[self beginTransaction];
	
	rc = sqlite3_exec(db,createMasterTable,NULL,NULL,&errmsg);
	if(rc != SQLITE_OK){
		[self logError:errmsg];
		[self rollbackTransaction];
		return NO;
	}
	
	strbuf = sqlite3_mprintf(populateMasterTable,1,"foo");
	rc = sqlite3_exec(db,strbuf,NULL,NULL,&errmsg);
	sqlite3_free(strbuf);
	
	if(rc != SQLITE_OK){
		[self logError:errmsg];
		[self rollbackTransaction];
		return NO;
	}
	
	rc = sqlite3_exec(db,createSkillPlanTable,NULL,NULL,&errmsg);
	if(rc != SQLITE_OK){
		[self logError:errmsg];
		[self rollbackTransaction];
		return NO;
	}
	
	rc = sqlite3_exec(db,createSkillPlanOverviewTable,NULL,NULL,&errmsg);
	if(rc != SQLITE_OK){
		[self logError:errmsg];
		[self rollbackTransaction];
		return NO;
	}
	
	[self commitTransaction];
	return YES;
}

#define CURRENT_DB_VERSION 2


-(BOOL) upgradeDatabaseFromVersion:(NSInteger)currentVersion toVersion:(NSInteger)toVersion
{
	if(currentVersion == 1){
		const char rename[] = "ALTER TABLE skill_plan_overview RENAME TO skill_plan_overview_old;";
		const char createSkillPlanOverviewTable2[] = 
			"CREATE TABLE skill_plan_overview (plan_id INTEGER PRIMARY KEY, plan_name VARCHAR(64), UNIQUE(plan_name));";
		const char copySkillPlanTable[] = "INSERT INTO skill_plan_overview SELECT plan_id, plan_name FROM skill_plan_overview_old;";
		const char dropOldPlanOverview[] = "DROP TABLE skill_plan_overview_old;";
		const char updateVersion[] = "UPDATE master SET version = 2;";
		char *error;
		int rc;
		[self beginTransaction];
		
		rc = sqlite3_exec(db,rename,NULL,NULL,&error);
		if(rc != SQLITE_OK){
			[self logError:error];
			[self rollbackTransaction];
			return NO;
		}
		rc = sqlite3_exec(db,createSkillPlanOverviewTable2,NULL,NULL,&error);
		if(rc != SQLITE_OK){
			[self logError:error];
			[self rollbackTransaction];
			return NO;
		}
		rc = sqlite3_exec(db,copySkillPlanTable,NULL,NULL,&error);
		if(rc != SQLITE_OK){
			[self logError:error];
			[self rollbackTransaction];
			return NO;
		}
		rc = sqlite3_exec(db,dropOldPlanOverview,NULL,NULL,&error);
		if(rc != SQLITE_OK){
			[self logError:error];
			[self rollbackTransaction];
			return NO;
		}
		
		rc = sqlite3_exec(db,updateVersion,NULL,NULL,&error);
		if(rc != SQLITE_OK){
			[self logError:error];
			[self rollbackTransaction];
			return NO;
		}
		
		[self commitTransaction];
		
		NSLog(@"Succesfully upgraded character database");
		return YES;
	}
	return NO;
}

-(BOOL) checkStatus
{
	char **results;
	char *errormsg;
	const char existenceTest[] = "SELECT version FROM master;";
	BOOL status = YES;
	int rc;
	int rows;
	int cols;
	long version;
	
	rc = sqlite3_get_table(db, existenceTest, &results, &rows, &cols, &errormsg);
	
	if(rows != 1){
		NSLog(@"Database does not exist");
		status = NO;
		return NO;
	}
		
	if(strcmp(results[0],"version") != 0){
		status = NO;
	}
	
	version = strtol(results[1],NULL,10);
	
	if(version != CURRENT_DB_VERSION){
		rc = [self upgradeDatabaseFromVersion:version toVersion:CURRENT_DB_VERSION];
	}
	
	if(results != NULL){
		sqlite3_free_table(results);
	}
	if(errormsg){
		[self logError:errormsg];
	}
	
	return status;
}

-(CharacterDatabase*) initWithPath:(NSString*)dbPath
{
	if(self = (CharacterDatabase*)[super initWithPath:dbPath]){
		[self initDatabase];
	}
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(BOOL) initDatabase
{
	[self openDatabase];
	
	int rc = [self checkStatus];
	if(!rc){
		rc = [self createDatabase];
		if(!rc){
			NSLog(@"error initialising database database");
			return NO;
		}
	}
	[self closeDatabase];
	
	return rc;
}

-(BOOL) writeSkillPlans:(NSArray*)plans
{
	BOOL rc;
	[self openDatabase];
	[self beginTransaction];
	
	for(SkillPlan *sp in plans){
		if([sp dirty]){
			rc = [self deleteSkillPlanPrivate:sp];
			if(!rc){
				NSLog(@"error deleting skill plan %@",[sp planName]);
				[self rollbackTransaction];
				return NO;
			}
			rc = [self writeSkillPlanPrivate:sp];
			if(!rc){
				NSLog(@"error writing skill plan %@",[sp planName]);
				[self rollbackTransaction];
				return NO;
			}			
		}
	}
	
	rc = [self commitTransaction];
	[self closeDatabase];
	
	if(rc){
		for(SkillPlan *sp in plans){
			[sp setDirty:NO];
		}
	}else{
		NSLog(@"error comming transaction");
	}
	return YES;
}

-(BOOL) deleteAllSkillPlans
{
	[self openDatabase];
	[self beginTransaction];
	BOOL rc = [self deleteAllSkillPlansPrivate];
	[self commitTransaction];
	[self closeDatabase];
	
	return rc;
}

/*delete a single plan*/
-(BOOL) deleteSkillPlan:(SkillPlan*)plan
{
	[self openDatabase];
	[self beginTransaction];
	
	if(![self deleteSkillPlanPrivate:plan]){
		NSLog(@"error deleting plan %@",[plan planName]);
		[self rollbackTransaction];
		return NO;
	}
	
	[self commitTransaction];
	[self closeDatabase];

	return YES;
}

/*write a plan to the database*/
-(BOOL) writeSkillPlan:(SkillPlan*)plan
{
	[self openDatabase];
	[self beginTransaction];
	
	if(![self writeSkillPlanPrivate:plan]){
		NSLog(@"error writing plan %@",[plan planName]);
		[self rollbackTransaction];
		[self closeDatabase];
		return NO;
	}
	
	[self commitTransaction];
	[plan setDirty:NO];
	[self closeDatabase];
	return YES;
}

-(BOOL) readSkillPlan:(SkillPlan*)plan planId:(sqlite_int64)planId
{
	[self openDatabase];
	
	[self readSkillPlanPrivate:plan planId:planId];
	
	[self closeDatabase];
	
	/*
	 remove any skills that have been completed
	 This has the potential to open the database connection, so make sure we close the old one first
	 */
	[plan purgeCompletedSkills];
	
	return YES;
}

/*read in all the skill plans for this character*/
-(NSMutableArray*) readSkillPlans:(Character*)character;
{
	NSMutableArray *skillPlans;
	const char select_skill_plan_overview[] = "SELECT plan_id, plan_name FROM skill_plan_overview;";
	sqlite3_stmt *read_overview_stmt;
	int rc;
	
	[self openDatabase];
	
	rc = sqlite3_prepare_v2(db, select_skill_plan_overview,(int)sizeof(select_skill_plan_overview)
							,&read_overview_stmt, NULL);
	if(rc != SQLITE_OK){
		NSLog(@"sqlite error\n");
		if(read_overview_stmt != NULL){
			sqlite3_finalize(read_overview_stmt);
		}
		[self closeDatabase];
		return nil;
	}
	
	skillPlans = [[[NSMutableArray alloc]init]autorelease];

	while((rc = sqlite3_step(read_overview_stmt)) == SQLITE_ROW){
		sqlite_int64 planId = sqlite3_column_int64(read_overview_stmt,0);
		const unsigned char *planName = sqlite3_column_text(read_overview_stmt,1);
		/*
		SkillPlan *sp = [[SkillPlan alloc]initWithName:
						 [NSString stringWithUTF8String:(const char*)planName]
											 character:character];
		*/
		SkillPlan *sp = [[SkillPlan alloc]
						 initWithName:[NSString stringWithUTF8String:(const char*)planName]
						 forCharacter:character
						 withId:(NSInteger)planId];
		
		[self readSkillPlanPrivate:sp planId:planId];
		[skillPlans addObject:sp];
		[sp release];
	}
		
	sqlite3_finalize(read_overview_stmt);
	
	[self closeDatabase];
	
	return skillPlans;
}

-(SkillPlan*) createPlan:(NSString*)planName forCharacter:(Character*)ch
{
	[self openDatabase];
	
	sqlite_int64 planId = [self createSkillPlan:planName];

	[self closeDatabase];

	
	if(planId == -1){
		NSLog(@"Duplicate plan name %@",planName);
		return nil;
	}
	
	SkillPlan *sp = [[[SkillPlan alloc]initWithName:planName forCharacter:ch withId:(NSInteger)planId]autorelease];
	
	return sp;
}

@end
