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

#import "Helpers.h"
#import "macros.h"
#import <sqlite3.h>
#import <assert.h>

NSString* romanForString(NSString *value)
{
	return romanForInteger([value integerValue]);
}

NSString* romanForInteger(NSInteger value)
{
	switch (value) {
		case 0:
			return @"0";
		case 1:
			return @"I";
		case 2:
			return @"II";
		case 3:
			return @"III";
		case 4:
			return @"IV";
		case 5:
			return @"V";
	}
	return nil;
}

NSInteger attrCodeForString(NSString *str)
{
	if([str isEqualToString:ATTR_INTELLIGENCE_STR]){
		return ATTR_INTELLIGENCE;
	}else if([str isEqualToString: ATTR_MEMORY_STR]){
		return ATTR_MEMORY;
	}else if([str isEqualToString:ATTR_CHARISMA_STR]){
		return ATTR_CHARISMA;
	}else if([str isEqualToString:ATTR_WILLPOWER_STR]){
		return ATTR_WILLPOWER;
	}else if([str isEqualToString:ATTR_PERCEPTION_STR]){
		return ATTR_PERCEPTION;
	}
	assert(0);
	return -1;
}

NSInteger attrCodeForDBInt(NSInteger dbcode)
{
	/*
	 database 
	 164 - charisma
	 165 - intelligence
	 155 - memory
	 167 - perception
	 168 - willpower
	 */
	NSInteger code = 0;
	
	switch (dbcode) {
		case 164:
			code = ATTR_CHARISMA;
			break;
		case 165:
			code = ATTR_INTELLIGENCE;
			break;
		case 166:
			code = ATTR_MEMORY;
			break;
		case 167:
			code = ATTR_PERCEPTION;
			break;
		case 168:
			code = ATTR_WILLPOWER;
			break;
	}
	return code;
}

NSString *strForAttrCode(NSInteger code)
{
	switch(code)
	{
		case ATTR_MEMORY:
			return ATTR_MEMORY_STR_UPPER;
		case ATTR_INTELLIGENCE:
			return ATTR_INTELLIGENCE_STR_UPPER;
		case ATTR_CHARISMA:
			return ATTR_CHARISMA_STR_UPPER;
		case ATTR_WILLPOWER:
			return ATTR_WILLPOWER_STR_UPPER;
		case ATTR_PERCEPTION:
			return ATTR_PERCEPTION_STR_UPPER;
	}
	assert(0);
	return nil;
}

BOOL createDirectory(NSString *path)
{
	BOOL rc = NO;
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if(! [fm fileExistsAtPath:path isDirectory:nil]){
		if(![fm createDirectoryAtPath:path  withIntermediateDirectories:YES attributes:nil error:nil]){
			NSLog(@"Could not create directory %@",path);
		}else{
			NSLog(@"Created directory %@",path);
			rc = YES;
		}
	}
	return rc;
}

static NSInteger sp[] = {0, 250, 1414, 8000, 45255, 256000};

NSInteger skillPointsForLevel(NSInteger skillLevel, NSInteger skillRank)
{
	return (sp[skillLevel] * skillRank) - (sp[skillLevel-1] * skillRank);
}

NSInteger totalSkillPointsForLevel(NSInteger skillLevel, NSInteger skillRank)
{
	return (sp[skillLevel] * skillRank);
}

NSString* stringTrainingTime(NSInteger trainingTime)
{
	return stringTrainingTime2(trainingTime,TTF_Days | TTF_Hours | TTF_Minutes);
}

NSString* stringTrainingTime2(NSInteger trainingTime , enum TrainingTimeFields ttf)
{
	NSMutableString *str = [[[NSMutableString alloc]init]autorelease];
	
	if(trainingTime < 0){
		trainingTime = -trainingTime;
		[str appendString:@"-"];
	}
	
	NSInteger remain, days, hours , min, sec;
	days = trainingTime / SEC_DAY;
	remain = trainingTime - (days * SEC_DAY);
	
	hours = remain / SEC_HOUR;
	remain = remain - (hours * SEC_HOUR);
	
	min = remain / SEC_MINUTE;
	sec = remain - (min * SEC_MINUTE);
	
	if(days > 0 && (ttf & TTF_Days)){
		[str appendFormat:@"%ldd ",days];
	}
	if(hours > 0 && (ttf & TTF_Hours)){
		[str appendFormat:@"%ldh ",hours];
	}
	if(min > 0 && (ttf & TTF_Minutes)){
		[str appendFormat:@"%ldm ",min];
	}
	if(sec > 0 && (ttf & TTF_Seconds)){
		[str appendFormat:@"%lds",sec];
	}
	
	if(!(ttf & TTF_Seconds)){
		return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	}
	
	return str;
}

CGFloat skillPercentCompleted(NSInteger startingPoints, NSInteger finishingPoints, NSInteger currentPoints)
{
	return ((CGFloat)(currentPoints - startingPoints) / (CGFloat)(finishingPoints - startingPoints));
}

NSString* sqlite3_column_nsstr(void *stmt, int col)
{
	const unsigned char *str = sqlite3_column_text(stmt,col);
	if(str == NULL){
		return [NSString stringWithString:@""];
	}else{
		NSString *newString;
		newString = [NSString stringWithUTF8String:(const char*)str];
		if(newString != NULL){
			return newString;
		}
		
		/*for some reason stringWithUTF8String will return null.  attempt ASCII encoding*/
		newString = [NSString stringWithCString:(const char*)str encoding:NSASCIIStringEncoding];
		if(newString != NULL){
			return newString;
		}
		
		newString = [NSString stringWithString:@"If you can see this, then this is a bug. please report it."];
		return newString;
	}
}

NSString* languageForId(enum DatabaseLanguage lang)
{
	NSString *str;
	
	switch(lang){
		case l_EN:
			str = NSLocalizedString(@"English",@"english language");
			break;
		case l_DE:
			str = NSLocalizedString(@"German",@"german language");
			break;
		case l_RU:
			str = NSLocalizedString(@"Russian",@"russian language");
			break;
		default:
			str = NSLocalizedString(@"Invalid selection",@"invalid language choice error message");
			break;
	}
	
	return str;
}

static const char *langCode[] = {NULL,"DE","RU"};

const char* langCodeForId(enum DatabaseLanguage lang)
{
	return langCode[lang];
	/*
	const char *code;
	switch(lang){
		case l_EN:
			code = NULL;
			break;
		case l_DE:
			code = "DE";
			break;
		case l_RU:
			code = "RU";
			break;
		default:
			code = NULL;
			break;
	}	
	return code;
	 */
}
