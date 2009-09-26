//
//  CharacterDatabasePrivate.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 6/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CharacterDatabasePrivate.h"
#import "SkillPair.h"
#import "SkillPlan.h"
#import <sqlite3.h>
#import "macros.h"

@implementation CharacterDatabase (CharacterDatabasePrivate) 

//Read the skill plan items into the skill plan.
-(BOOL) readSkillPlanPrivate:(SkillPlan*)plan planId:(sqlite_int64)planId
{
	const char select_skill_plan[] = "SELECT type_id, level FROM skill_plan WHERE plan_id = ? ORDER BY type_order;";
	sqlite3_stmt *read_skill_stmt = NULL;
	int rc;	
	
	rc = sqlite3_prepare_v2(db,select_skill_plan,(int)sizeof(select_skill_plan),&read_skill_stmt,NULL);
	if(rc != SQLITE_OK){
		
		NSLog(@"sqlite error\n");
		if(read_skill_stmt != NULL){
			sqlite3_finalize(read_skill_stmt);
		}
		[self closeDatabase];
		
		return NO;
	}
	
	rc = sqlite3_bind_int64(read_skill_stmt,1,planId);
	
	NSMutableArray *array = [[NSMutableArray alloc]init];
	
	while(sqlite3_step(read_skill_stmt) == SQLITE_ROW){
		NSInteger type = sqlite3_column_nsint(read_skill_stmt,0);
		NSInteger level = sqlite3_column_nsint(read_skill_stmt,1);
		SkillPair *pair = [[SkillPair alloc]initWithSkill:[NSNumber numberWithInteger:type] level:level];
		[array addObject:pair];
		[pair release];
	}
	
	[plan addSkillArrayToPlan:array];
	[array release];	
	[plan setDirty:NO];
	
	sqlite3_finalize(read_skill_stmt);
	
	return YES;
}


-(BOOL) deleteAllSkillPlansPrivate
{
	const char delete_overview[] = "DELETE FROM skill_plan_overview;";
	const char delete_skill_plan[] = "DELETE FROM skill_plan;";
	char *errmsg;
	int rc;
	
	rc = sqlite3_exec(db,delete_overview,NULL,NULL,&errmsg);
	if(errmsg != NULL){
		[self logError:errmsg];
		return NO;
	}
	rc = sqlite3_exec(db,delete_skill_plan,NULL,NULL,&errmsg);
	if(errmsg != NULL){
		[self logError:errmsg];
		return NO;
	}
	
	return YES;
}


-(BOOL) deleteSkillPlanOverviewById:(sqlite_int64)planId
{
	const char delete_skill_plan[] = "DELETE FROM skill_plan_overview WHERE plan_id = %lld";
	char buf[64];
	int rc;
	char *errmsg;
	
	snprintf(buf, sizeof(buf), delete_skill_plan, planId);
	
	rc = sqlite3_exec(db,buf,NULL,NULL,&errmsg);
	
	if(errmsg != NULL){
		[self logError:errmsg];
	}
	
	return rc == SQLITE_OK;
}

-(BOOL) deleteSkillPlanById:(sqlite_int64)planId
{
	const char delete_skill_plan[] = "DELETE FROM skill_plan WHERE plan_id = %lld";
	char buf[64];
	int rc;
	char *errmsg;
	
	snprintf(buf, sizeof(buf), delete_skill_plan, planId);
	
	rc = sqlite3_exec(db,buf,NULL,NULL,&errmsg);
	
	if(errmsg != NULL){
		[self logError:errmsg];
	}
	
	return rc == SQLITE_OK;
}

-(BOOL) deleteSkillPlanPrivate:(SkillPlan*)plan
{
	sqlite_int64 planId;
	BOOL rc;
	
	planId = [self findSkillPlanId:plan];
	
	if(planId == -1){
		/*something is fucked*/
		NSLog(@"Error inserting skill plan %@",[plan planName]);
		return NO;
	}
	
	rc = [self deleteSkillPlanOverviewById:planId];
	
	if(!rc){
		NSLog(@"failed to delete skill plan overview for id %lld",planId);
		return NO;
	}
	
	return [self deleteSkillPlanById:planId];
}

