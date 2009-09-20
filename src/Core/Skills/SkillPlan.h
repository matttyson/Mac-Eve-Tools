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

#import "SkillPair.h"


//Some of the comments in this file may or may not be a bit out of date


/*
	the skillPlan array is an array of SkillPrerequisite objects.
	
	the array must always be in the correct prerequsite order, so that the skill plan can be 
	trained from beginning to end
*/
@class Character;

@interface SkillPlan : NSObject {
	/*the array of objects in the skill plan*/
	NSMutableArray *skillPlan;
	/*the start and finish dates of each skill in the plan, use accesor methods to get the dates*/
	NSMutableArray *skillDates;
	/*Skill points per hour that the skill will be training at, taking into account modifiers such as learning skills*/
	NSMutableArray *spHrArray;
	/*this should be kept somewhere else*/
	Character *character; //the character that created this object. NOT RETAINED.
	
	NSString *planName;
	NSInteger planTrainingTime;
	NSInteger planId;
	BOOL dirty;	
}

@property (readwrite,retain,nonatomic) NSString* planName;
@property (readwrite,nonatomic) BOOL dirty;
@property (readonly,nonatomic) NSInteger planId;

/*name of the plan, and the skillset that the character has.*/

// deprecated. don't use anymore
-(SkillPlan*) initWithName:(NSString*)name 
				 character:(Character*)ch;


/*
	create a skill plan through the character object, don't
	call this directly
 */
-(SkillPlan*) initWithName:(NSString*)name 
			  forCharacter:(Character*)ch 
					withId:(NSInteger)pId;


/* 
 If the skill can be added, it and any prerequisites will be added in the required order.
 
 Returns the number of skills added
 */
-(NSInteger) addSkillToPlan:(NSNumber*)skillID level:(NSInteger)skillLevel;

/*add suppy an array of SkillPrerequisite* objects*/
-(void) addSkillArrayToPlan:(NSArray*)prereqArray;

/*
 remove skills from the plan. must not break the prerequisite requirements of the plan.
 generate array using constructAntiPlan
 */
-(BOOL) removeSkillArrayFromPlan:(NSArray*)prereqArray;

/*number of skills in the plan*/
-(NSInteger) skillCount;
-(SkillPair*) skillAtIndex:(NSInteger)index;
/*sp/hr for the skill at index, adjusted for any learning skills that have been added*/
-(NSNumber*) spHrForSkill:(NSInteger)index;

/*supply an array of indexes of skills you want to move, and the location where you want them all inserted*/
-(BOOL) moveSkill:(NSArray*)fromIndexArray to:(NSInteger)toIndex;

/*returns the total training time of the plan in seconds*/
-(NSInteger) trainingTime;
-(NSInteger) trainingTime:(BOOL)recalc;

/*should be obvious*/
-(void) savePlan;

/*remove the skill at skillIndex, returns an array of skills to be removed.*/
-(NSArray*) constructAntiPlan:(NSInteger)skillIndex;
-(NSArray*) constructAntiPlan:(NSUInteger*)skillIndex arrayLength:(NSUInteger)arrayLength;

/*returns a start and finish date the indexed skill*/
-(NSDate*) skillTrainingStart:(NSInteger)skillIndex;
-(NSDate*) skillTrainingFinish:(NSInteger)skillIndex;

-(NSDate*) planFinishDate;

-(NSInteger) purgeCompletedSkills;

/*used by the database backend to load up skill plans, does not perform validation*/
-(void) secretAddSkillToPlan:(NSNumber*)typeID level:(NSInteger)level;

@end
