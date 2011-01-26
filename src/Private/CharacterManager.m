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

#import "CharacterManager.h"
#import "Config.h"
#import "Account.h"
#import "Character.h"
#import "CharacterTemplate.h"
#import "MTCharacterOverviewCell.h"
#import "Skill.h"
#import "SkillPlan.h"
#import "GlobalData.h"
#import "macros.h"
#import "Helpers.h"

#import <assert.h>

#import "XMLDownloadOperation.h"
#import "XMLParseOperation.h"
#import "GenericDownloadOperation.h"

@implementation CharacterManager



-(void) dealloc
{
	[templateArray release];
	[sortedArray release];
	[characterDictionary release];
	[super dealloc];
}

-(CharacterManager*) init
{
	if((self = [super init])){
		templateArray = [[NSMutableArray alloc]init];
		sortedArray = nil;
		characterDictionary = nil;
	}
	return self;
}

//Download the character portrait.
-(NSOperation*) buildPortraitOperation:(CharacterTemplate*)template
{
	NSString *pictureUrl = [NSString stringWithFormat:@"%@%@_256.jpg",
							[[NSUserDefaults standardUserDefaults] stringForKey:UD_PICTURE_URL],
							[template characterId]];
	
	GenericDownloadOperation *op;
	
	op = [[[GenericDownloadOperation alloc]init]autorelease];
	
	[op setUrlPath:pictureUrl];
	
	NSString *saveFile = [Config charDirectoryPath:[template accountId]
										 character:[template characterId]];
	saveFile = [saveFile stringByAppendingString:@"/portrait.jpg"];
	
	[op setSavePath:saveFile];
	
	return op;
}

/*
	Builds a download operation object for a character, given the
	XML page to fetch (see macros.h)
 */
-(NSOperation*) buildOperation:(CharacterTemplate*)template 
								docPath:(NSString*)docPath
{
	
	NSString *apiUrl = [Config getApiUrl:docPath
							   accountID:[template accountId] 
								  apiKey:[template apiKey]
								  charId:[template characterId]];
	
	NSString *characterDir = [Config charDirectoryPath:[template accountId] 
											 character:[template characterId]];
	
	XMLDownloadOperation *op;
	
	op = [[[XMLDownloadOperation alloc]init]autorelease];
	[op setXmlDocUrl:apiUrl];
	[op setCharacterDirectory:characterDir];
	
	[op setXmlDoc:docPath];
			
	return op;
}

/*
	returns an array of NSOperation objects for a character
	update procedure.
 */
-(NSArray*) updateOperationObjects:(CharacterTemplate*)template parseOperation:(XMLParseOperation*)opParse
{	
	NSOperation *opSheet, *opTrain, *opQueue;
	NSOperation *opPortrait = nil;
	
	// create the NSOperations, add them to the queue.	
	NSString *characterDir = [Config charDirectoryPath:[template accountId] character:[template characterId]];
	
	NSString *pendingDir = [characterDir stringByAppendingString:@"/pending"];
	
	//create the output directory, the XMLParseOperation will clean it up
	NSFileManager *fm = [NSFileManager defaultManager];
	if(! [fm fileExistsAtPath:pendingDir isDirectory:nil]){
		if(![fm createDirectoryAtPath: pendingDir
		  withIntermediateDirectories:YES attributes:nil error:nil]){
			NSLog(@"Could not create directory %@",pendingDir);
			return nil;
		}else{
			NSLog(@"Created directory %@",pendingDir);
		}
	}
	
	opSheet = [self buildOperation:template docPath:XMLAPI_CHAR_SHEET];
	opTrain = [self buildOperation:template docPath:XMLAPI_CHAR_TRAINING];
	opQueue = [self buildOperation:template docPath:XMLAPI_CHAR_QUEUE];
	
	/*If the portrait does not exist, redownload it.*/
	if(![fm fileExistsAtPath:[characterDir stringByAppendingString:@"/portrait.jpg"]]){
		opPortrait = [self buildPortraitOperation:template];
	}
	
	[opParse addDependency:opSheet]; //THIS MUST BE THE FIRST DEPENDENCY.
	[opParse addCharacterDir:characterDir forSheet:XMLAPI_CHAR_SHEET];
	
	[opParse addDependency:opTrain]; //THIS MUST BE THE SECOND DEPENDENCY.
	[opParse addCharacterDir:characterDir forSheet:XMLAPI_CHAR_TRAINING];
	
	[opParse addDependency:opQueue]; //THIS MUST BE THE THIRD DEPENDENCY.
	[opParse addCharacterDir:characterDir forSheet:XMLAPI_CHAR_QUEUE];
	
		
	NSArray *operationArray;
	if(opPortrait != nil){
		operationArray = [NSArray arrayWithObjects:opPortrait,opSheet,opTrain,opQueue,nil];
	}else{
		operationArray = [NSArray arrayWithObjects:opSheet,opTrain,opQueue,nil];	
	}
	 	
	return operationArray;
}

