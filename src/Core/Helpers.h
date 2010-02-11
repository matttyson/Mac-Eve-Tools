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

#include "macros.h"

/*return a roman numeral string for a number. eg @"3" returns @"III" */
NSString* romanForString(NSString *value);
NSString* romanForInteger(NSInteger value);

/*
	these are to convert strings such as "memory" into integers for storage. see
	macros.h for valid values
 */
NSInteger attrCodeForString(NSString *str);
NSString* strForAttrCode(NSInteger code);
NSInteger attrCodeForDBInt(NSInteger dbcode);

BOOL createDirectory(NSString *path);

/*the skill points required for a particular level*/
NSInteger skillPointsForLevel(NSInteger skillLevel, NSInteger skillRank);
/*the total skill points up to a particular level*/
NSInteger totalSkillPointsForLevel(NSInteger skillLevel, NSInteger skillRank);

/*given the number of seconds, return a string describing how long it will take to train*/

enum TrainingTimeFields
{
	TTF_Days = (1 << 1),
	TTF_Hours = (1 << 2),
	TTF_Minutes = (1 << 3),
	TTF_Seconds = (1 << 4),
	TTF_All = 0xFFFFFFFF
};

NSString* stringTrainingTime2(NSInteger trainingTime , enum TrainingTimeFields ttf);
NSString* stringTrainingTime(NSInteger trainingTime);

CGFloat skillPercentCompleted(NSInteger startingPoints, NSInteger finishingPoints, NSInteger currentPoints);

NSString* sqlite3_column_nsstr(void *stmt, int col);

NSString* languageForId(enum DatabaseLanguage lang);
const char* langCodeForId(enum DatabaseLanguage lang);
