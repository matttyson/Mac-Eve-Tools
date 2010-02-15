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
/*
	Generic preprocessor macros for use throughout the project
 */

/*
 These are the keys for the values stored in the NSMutableDictionary in the Character object
 */

#define TAG_PLUS_BUTTON 0
#define TAG_MINUS_BUTTON 1

#define CHAR_ID @"characterID"
#define CHAR_NAME @"name"
#define CHAR_RACE @"race"
#define CHAR_BLOODLINE @"bloodLine"
#define CHAR_GENDER @"gender"
#define CHAR_CORP_NAME @"corporationName"
#define CHAR_CORP_ID @"corporationID"
#define CHAR_CLONE_NAME @"cloneName"
#define CHAR_CLONE_SP @"cloneSkillPoints"
#define CHAR_BALANCE @"balance"

#define CHAR_TRAINING_END @"trainingEndTime"
#define CHAR_TRAINING_START @"trainingStartTime"
#define CHAR_TRAINING_TYPEID @"trainingTypeID"
#define CHAR_TRAINING_STARTSP @"trainingStartSP"
#define CHAR_TRAINING_ENDSP @"trainingDestinationSP"
#define CHAR_TRAINING_LEVEL @"trainingToLevel"
#define CHAR_TRAINING_SKILLTRAINING @"skillInTraining" 
/*SKILLTRAINING will be @"1" if a skill is training, @"0" if not training*/

#define CHAR_ERROR_CHARSHEET 0
#define CHAR_ERROR_TRAININGSHEET 1
#define CHAR_ERROR_QUEUE 2
//total error sheets
#define CHAR_ERROR_TOTAL 3

/*Attribute macros*/

enum AttributeType {
	attr_intelligence,
	attr_memory,
	attr_charisma,
	attr_perception,
	attr_willpower
};

#define ATTR_INTELLIGENCE 0
#define ATTR_INTELLIGENCE_STR @"intelligence"
#define ATTR_INTELLIGENCE_STR_UPPER @"Intelligence"
#define ATTR_MEMORY 1
#define ATTR_MEMORY_STR @"memory"
#define ATTR_MEMORY_STR_UPPER @"Memory"
#define ATTR_CHARISMA 2
#define ATTR_CHARISMA_STR @"charisma"
#define ATTR_CHARISMA_STR_UPPER @"Charisma"
#define ATTR_PERCEPTION 3
#define ATTR_PERCEPTION_STR @"perception"
#define ATTR_PERCEPTION_STR_UPPER @"Perception"
#define ATTR_WILLPOWER 4
#define ATTR_WILLPOWER_STR @"willpower"
#define ATTR_WILLPOWER_STR_UPPER @"Willpower"

#define ATTR_TOTAL 5

/* Views for the main window */
#define VIEW_CHARSHEET 0
#define VIEW_UPDATE 1
#define VIEW_SKILLPLAN 2


/*table column headers that the SkillTree delegate will respond to*/
#define COL_SKILL_NAME @"SKILL"
#define COL_SKILL_RANK @"RANK"
#define COL_SKILL_POINTS @"POINTS"
#define COL_SKILL_CURLEVEL @"LEVEL"
/*table column identifiers for the skill overview*/
#define COL_POV_NAME @"NAME"
#define COL_POV_SKILLCOUNT @"SKILLCOUNT"
#define COL_POV_TIMELEFT @"TIMELEFT"


/*colums the skill plan view will respond to*/
#define COL_PLAN_CALSTART @"CALSTART"
#define COL_PLAN_CALFINISH @"CALFINISH"
#define COL_PLAN_PERCENT @"%"
#define COL_PLAN_SKILLNAME @"SKILLNAME"
#define COL_PLAN_SPHR @"SPHR"
#define COL_PLAN_TRAINING_TIME @"TRAININGTIME"
#define COL_PLAN_TRAINING_TTD @"TIMETODATE"
#define COL_PLAN_BUTTONS @"BUTTONS"


/*XML Documents we are interested in downloading*/
#define XMLAPI_CHAR_SHEET @"/char/CharacterSheet.xml.aspx"
#define XMLAPI_CHAR_LIST @"/account/Characters.xml.aspx"
#define XMLAPI_CHAR_TRAINING @"/char/SkillInTraining.xml.aspx"
#define XMLAPI_CHAR_QUEUE @"/char/SkillQueue.xml.aspx"
#define XMLAPI_SKILL_TREE @"/eve/SkillTree.xml.aspx"
#define XMLAPI_WALLET_REF @"/eve/RefTypes.xml.aspx"
#define XMLAPI_SERVER_STATUS @"/server/ServerStatus.xml.aspx"
#define XMLAPI_CERT_TREE @"/eve/CertificateTree.xml.aspx"

/*the portrait will be saved to this file in the characters directory*/
#define PORTRAIT @"portrait.jpg"

#define MIN_DAY 1440
#define MIN_HOUR 60
#define MIN_MINUTE 1

#define SEC_DAY 86400
#define SEC_HOUR 3600
#define SEC_MINUTE 60

#define MTSkillPairPBoardType @"MTSkillPairPBoardType"
#define MTSkillArrayPBoardType @"MTSkillArrayPBoardType"

#define MTSkillIndexPBoardType @"MTSkillIndexPBoardType"

#define DRAG_TYPEID @"typeid"
#define DRAG_SKILLLEVEL @"level"

#define DRAG_SKILLINDEX @"skillindex"