/*Check to see if the character has been downloaded yet*/
-(BOOL) testCharacterDirectory:(NSString*)directory
{
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if(![fm fileExistsAtPath:directory]){
		//Character directory does not exist. need to download that character.
		return NO;
	}
	
	//Test for files within that directory.
	NSString *filePath;
	filePath = [directory stringByAppendingFormat:@"/%@",[XMLAPI_CHAR_SHEET lastPathComponent]];
	if(![fm fileExistsAtPath:filePath]){
		//Character sheet does not exist.  return NO and begin update procedure.
		return NO;
	}
	
	return YES;
}


/*
 given a template object, read a character off disk.
 */
-(Character*) loadCharacter:(CharacterTemplate*)template
{
	NSString *path = [Config charDirectoryPath:[template accountId] character:[template characterId]];
	
	if(![self testCharacterDirectory:path]){
		return nil;
	}
	
	Character *c = [[[Character alloc]initWithPath:path]autorelease];
	
	return c;
}


-(Character*) buildCharacterAtIndex:(NSInteger)index
{	
	CharacterTemplate *template = [templateArray objectAtIndex:index];
	
	Character *c = [self loadCharacter:template];
	
	return c;
}


-(void) buildCharacterDict
{
	/*
	 build the character dictionary from the template array
	 requires all the characters to be downloaded and good to go.
	*/
	
	for(CharacterTemplate *template in templateArray){
		Character *c = [self loadCharacter:template];
		NSNumber *cId = [NSNumber numberWithInteger:[[template characterId]integerValue]];
		[characterDictionary setObject:c forKey:cId];
	}
}


/*
 delegate called when the batch update of all characters is done.
 Called by the BatchParseOperation object.
 Notify that the update operation has been completed.
 
 Object is an NSArray of error strings.  NIL if there are no errors
 */
-(void) batchUpdateOperationDone:(id)del errors:(NSArray*)errorArray
{
	[self buildCharacterDict];
	
	NSLog(@"Finished downloading characters");
	if(sortedArray != nil){
		[sortedArray release];
	}
	sortedArray = nil;
	
	if(del != nil){
		if([del respondsToSelector:@selector(batchUpdateOperationDone:)]){
			[del performSelector:@selector(batchUpdateOperationDone:) 
						   withObject:errorArray];
		}
	}
}

-(void) updateTemplateArray:(NSArray*)templates delegate:(id)del
{
	NSOperationQueue *queue = [[NSOperationQueue alloc]init];
	[queue setMaxConcurrentOperationCount:3];
	
	//This object will calll the delegate function.
	
	XMLParseOperation *opParse = [[XMLParseOperation alloc]init];
	
	[opParse setDelegate:self];
	[opParse setCallback:@selector(batchUpdateOperationDone:errors:)];
	[opParse setObject:del];
	
	for(CharacterTemplate *template in templates){
		NSArray *ary = [self updateOperationObjects:template parseOperation:opParse];
		[queue addOperations:ary waitUntilFinished:NO];
	}
	[queue addOperation:opParse];
	
	[opParse release];
	[queue release];
}


/*
	This will update all the templates on disk, and signal when done.
 */
-(void) updateAllCharacters:(id)del
{
	[self updateTemplateArray:templateArray delegate:del];
}

/*
 returns YES if all characters are on disk. delegate will NOT be called
 returns NO if characters need to be downloaded. delegate WILL be called.
 */
-(BOOL)setTemplateArray:(NSArray*)tarray delegate:(id)del
{
	if(templateArray != nil){
		[templateArray release];
	}
	templateArray = [tarray retain];
		
	NSInteger i = 0;
	BOOL rc = NO;
	NSMutableDictionary *charDict = [[NSMutableDictionary alloc]init];
	NSMutableArray *charsToDownload = nil;
	
	//for each template element in the array, load it up and make a character object.
	
	for(CharacterTemplate *template in templateArray){
		NSString *path = [Config charDirectoryPath:[template accountId] character:[template characterId]];
		
		/*
			Test that all the XML files exist.
			If they do not, we will need to fetch them.
		*/
		
		if(![self testCharacterDirectory:path]){
			if(charsToDownload == nil){
				charsToDownload = [[NSMutableArray alloc]init];
				rc = YES;
			}
			//Character has not yet been downloaded.
			//Download this character.  We will need to signal when done.
			[charsToDownload addObject:template];
		}else{
			if([template primary]){
				defaultCharacter = i;
			}
			
			Character *c = [self loadCharacter:template];
			NSNumber *cId = [NSNumber numberWithInteger:[[template characterId]integerValue]];
			[charDict setObject:c forKey:cId];			
		}
		i++;
	}
	
	if(charsToDownload != nil){
		[self updateTemplateArray:charsToDownload delegate:del];
		[charsToDownload release];
	}
	
	if(characterDictionary != nil){
		[characterDictionary release];
	}
	characterDictionary = charDict;
	
	/*reset the cached character objects. they will be refreshed later*/
	if(sortedArray != nil){
		[sortedArray release];
		sortedArray = nil;
	}
	
	return rc;
}

