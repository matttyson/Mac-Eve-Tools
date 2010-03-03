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

@class Skill;
@class Character;

@class SkillDetailsPointsDatasource;
@class SkillDetailsTrainingTimeDatasource;
@class SkillPrerequisiteDatasource;

@interface SkillDetailsWindowController : NSWindowController 
{
	IBOutlet NSTextField *skillName;
	IBOutlet NSTextField *skillRank;
	IBOutlet NSTextField *skillGroup;
	IBOutlet NSTextField *skillPrimaryAttr;
	IBOutlet NSTextField *skillSecondaryAttr;
	
	IBOutlet NSTextField *pilotLevel;
	IBOutlet NSTextField *pilotPoints;
	IBOutlet NSTextField *pilotTimeToLevel;
	IBOutlet NSTextField *pilotTrainingRate;
	
	IBOutlet NSTabView *tabView;
	
	IBOutlet NSTextField *skillDescription;
	IBOutlet NSOutlineView *skillPrerequisites;
	IBOutlet NSTableView *skillPoints;
	IBOutlet NSTableView *skillTrainingTimes;
	
	SkillDetailsPointsDatasource *skillPointsDs;
	SkillDetailsTrainingTimeDatasource *skillTrainDs;
	SkillPrerequisiteDatasource *skillPreDs;
	
	Skill *skill;
	Character *character;
}
/*
@property (readwrite,retain,nonatomic) Skill* skill;
@property (readwrite,retain,nonatomic) Character *character;
*/

+(void) displayWindowForTypeID:(NSNumber*)s forCharacter:(Character*)c;
+(void) displayWindowForSkill:(Skill*)s forCharacter:(Character*)c;

//-(void) setSkill:(Skill*)s forCharacter:(Character*)c;

@end