-(sqlite_int64) findSkillPlanId:(SkillPlan*)plan
{
	const char planid[] = "SELECT plan_id FROM skill_plan_overview WHERE plan_name = %Q;";
	char buf[256];
	sqlite_int64 rowId;
	char **results;
	char *errmsg;
	int rows;
	int cols;
	int rc;
	
	sqlite3_snprintf((int)sizeof(buf), buf, planid,[[plan planName]UTF8String]);
	
	rc = sqlite3_get_table(db, buf, &results, &rows, &cols, &errmsg);
	
	if(rc != SQLITE_OK){
		[self logError:errmsg];
		return -1;
	}
	
	if(rows == 0){
		rowId = [self createSkillPlan:[plan planName]];
	}else{
		rowId = strtol(results[1],NULL,10);
	}
	
	if(results != NULL){
		sqlite3_free_table(results);
	}
	
	if(errmsg != NULL){
		[self logError:errmsg];
	}
	
	return rowId;
}

/*
 creates a new skill plan in the database, returns -1 on error
 plan_id on success
 */
-(sqlite_int64) createSkillPlan:(NSString*)name
{
	const char create_plan[] = "INSERT INTO skill_plan_overview VALUES(NULL,%Q);";
	char buf[128];
	char *errmsg;
	int rc;
	
	sqlite3_snprintf((int)sizeof(buf),buf,create_plan,[name UTF8String]);
	
	rc = sqlite3_exec(db, buf,NULL,NULL,&errmsg);
	if(rc != SQLITE_OK){
		[self logError:errmsg];
		return -1;
	}
	
	return sqlite3_last_insert_rowid(db);
}

/*
 note: this will delete any existing skill plan before writing out the new plan
*/

-(BOOL) writeSkillPlanPrivate:(SkillPlan*)plan
{
	/*get the plan id for this plan name*/
	
	sqlite_int64 planId;
	
	planId = [self findSkillPlanId:plan];
	
	if(planId == -1){
		NSLog(@"Plan '%@' does not exist - creating a new plan!",[plan planName]);
		planId = [self createSkillPlan:[plan planName]];
	}
	
	if(planId == -1){
		/*something is fucked*/
		NSLog(@"Error inserting skill plan %@",[plan planName]);
		return NO;
	}
	
	if(![self deleteSkillPlanById:planId]){
		return NO;
	}
	return [self writeSkillPlanById:planId forPlan:plan];
}



-(BOOL) writeSkillPlanById:(sqlite_int64)planId forPlan:(SkillPlan*)plan
{
	const char insert_skill[] = "INSERT INTO skill_plan VALUES (?,?,?,?);";
	sqlite3_stmt *insert_skill_stmt;
	BOOL success = YES;
	int rc;
	
	NSInteger skillCount = [plan skillCount];
	
	rc = sqlite3_prepare_v2(db,insert_skill,(int)sizeof(insert_skill),&insert_skill_stmt,NULL);
	
	rc = sqlite3_bind_int64(insert_skill_stmt,1,planId);
	
	for(NSInteger i = 0; i< skillCount; i++){
		SkillPair *sp = [plan skillAtIndex:i];
		rc = sqlite3_bind_nsint(insert_skill_stmt,2,i);
		rc = sqlite3_bind_nsint(insert_skill_stmt,3,[[sp typeID]integerValue]);
		rc = sqlite3_bind_nsint(insert_skill_stmt,4,[sp skillLevel]);
		
		if((rc = sqlite3_step(insert_skill_stmt)) != SQLITE_DONE){
			NSLog(@"sqlite error inserting skill plan");
			success = NO;
			break;
		}
		sqlite3_reset(insert_skill_stmt);
	}
	
	sqlite3_finalize(insert_skill_stmt);
	
	return success;
}

-(BOOL) renameSkillPlanPrivate:(SkillPlan*)plan
{
	const char rename_plan[] = "UPDATE skill_plan_overview SET plan_name = ? WHERE plan_id = ?;";
	sqlite3_stmt *rename_stmt;
	BOOL success = YES;
	int rc;
	
	rc = sqlite3_prepare_v2(db,rename_plan,(int)sizeof(rename_plan),&rename_stmt,NULL);
	
	NSString *planName = [plan planName];
	
	rc = sqlite3_bind_text(rename_stmt,1,[planName UTF8String],
						   (int)[planName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
						   NULL);
	rc = sqlite3_bind_nsint(rename_stmt,2,[plan planId]);
	
	if((rc = sqlite3_step(rename_stmt)) != SQLITE_DONE){
		NSLog(@"Error renaming skill plan");
		success = NO;
	}
	
	sqlite3_reset(rename_stmt);
	
	sqlite3_finalize(rename_stmt);
	
	return success;
}

@end