-(Character*) defaultCharacter;
{
	for(CharacterTemplate *t in templateArray){
		if([t primary]){
			if(characterDictionary != nil){
				return [characterDictionary objectForKey:
						[NSNumber numberWithInteger:[[t characterId] integerValue]]];
			}
			return [self loadCharacter:t];
		}
	}
	
	/*fallback, find the first active character*/
	
	NSLog(@"Primary character not set, finding first active");
	
	for(CharacterTemplate *t in templateArray){
		if([t active]){
			if(characterDictionary != nil){
				return [characterDictionary objectForKey:
						[NSNumber numberWithInteger:[[t characterId] integerValue]]];
			}
			return [self loadCharacter:t];
		}
	}
	
	return nil;
}

-(Character*) characterById:(NSUInteger)characterId
{
	if([self characterCount] > 0){
		for(Character *character in sortedArray){
			if([character characterId] == characterId){
				return character;
			}
		}
	}
	NSLog(@"Character %lu not found",characterId);
	return nil;
}

-(Character*) currentCharacter
{
	return nil;
}

-(NSInteger) characterCount
{
	if(characterDictionary == nil){
		return 0;
	}
	
	if(sortedArray == nil){
		/*write code to sort according to some order.*/
		sortedArray = [[characterDictionary allValues]retain];
	}
	
	return [sortedArray count];
}

-(Character*) characterAtIndex:(NSInteger)index
{
	if(sortedArray == nil){
		return nil;
	}
	return [sortedArray objectAtIndex:index];
}

-(NSArray*)allCharacters
{
	return [characterDictionary allValues];
}

-(void) deletePortrait
{
/*
	Character *c = [self characterAtIndex:currentCharacter];
	
	//NSString *path = [Config charDirectoryPath:[temp :[template characterId]];
	path = [path stringByAppendingFormat:@"/portrait.jpg"];
	
	if(![[NSFileManager defaultManager]fileExistsAtPath:path]){
		return;
	}
	
	NSLog(@"Deleting portrait %@",path);
	
	[[NSFileManager defaultManager]removeItemAtPath:path error:NULL];

	[NSAlert alertWithMessageText:NSLocalizedString(@"Portrait will be refetched on character update",) 
					defaultButton:NSLocalizedString(@"OK",)
				  alternateButton:nil
					  otherButton:nil
		informativeTextWithFormat:nil];
*/
}

#pragma mark Outlineview methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [self characterCount];
}

- (id)tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(NSInteger)rowIndex
{
	/*the work is done in the willDisplayCell delegate*/
	return nil;
}


/*delegate methods*/

- (void)tableView:(NSTableView *)aTableView 
  willDisplayCell:(id)aCell 
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(NSInteger)rowIndex
{
	if(rowIndex > [sortedArray count]){
		assert(0);
	}
	
	MTCharacterOverviewCell *cell = (MTCharacterOverviewCell*)aCell;
	Character *c = [sortedArray objectAtIndex:rowIndex];
	
	[cell setPortrait:[c portrait]];
	[cell setCharName:[c characterName]];
	
	[cell setSkillPoints:[c skillPointTotal]];
	[cell setIsk:[NSDecimalNumber decimalNumberWithString:[c stringForKey:CHAR_BALANCE]]];
	
	if([c integerForKey:CHAR_TRAINING_SKILLTRAINING] != 0){
		[cell setIsTraining:YES];
		
		SkillPlan *plan = [c trainingQueue];
		
		//The string for the skill in training
		NSString *typeID = [c stringForKey:CHAR_TRAINING_TYPEID];
		NSNumber *key = [NSNumber numberWithInteger:[typeID integerValue]];
		Skill *s = [[[GlobalData sharedInstance]skillTree] skillForId:key];
		NSString *romanLevel = romanForInteger([c integerForKey:CHAR_TRAINING_LEVEL]);
		NSString *training = [NSString stringWithFormat:@"%@ %@",[s skillName],romanLevel];
		[cell setSkillName:training];
		
		[cell setFinishDate:[plan planFinishDate]];
		[cell setQueueLength:[plan skillCount]];
		
		[cell setSkillTimeLeft:[c skillTrainingFinishSeconds]];
		[cell setQueueTimeLeft:[plan trainingTime]];
	}else{
		[cell setIsTraining:NO];
	}
	
}

- (BOOL)tableView:(NSTableView *)aTableView 
shouldEditTableColumn:(NSTableColumn *)aTableColumn 
			  row:(NSInteger)rowIndex
{
	return NO;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSInteger row = [[aNotification object]selectedRow];
	if(row == -1){
		return;
	}
	
	currentCharacter = row;
}


@end
