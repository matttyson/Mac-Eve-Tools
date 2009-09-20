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

#import "Config.h"
#import "Character.h"
#import "CharacterPrivate.h"
#import "XmlFetcher.h"
#import "XmlHelpers.h"
#import "Helpers.h"
#import "SkillPlan.h"

#import "GlobalData.h"

#import "XMLDownloadOperation.h"
#import "XMLParseOperation.h"

#import <libxml/tree.h>
#import <libxml/parser.h>

@implementation Character

#pragma mark initialisers

@synthesize st;
@synthesize characterId;
@synthesize characterName;
@synthesize portrait;
@synthesize trainingQueue;

-(void) dealloc
{
	[characterName release];
	[data release];
	[st release];
	[db closeDatabase];
	[db release];
	[skillPlans release];
	[portrait release];
	[trainingQueue release];
	[trainingSkill release];
	
	for(NSInteger i = 0; i < CHAR_ERROR_TOTAL;i++){
		if(errorMessage[i] == nil){
			[errorMessage[i] release];
		}
	}
	
	[super dealloc];
}


/*don't call init*/
-(Character*)init
{
	[self doesNotRecognizeSelector:_cmd];
}

-(Character*) initWithPath:(NSString*)path
{
	if((self = [super init])){
		data = [[NSMutableDictionary alloc]init];
		
		db = [[CharacterDatabase alloc]initWithPath:[path stringByAppendingString:@"/database.sqlite"]];
		portrait = [[NSImage alloc]initWithContentsOfFile:[path stringByAppendingString:@"/portrait.jpg"]];
		
		BOOL rc = [self parseCharacterXml:path];
		if(!rc){
			NSLog(@"Failed to parse character sheet");
		}
		/*if there are no XML sheets in path, then the character cannot be created*/
	}
	
	return self;
}

#pragma mark methods

-(BOOL) charSheetError
{
	return error[CHAR_ERROR_CHARSHEET];
}

-(BOOL) trainingSheetError
{
	return error[CHAR_ERROR_TRAININGSHEET];
}

-(NSString*) charSheetErrorMessage
{
	return errorMessage[CHAR_ERROR_CHARSHEET];
}

-(NSString*) trainingSheetErrorMessage
{
	return errorMessage[CHAR_ERROR_TRAININGSHEET];
}

-(NSInteger) skillsAtV
{
	return [st skillsAtV];
}

-(NSInteger) skillPointTotal
{
	return [st skillPointTotal];
}

-(NSInteger) skillsKnown
{
	return [st skillCount];
}

-(NSString*) stringForKey:(NSString*)key
{
	if(data == nil){
		NSLog(@"data is nil for character %@",characterName);
		return nil;
	}
	return [data valueForKey:key];
}

-(NSInteger) integerForKey:(NSString*)key
{
	if(data == nil){
		NSLog(@"data is nil for character %@",characterName);
		return -1;
	}
	return [[self stringForKey:key]integerValue];
}

-(NSInteger) trainingTimeInSeconds:(NSInteger)primary secondary:(NSInteger)secondary skillPoints:(NSInteger)skillPoints
{
	CGFloat spPerSecond = (((attributeTotals[primary]) + ((attributeTotals[secondary]) / 2.0)) / 60.0);
	return (NSInteger) (skillPoints / spPerSecond);
}

-(NSInteger) trainingTimeInSeconds:(NSNumber*)typeID fromLevel:(NSInteger)fromLevel toLevel:(NSInteger)toLevel
{
	NSInteger time = [self trainingTimeInSeconds:typeID fromLevel:fromLevel toLevel:toLevel accountForTrainingSkill:YES];
	return MAX(time,0);
}