/*Skill details pop up window*/
#define SD_LEVEL @"TT_LEVEL"
#define SD_TIME @"TT_TIME"
#define SD_TOTAL @"TT_RUN_TOTAL"
#define SD_FROM_NOW @"TT_FROM_NOW"
#define SD_SP_LEVEL @"TT_SP_LEVEL"
#define SD_SP_DIFF @"TT_SP_DIFF"

#define SD_PREREQUISITE @"SD_PRE"

#define GROUP_LEARNING 267

#define SKILL_LEARNING 3374
#define SKILL_MEMORY 3377



/*bonuses*/

#define BONUS_LEARNING @"learningBonus"
#define BONUS_INTELLIGENCE @"intelligenceBonus"
#define BONUS_CHARISMA @"charismaBonus"
#define BONUS_PERCEPTION @"perceptionBonus"
#define BONUS_WILLPOWER @"willpowerBonus"
#define BONUS_MEMORY @"memoryBonus"

/*Notifications*/

#define NOTE_DATABASE_DOWNLOAD_COMPLETE @"databaseDownloadCompleted"

/*
 the character sheet has finished updating. skill plans may or may not have
 been purged
 */
#define CHARACTER_SHEET_UPDATE_NOTIFICATION @"MTCharacterSheetDidUpdate"

#define SERVER_STATUS_NOTIFICATION @"MTServerStatusNotification"

#define CHARACTER_SKILL_PLAN_PURGED @"MTSkillPlanPurged"

/*CCP Database*/

#define DB_CATEGORY_SHIP 6
#define DB_CATEGORY_MODULE 7
#define DB_CATEGORY_CHARGE 8
#define DB_CATEGORY_SKILL 16

/* Translation Columns */

#define TRN_TYPE_DESCRIPTION 33
#define TRN_TYPE_NAME 8
#define TRN_GROUP_NAME 7

#define TRN_CRTCRT_DESCRIPTION 107
#define TRN_CRTCLS_NAME 106
#define TRN_CRTCAT_NAME 105


/*NSUserDefault keys*/
#define SKILL_PLAN_CONFIG @"skill_plan_config"
#define UD_DATABASE_LANG @"ud_db_lang"

enum CCPRace
{
	NullRace = 0,
	Caldari = 1,
	Minmatar = 2,
	Amarr = 4,
	Gallente = 8,
	Jove = 16,
	Pirate = 32
};
typedef enum CCPRace CCPRace;

enum CCPMetaGroup
{
	NullType = 0,
	TechI = 1,
	TechII = 2,
	Storyline = 3,
	Faction = 4,
	Officer = 5,
	Deadspace = 6,
	Frigates = 7,
	EliteFrigates = 8,
	Commander = 9,
	Destroyer = 10,
	Cruiser = 11,
	EliteCruiser = 12,
	CommanderCruiser = 13,
	TechIII = 14
};
typedef enum CCPMetaGroup CCPMetaGroup;


enum ServerStatus
{
	ServerUp,
	ServerDown,
	ServerUnknown,
	ServerStarting
};
typedef enum ServerStatus ServerStatus;

enum StatusImageState
{
	StatusGreen,
	StatusRed,
	StatusGray,
	StatusYellow,
	StatusHidden
};
typedef enum StatusImageState StatusImageState;

enum ImageSize
{
	_16 = 16,
	_32 = 32,
	_64 = 64,
	_128 = 128,
	_256 = 256
};
typedef enum ImageSize ImageSize;

enum AttributeTypeGroups
{
	Drones = 1,
	Structure = 2,
	Armour = 3, 
	Shield = 4,
	Cap = 5,
	Targeting = 6,
	Propulsion = 7,
	Other = 8,
	Fitting = 9
};
typedef enum AttributeTypeGroups AttributeTypeGroups;


/*Don't fuck with these values unless you're special*/
enum DatabaseLanguage
{
	l_EN = 0,
	l_DE = 1,
	l_RU = 2
};
typedef enum DatabaseLanguage DatabaseLanguage;
/*
 macros for sqlite. we use NSIntegers which are defined as longs and therefore change size depending on what platform we are building for
 may need to look at changing this if we ever store anything that could go > MAX_INT. but nothing does at the moment (14/6/09)
 */
#ifdef __LP64__
#define sqlite3_column_nsint(x,y) sqlite3_column_int64((x),(y))
#define sqlite3_bind_nsint(x,y,z) sqlite3_bind_int64((x),(y),(z))
#else
#define sqlite3_column_nsint(x,y) sqlite3_column_int((x),(y))
#define sqlite3_bind_nsint(x,y,z) sqlite3_bind_int((x),(y),(z))
#endif

/*
 macro hackery for 32 bit platforms
 
 CGFloat is a float on 32 bit platforms, and double on 64 bit platforms
 
 floating point constants follow the same rule, these macros wrap to the
 proper function call for the type we are currently building for, to avoid
 compiler complaints.
 */

#ifdef __LP64__
#define xround(x) round((x))
#define xfloor(x) floor((x))
#define xceil(x) ceil((x))
#define xlround(x) lround((x))
#else
#define xround(x) roundf((x))
#define xfloor(x) floorf((x))
#define xceil(x) ceilf((x))
#define xlround(x) lroundf((x))
#endif

///http://api.eve-online.com/char/CharacterSheet.xml.aspx?userID=<userid>&apiKey=<apikey>&characterID=<characterID>
///http://api.eve-online.com/char/CharacterSheet.xml.aspx?userID=<userid>&apiKey=<apikey>&characterID=<characterID>
