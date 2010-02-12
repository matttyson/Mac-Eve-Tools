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

#import "Account.h"
#import "Character.h"
#import "SkillTree.h"
#import "CharacterDatabase.h"
#import "SkillPair.h"
#import "macros.h"


/*
	This class should represent everything about a particular charcater - all the info
	parsed from the character XML sheet
 */


/*prevent circular includes*/
@class SkillPlan;

@class Character;


@interface Character : NSObject <NSOutlineViewDataSource> {
	NSUInteger characterId; /*char id. this + acct ID can be used to determine the URL for the sheet*/
	NSString *characterName;
		
	NSMutableDictionary *data; /*generic key value data*/
	SkillTree *skillTree; /*The skills that this character has.*/
		
	SkillPlan *trainingQueue; //Skills that are in the current training queue.
	NSMutableArray *skillPlans;
	CharacterDatabase *db;
	NSNumber *trainingSkill;
	
	NSImage *portrait;
	
	NSString *errorMessage[CHAR_ERROR_TOTAL];
	
	NSDate *cacheExpiry;
	
	NSMutableSet *ownedCerts;//Certs that have been awarded to this character. NSNumber certID.
	
	NSInteger updateProgress;
		
	NSInteger baseAttributes[ATTR_TOTAL]; //base attribute levels before modification
	NSInteger implantAttributes[ATTR_TOTAL]; //implants
	NSInteger learningTotals[ATTR_TOTAL]; //the sum of all the learning skills.
	NSInteger tempBonuses[ATTR_TOTAL]; //temporary values used when calculating an optimized training queue
	NSInteger learningBonus; //bonus to the learning skill
	
	CGFloat attributeTotals[ATTR_TOTAL]; //the total with all bonuses applied
	
	BOOL error[CHAR_ERROR_TOTAL]; /*YES if there was an error*/
	BOOL isTraining; /*is this character currently training?*/	
}

/*
	Supply a path to the directory where all the character files live.  the object
	will create itslef with the needed data.
 */

-(Character*) initWithPath:(NSString*)path;

/*Get a string value from the NSDictionary - see the #defines above for valid key values*/
-(NSString*) stringForKey:(NSString*)key;
/*
 returns an integer representation, if the value is an integer
 results are undefined if the key does not contain a string representation of an integer value
*/
-(NSInteger) integerForKey:(NSString*)key;

/*returns an attribute as a string for easy display*/
-(NSString*) getAttributeString:(NSInteger)attr;

-(NSInteger) skillPointTotal;
-(NSInteger) skillsAtV;
-(NSInteger) skillsKnown;

/*the number of skill points per hour the character trains. see macros.h for skill types*/

/*
 how long the character will take to train X skill points with the given attributes. 
	does not take into account partially trained skills
 */
-(NSInteger) trainingTimeInSeconds:(NSInteger)primary 
						 secondary:(NSInteger)secondary 
					   skillPoints:(NSInteger)sp;

/*
	how long the character will take to train the given skill. 
	this will take in to account partially trained skills
 */
-(NSInteger) trainingTimeInSeconds:(NSNumber*)typeID 
						 fromLevel:(NSInteger)fromLevel 
						   toLevel:(NSInteger)toLevel;

/*
 as above, but take in to account the skill that is currently training
 by estimating how many skill points we would have, assuming training has
 been done uninterrupted.
 */
-(NSInteger) trainingTimeInSeconds:(NSNumber*)typeID 
						 fromLevel:(NSInteger)fromLevel 
						   toLevel:(NSInteger)toLevel 
		   accountForTrainingSkill:(BOOL)train;

/*0.0 - 1.0 how complete is the skill?*/
-(CGFloat) percentCompleted:(NSNumber*)typeID 
				  fromLevel:(NSInteger)fromLevel 
					toLevel:(NSInteger)toLevel;

-(NSInteger) spPerHour:(NSInteger)primary 
			 secondary:(NSInteger)secondary;
/*sp per hour for the currently training skill*/
-(NSInteger) spPerHour;

-(NSDictionary*) skillSet; /*get the current skill set*/

/*Skill plan methods*/
-(NSInteger) skillPlanCount;

-(SkillPlan*) createSkillPlan:(NSString*)planName;

//This is messy, remove the redundant ones and have a single method
-(void) removeSkillPlan:(SkillPlan*)plan;
-(void) removeSkillPlanById:(NSInteger)planId;
-(void) removeSkillPlanAtIndex:(NSInteger)index;

-(SkillPlan*) skillPlanAtIndex:(NSInteger)index;
-(SkillPlan*) skillPlanById:(NSInteger)planId;

//save the name change of the plan.
-(BOOL) renameSkillPlan:(SkillPlan*)plan; 

/*!NOTE! the skill functions below will be (possibly) be ripped out later.*/
-(void) updateSkillPlan:(SkillPlan*)plan; /*as above, but supply a skill plan object in the characters internal skill plan queue*/

/*these error functions might also get ripped out.*/
-(BOOL) charSheetError;
-(BOOL) trainingSheetError;

-(NSString*) charSheetErrorMessage;
-(NSString*) trainingSheetErrorMessage;

/*modify attribute by level - used for optimising a skill plan*/
-(void) modifyAttribute:(NSInteger)attribute  byLevel:(NSInteger)level;
-(void) modifyLearning:(NSInteger)level;
-(void) resetTempAttrBonus; //reset the bonuses back to the normal levels.

/*calculate the final attribute totals*/
-(void) processAttributeSkills;

/*is the character currently training?*/
-(BOOL) isTraining;
-(NSNumber*)trainingSkill;

/*
 returns autoreleased objects
 DO NOT call these methods if isTraining returns NO
 */
-(NSInteger) skillTrainingFinishSeconds;
-(NSInteger) currentSPForTrainingSkill;
-(SkillPair*) currentlyTrainingSkill;
-(NSDate*) skillTrainingFinishDate;

/*return YES if this Character has been awarded this cert.*/
-(BOOL) hasCert:(NSInteger)certID;

@property (readonly,nonatomic) NSImage* portrait;
@property (readonly,nonatomic) NSUInteger characterId;
@property (readonly,nonatomic) NSString* characterName;

@property (readonly,nonatomic) SkillTree* skillTree;
@property (readonly,nonatomic) SkillPlan* trainingQueue;

@end