-(NSInteger) trainingTimeInSeconds:(NSNumber*)typeID 
						 fromLevel:(NSInteger)fromLevel 
						   toLevel:(NSInteger)toLevel 
		   accountForTrainingSkill:(BOOL)train
{
	if(toLevel > 5){
		return 0;
	}
	
	Skill *s = [st skillForId:typeID];
	
	NSInteger currentSkillPoints = 0;
	NSInteger skillRank = 0;
	NSInteger primaryAttr = 0;
	NSInteger secondaryAttr = 0;
	
	if(s == nil){
		/*character does not have this skill.*/
		SkillTree *masterSt = [[GlobalData sharedInstance]skillTree];
		Skill *ms = [masterSt skillForId:typeID];
		skillRank = [ms skillRank];
		primaryAttr = [ms primaryAttr];
		secondaryAttr = [ms secondaryAttr];
	}else{
		currentSkillPoints = [s skillPoints];
		skillRank = [s skillRank];
		primaryAttr = [s primaryAttr];
		secondaryAttr = [s secondaryAttr];
	}
	
	NSInteger skillPointDifference = 0;

	/*
		if we are training from the current level;
		calculate the training time to get from the current level to the next, as it may have been partially trained
	 */
	
	if(fromLevel == [s skillLevel]){
		/*
			get the characters total number of skill points, subtract it for the total number of skill points for that level.
		 
			TODO: this is shit, fix it later.
		*/
		if(train && [self isTraining] && ([self integerForKey:CHAR_TRAINING_TYPEID] == [typeID integerValue]) ){
			//if([self getIntegerForKey:CHAR_TRAINING_TYPEID] == [typeID integerValue]){
				NSInteger totalForLevel = totalSkillPointsForLevel(fromLevel,skillRank); //total skill points for the starting level
				NSInteger difference = [self currentSPForTrainingSkill] - totalForLevel; //points we have already trained
				skillPointDifference = (skillPointsForLevel(fromLevel+1,skillRank) - difference);
				fromLevel++;
		}else{
			NSInteger totalForLevel = totalSkillPointsForLevel(fromLevel,skillRank); //total skill points for the starting level
			NSInteger difference = currentSkillPoints - totalForLevel; //points we have already trained
			skillPointDifference = skillPointsForLevel(fromLevel+1,skillRank) - difference;
			fromLevel++;
		}
	}	
	
	/*given a skill and the level we want to train it to, determine the number of seconds that it will take*/	
	for(NSInteger i = fromLevel; i < toLevel; i++){
		skillPointDifference += skillPointsForLevel(i+1,skillRank);
	}
	
	return [self trainingTimeInSeconds:primaryAttr secondary:secondaryAttr skillPoints:skillPointDifference];
}

-(NSInteger) spPerHour:(NSInteger)primary secondary:(NSInteger)secondary
{
	return (NSInteger) (((attributeTotals[primary]) + ((attributeTotals[secondary]) / 2.0)) * 60.0);
}

-(NSInteger) spPerHour
{
	NSInteger sphr = 0;
	if([self integerForKey:CHAR_TRAINING_SKILLTRAINING] != 0){
		NSInteger typeId = [self integerForKey:CHAR_TRAINING_TYPEID];
		Skill *s = [[[GlobalData sharedInstance]skillTree] skillForIdInteger:typeId];
		sphr = [self spPerHour:[s primaryAttr] secondary:[s secondaryAttr]];
	}
	return sphr;
}

-(NSInteger) skillPlanCount
{
	return [skillPlans count];
}

-(SkillPlan*) skillPlanAtIndex:(NSInteger)index
{
	return [skillPlans objectAtIndex:index];
}

-(SkillPlan*) skillPlanById:(NSInteger)planId
{
	for(SkillPlan *plan in skillPlans){
		if([plan planId] == planId){
			return plan;
		}
	}
	return nil;
}

-(void) removeSkillPlan:(SkillPlan*)plan
{
	if(![db deleteSkillPlan:plan]){
		NSLog(@"Failed to delete plan from database");
		return;
	}
	[skillPlans removeObject:plan];
}

-(void) removeSkillPlanById:(NSInteger)planId
{
	[self removeSkillPlan:[self skillPlanById:planId]];
}

-(void) removeSkillPlanAtIndex:(NSInteger)index
{
	SkillPlan *sp = [skillPlans objectAtIndex:index];
	[self removeSkillPlan:sp];
}

-(BOOL) addSkillPlan:(SkillPlan*)plan
{
	NSString *newPlanName = [plan planName];
	/*enforce plan name uniqueness*/
	for(SkillPlan *sp in skillPlans){
		if([[sp planName] isEqualToString:newPlanName]){
			NSLog(@"Could not add skill to plan");
			return NO;
		}
	}
	[skillPlans addObject:plan];
	//[db writeSkillPlan:plan];
	return YES;
}

-(SkillPlan*) createSkillPlan:(NSString*)planName
{
	SkillPlan *plan = [db createPlan:planName forCharacter:self];
	
	if(plan == nil){
		return nil;
	}
	
	[self addSkillPlan:plan];
	
	return plan;
}

-(void) updateSkillPlan:(SkillPlan*)plan
{
	/*check that the skill plan belongs to this character*/
	if([skillPlans indexOfObject:plan] == NSNotFound){
		NSLog(@"Error: attempting to save a skill plan that does not belong to this character");
		return;
	}
	
	[db writeSkillPlan:plan];
}

