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


@interface Skill : NSObject <NSCopying> {
	NSString *skillName;
	NSString *skillDescription;
	NSInteger skillRank;
	
	/*
		Details for a skill if it belongs to a character
	 */
	NSInteger skillLevel;	
	NSInteger skillPoints; //Skill points the character has in this skill, not skill points for the level.
	
	NSInteger primaryAttr;
	NSInteger secondaryAttr;
	
	NSMutableArray *skillPrereqs;
	
	/*internal references*/
	NSNumber* typeID; /*typeID is the unique skill identifier*/
	NSNumber* groupID; /*groupID is the skill group that this skill belongs to*/
	NSDictionary *bonuses;
}

-(Skill*) initWithDetails:(NSString*)name group:(NSNumber*)skillGroupID type:(NSNumber*)skillTypeID;

-(NSComparisonResult) sortByName:(Skill*)skill;

-(NSArray*) prerequisites;
-(void) addPrerequiste:(NSNumber*)skillTypeID level:(NSInteger)level;

-(NSString*) description;

-(NSInteger) skillPointsForLevel:(NSInteger)level;
-(NSInteger) totalSkillPointsForLevel:(NSInteger)level;

-(void) addBonus:(NSString*)bonusName bonusValue:(NSString*)value;
-(NSString*) getBonus:(NSString*)bonusName;

-(CGFloat) percentCompleted:(NSInteger)fromLevel toLevel:(NSInteger)toLevel;

@property (readonly, nonatomic) NSString* skillName;
@property (readonly, nonatomic) NSNumber* typeID;
@property (readonly, nonatomic) NSNumber* groupID;

@property (readwrite, retain, nonatomic) NSString* skillDescription;
@property (readwrite, assign, nonatomic) NSInteger skillRank;
@property (readwrite, assign, nonatomic) NSInteger skillLevel;
@property (readwrite, assign, nonatomic) NSInteger skillPoints;

@property (readwrite, assign, nonatomic) NSInteger primaryAttr;
@property (readwrite, assign, nonatomic) NSInteger secondaryAttr;


@end
