//
//  CharacterDatabase.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 6/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SqliteDatabase.h"

@class SkillPlan;
@class Character;

typedef struct sqlite3_stmt sqlite3_stmt;


@interface CharacterDatabase : SqliteDatabase {

	
}

-(CharacterDatabase*) initWithPath:(NSString*)dbPath;

/*returns an aray of all skill plans for the character*/
-(NSMutableArray*) readSkillPlans:(Character*)character;
/*synchronise all plans in the array with the database. any plans not in the array will be deleted*/
-(BOOL) writeSkillPlans:(NSArray*)plans;

/*writes a skill plan out to the database*/
-(BOOL) writeSkillPlan:(SkillPlan*)plan;
-(BOOL) deleteSkillPlan:(SkillPlan*)plan;

/*Set the name of the skill plan object, then write it out to disk.*/
-(BOOL) renameSkillPlan:(SkillPlan*)plan;

-(BOOL) deleteAllSkillPlans;

-(BOOL) initDatabase;


/*
 This is the only method you should use to create a plan. DO NOT create a skill plan
 using the alloc init methods.
 
 SkillPlan is returned autoreleased
 */
-(SkillPlan*) createPlan:(NSString*)planName forCharacter:(Character*)ch;

@end
