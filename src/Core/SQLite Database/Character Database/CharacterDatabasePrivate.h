//
//  CharacterDatabasePrivate.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 6/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CharacterDatabase.h"
#import <sqlite3.h>

@interface CharacterDatabase (CharacterDatabasePrivate) 

/*these are private functions that should be called from within a transaction*/

-(BOOL) readSkillPlanPrivate:(SkillPlan*)plan planId:(sqlite_int64)planId;
-(BOOL) deleteSkillPlanOverviewById:(sqlite_int64)planId;

-(BOOL) deleteSkillPlanById:(sqlite_int64)planId;
-(BOOL) deleteSkillPlanPrivate:(SkillPlan*)plan;
-(BOOL) deleteAllSkillPlansPrivate;

/*
 the SkillPlan class now has this identifier internally, but it never used to
 This function is mostly historical now.
*/
-(sqlite_int64) findSkillPlanId:(SkillPlan*)plan;
-(sqlite_int64) createSkillPlan:(NSString*)name;

-(BOOL) writeSkillPlanPrivate:(SkillPlan*)plan;
-(BOOL) writeSkillPlanById:(sqlite_int64)planId forPlan:(SkillPlan*)plan;

-(BOOL) renameSkillPlanPrivate:(SkillPlan*)plan;

@end