-(NSString*) getAttributeString:(NSInteger)attr
{
	return [NSString stringWithFormat:@"%2.2f",(double)attributeTotals[attr]];
}

-(NSDictionary*) skillSet
{
	return [st skillSet];
}

/*in practice this is only used from say level 1->2 2->3 etc*/
-(CGFloat) percentCompleted:(NSNumber*)typeID fromLevel:(NSInteger)fromLevel toLevel:(NSInteger)toLevel
{
	Skill *s = [st skillForId:typeID];
	if(s == nil){
		return 0.0;
	}
	
	NSInteger startPoints = totalSkillPointsForLevel(fromLevel,[s skillRank]);
	NSInteger finishPoints = totalSkillPointsForLevel(toLevel,[s skillRank]);
	
	NSInteger currentPoints = [s skillPoints];
	
	if([self isTraining]){
		SkillPair *pair = [self currentlyTrainingSkill];
		if([[pair typeID]isEqualToNumber:typeID]){
			if([pair skillLevel] >= fromLevel){
				currentPoints = [self currentSPForTrainingSkill];
			}
		}
	}
	
	if(startPoints > currentPoints){
		return 0.0;
	}
	
	return (((CGFloat)(currentPoints - startPoints) / (CGFloat)(finishPoints - startPoints)));
	
	/*given the start and finish skill point targets, find what percentage we have completed*/
}

-(void) resetTempAttrBonus
{
	memset(tempBonuses,0,sizeof(tempBonuses));
	learningBonus = 0;
}

-(void) modifyAttribute:(NSInteger)attribute  byLevel:(NSInteger) level
{
	tempBonuses[attribute] += level;
}

-(void) modifyLearning:(NSInteger)level
{
	learningBonus += level;
}

/*perform the final total*/
-(void)processAttributeSkills
{
	for(NSInteger i = 0; i < ATTR_TOTAL; i++){
		attributeTotals[i] = baseAttributes[i] + implantAttributes[i] + learningTotals[i] + tempBonuses[i];
	}
	
	/*Learning. type 3374. +2% per level to all skills*/
	NSInteger level = [[st skillForIdInteger:3374] skillLevel];
	CGFloat bonus = (1.0+(0.02 * (level + learningBonus)));
	
	for(NSInteger i = 0;i < ATTR_TOTAL; i++){
		attributeTotals[i] *= bonus;
	}
}

-(NSInteger) currentSPForTrainingSkill
{
	/*get the start time, the finish time, start SP and calculate the current progress*/
	NSInteger startSP = [self integerForKey:CHAR_TRAINING_STARTSP];
	NSString *startTime = [NSString stringWithFormat:@"%@ +0000",[self stringForKey:CHAR_TRAINING_START]];
	NSDate *startDate = [NSDate dateWithString:startTime];
	
	NSTimeInterval difference = [startDate timeIntervalSinceNow];//number of seconds since we started training
	
	/*now, get the current time, SP/hr and calculate the current SP.*/
	NSInteger sphr = [self spPerHour];
	
	return (((CGFloat)-difference / 3600.0) * sphr) + startSP;
}

-(BOOL) isTraining
{
	return ![[data objectForKey:CHAR_TRAINING_SKILLTRAINING]isEqualToString:@"0"];
}

-(NSNumber*)trainingSkill
{
	if(trainingSkill == nil){
		trainingSkill = [[NSNumber numberWithInteger:[self integerForKey:CHAR_TRAINING_TYPEID]]retain];
	}
	return trainingSkill;
}


-(SkillPair*) currentlyTrainingSkill
{
	SkillPair *pair = [[SkillPair alloc]initWithSkill:
					   [NSNumber numberWithInteger:[[data objectForKey:CHAR_TRAINING_TYPEID]integerValue]]
											 level:[[data objectForKey:CHAR_TRAINING_LEVEL]integerValue]];
	[pair autorelease];
	return pair;
}

-(NSDate*) skillTrainingFinishDate
{
	NSDate *date = [NSDate dateWithString:[[data objectForKey:CHAR_TRAINING_END]stringByAppendingString:@" +0000"]];
	return date;
}

-(NSInteger) skillTrainingFinishSeconds
{
	NSInteger toLevel = [self integerForKey:CHAR_TRAINING_LEVEL];
	
	return [self trainingTimeInSeconds:[self trainingSkill] 
							 fromLevel:toLevel - 1
							   toLevel:toLevel];
}


@end

