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

#import "SkillTree.h"
#import "Account.h"
#import "macros.h"

@interface Config : NSObject {
	NSString *programName;
	
		//NSString *rootPath; /*Root path to save data to*/
		
	NSMutableArray *accounts; /*a list of Account* objects*/
	
	//remove this. push into GlobalData structure
	//NSDateFormatter *dateFormatter; -> removed
		
}

@property (retain) NSMutableArray* accounts;

+(Config*) sharedInstance;


/*
	Construct a URL with the required API keys to get a XML page for a character.
	xmlPage should be in the form of @"/foo/bar.xml".  see macros.h for the page macros
 */
+(NSString*) getApiUrl:(NSString*)xmlPage 
			 accountID:(NSString*)accountId 
				apiKey:(NSString*)apiKey 
				charId:(NSString*)characterId;


/*
	Supply the final xml file name, and all the subpath components as variable arguments
 eg
	getFilePath:XMLAPI_CHAR_SHEET,"foo","bar",nil;
 
 will generate the path
 /Users/username/Library/Application Data/EveApi/foo/bar/CharacterSheet.xml.aspx
 
 (the /char/ will be stripped off the XMLAPI_CHAR_SHEET string)
 
 the last parameter MUST be nil or BAD THINGS will happen
 */
+(NSString*) filePath:(NSString*)xmpApiFile, ...;

/*this will return the base directory for a particular character*/
+(NSString*) charDirectoryPath:(NSString*)accountId character:(NSString*)characterId;

+(NSString*) buildPathSingle:(NSString*)file;


/*returns the array index*/
-(NSInteger) addAccount:(Account*)acct;
-(BOOL) removeAccount:(Account*)acct;
-(BOOL) clearAccounts;

/*YES if all the required files exist*/
-(BOOL) requisiteFilesExist;

/*save the config out to disk*/
-(BOOL) saveConfig;
/*read it back in*/
-(BOOL) readConfig;

//-(NSString*) itemDBFallbackPath;

/*return a list of all the active characters  (CharacterTemplate)*/
-(NSArray*) activeCharacters;




/*functions for ship and icon graphics*/

-(NSString*) pathForImageType:(NSInteger)typeID;
-(NSString*) urlForImageType:(NSInteger)typeID;

-(enum DatabaseLanguage) dbLanguage;
-(void) setDbLanguage:(enum DatabaseLanguage)lang;

@end
