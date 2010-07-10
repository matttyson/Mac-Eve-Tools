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

#import "Account.h"
#import "Character.h"
#import "XmlHelpers.h"
#import "CharacterTemplate.h"

#import "CCPDatabase.h"

#import <libxml/parser.h>
#import <libxml/tree.h>

#ifdef HAVE_SPARKLE
#import <Sparkle/Sparkle.h>
#endif

@implementation Config

@synthesize accounts;

static Config *sharedSingletonCfg = nil;

-(id) init
{
	self = [super init];
    sharedSingletonCfg = self;
	
    self.accounts = [[NSMutableArray alloc]init]; /*array of Account objects */
	[self readConfig];
	
    return self;
}

+(id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedSingletonCfg == nil) {
            sharedSingletonCfg = [super allocWithZone:zone];
            return sharedSingletonCfg;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

-(id)copyWithZone:(NSZone *)zone {
    return self;
}

-(id)retain {
    return self;
}


-(unsigned long)retainCount {
    return UINT_MAX;  //denotes an object that cannot be release
}


-(void)release {
    //do nothing    
}


-(id)autorelease {
    return self;    
}


+(Config*) sharedInstance
{
	@synchronized(self) {
        if (sharedSingletonCfg == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedSingletonCfg;
}

+(NSString*) getApiUrl:(NSString*)xmlPage 
			 accountID:(NSString*)accountId 
				apiKey:(NSString*)apiKey 
				charId:(NSString*)characterId
{
	NSMutableString *str = [[[NSMutableString alloc]init] autorelease];
	
	
	[str appendFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] stringForKey:UD_API_URL],xmlPage];
	if(accountId && apiKey){
		[str appendFormat:@"?userID=%@&apiKey=%@",accountId,apiKey];
		if(characterId){
			[str appendFormat:@"&characterID=%@",characterId];
		}
	}
	
//	NSLog(@"Generated URL (%@)",str);
	
	return str;
	
}


+(NSString*) charDirectoryPath:(NSString*)accountId character:(NSString*)characterId
{
	return [NSString stringWithFormat:@"%@/%@/%@",[[NSUserDefaults standardUserDefaults] stringForKey:UD_ROOT_PATH],accountId,characterId];
}

/*
	the last parameter MUST be nil
 */
+(NSString*) filePath:(NSString*)xmlApiFile, ...
{
	NSString *str;
	va_list argList;
	NSMutableString *result = [[[NSMutableString alloc]initWithString:[[NSUserDefaults standardUserDefaults] stringForKey:UD_ROOT_PATH]]autorelease];
	
	va_start(argList, xmlApiFile);
	
	while((str = va_arg(argList,NSString*)) != nil){
		[result appendFormat:@"/%@",str];
	}
	
	va_end(argList);
	
	[result appendFormat:@"/%@",[xmlApiFile lastPathComponent]];
	
	//NSLog(@"Generated path (%@)",result);
	
	return result;
}

+(NSString*) buildPathSingle:(NSString*)file
{
	//Config *cfg = [Config sharedInstance];
	return [NSString stringWithFormat:@"%@/%@",[[NSUserDefaults standardUserDefaults] stringForKey:UD_ROOT_PATH],file];
}


/*Generate a save file path for the configuration data*/
-(NSString*) savePath
{
	return [Config filePath:@"EveApiConfig.xml",nil];
}

-(BOOL) readBoolElement:(xmlNode*)node
{
	if(node != NULL){
		NSString *str = getNodeText(node);
		if([str isEqualToString:@"yes"]){
			return YES;
		}
	}
	return NO;
}

- (BOOL) readOldConfigFile {
	xmlDoc *doc;
	xmlNode *root;
	
	NSString *path = [self savePath];
	
	doc = xmlReadFile([path fileSystemRepresentation],NULL,0);
	
	if(doc == NULL){
		NSLog(@"NULL pointer for xmlFileOpen(%@)",path);
		return NO;
	}
	
	root = xmlDocGetRootElement(doc);
	
	if(accounts && [accounts count] > 0){
		[accounts removeAllObjects];
	}
	
	/*root node should be <cfg->progra>*/
	
	xmlNode *accountRowsetNode = findChildNode(root,(xmlChar*)"rowset");
	if(accountRowsetNode == NULL){
		NSLog(@"Could not parse config file");
		xmlFreeDoc(doc);		
		return NO;
	}
	/*should be the <rowset name="accounts"> node here*/
	
	NSString *rowsetName = findAttribute(accountRowsetNode,(xmlChar*)"name");
	if(![rowsetName isEqualToString:@"accounts"]){
		NSLog(@"invalid XML");
		xmlFreeDoc(doc);
		return NO;
	}
	
	/*load all the accounts into the config object*/
	for(xmlNode *accountNode = accountRowsetNode->children;
		accountNode != NULL;
		accountNode = accountNode->next)
	{
		if(accountNode->type != XML_ELEMENT_NODE){
			continue;
		}
		
		/*we have found an account object*/
		Account *acct = [[Account alloc]init];
		NSString *accountId = findAttribute(accountNode,(xmlChar*)"accountID");
		NSString *apiKey = findAttribute(accountNode,(xmlChar*)"apiKey");
		NSString *acctName = findAttribute(accountNode,(xmlChar*)"name");
		
		acct.apiKey = apiKey;
		acct.accountID = accountId;
		acct.accountName = acctName;
		
		/*parse the XML document for this account.*/
		[acct performSelector:@selector(loadXmlDocument)];
		
		/*The account object has been read in*/
		
		xmlNode *charRowsetNode = findChildNode(accountNode,(xmlChar*)"rowset");
		if(charRowsetNode == NULL){
			NSLog(@"Rowset node is null for account %@",acctName);
			[acct release];
			continue;
		}
		/*
		 If a character object is in this section, that means the user has
		 activated it.
		 
		 Add all the characters for this account to the account object
		 */
		for(xmlNode *charNode = charRowsetNode->children;
			charNode != NULL;
			charNode = charNode->next)
		{
			if(charNode->type != XML_ELEMENT_NODE){
				continue;
			}
			
			//NSString *charId = findAttribute(charNode,(xmlChar*)"characterID");
			NSString *charName = findAttribute(charNode,(xmlChar*)"characterName");
			NSString *charPrimary = findAttribute(charNode,(xmlChar*)"primary");
			NSString *charActive = findAttribute(charNode,(xmlChar*)"active");
			
			CharacterTemplate *template = [acct findCharacter:charName];
			if(template != nil){
				[template setActive:[charActive isEqualToString:@"yes"]];
				[template setPrimary:[charPrimary isEqualToString:@"yes"]];
			}
		}
		
		/*add the account object to the array of accounts*/
		[accounts addObject:acct];
		[acct release];
	}
	
	/*check for the auto update flag.*/
	xmlNode *element;
	element = findChildNode(root,(xmlChar*)"autoupdate");
	if(element != NULL){
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[self readBoolElement:element]] forKey:UD_CHECK_FOR_UPDATES];
	}
	
	/*submit usage information*/
	element = findChildNode(root,(xmlChar*)"submitStatistics");
	if(element != NULL){
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[self readBoolElement:element]] forKey:UD_SUBMIT_STATS];
	}
	
	xmlFreeDoc(doc);
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:self.accounts];
	[defaults setObject:archive forKey:UD_ACCOUNTS];
	[defaults synchronize];
	
	[[NSFileManager defaultManager] removeItemAtPath:[self savePath] error:nil];
	
	return YES;
}

/*
 read the program config file off disk.
 note that the error checking in here is not very agressive. an XML file with junk in it will
 probably cause a crash.
 */
-(BOOL) readConfig
{	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self savePath]]) {
		[self readOldConfigFile];
	}
	else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSData *archive = [defaults objectForKey:UD_ACCOUNTS];
		NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
	
	/* clearing mutable array and add new array via add method.. 
	 Init a new Array with the array causes a memory leak
	 releasing the previous list to fix the leak causes 
	 EXC_BAD_ACCESS because somewhere is an access to the old released list*/
		if (self.accounts != NULL) {
			[self.accounts removeAllObjects];
		}
		else {
			self.accounts = [[NSMutableArray alloc] init];
		}
	
		[self.accounts addObjectsFromArray:array];
			
	}
	return YES;
}

-(BOOL) saveConfig
{	
	return YES;
}

-(BOOL) requisiteFilesExist
{
	NSString *path = [Config filePath:XMLAPI_SKILL_TREE,nil];
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if(![fm fileExistsAtPath:path]){
		return NO;
	}

	path = [Config filePath:XMLAPI_CERT_TREE,nil];
	if(![fm fileExistsAtPath:path]){
		return NO;
	}
	
	return YES;
}

-(NSInteger) addAccount:(Account*)acct
{
	/*check to see if the Account object already exists in the array.*/
	NSString *acctName = [acct accountName];
	for(Account *a in self.accounts){
		if([[a accountName]isEqualToString:acctName]){
			return -1;
		}
	}
	
	[self.accounts addObject:acct];
	return [self.accounts count]-1;
}

-(BOOL) removeAccount:(Account*)acct
{
	NSString *acctName = [acct accountName];
	/*iterate through the list of accounts and find one with that name and remove it.*/
	for(Account *acct in self.accounts){
		if([[acct accountName]isEqualToString:acctName]){
			/*found the account. remove it*/
			[self.accounts removeObject:acct];
			return YES;
		}
	}
	return NO;
}

-(BOOL) clearAccounts {
	[self.accounts removeAllObjects];
	
	return TRUE;
}

-(NSArray*) activeCharacters
{
	NSMutableArray *ary = [[[NSMutableArray alloc]init]autorelease];
	
	for(Account *acct in self.accounts){
		for(CharacterTemplate *template in acct.characters){
			if(template.active){
				[ary addObject:template];
			}
		}
	}
	
	return ary;
}

-(NSString*) pathForImageType:(NSInteger)typeID
{
	NSMutableString *url = [NSString stringWithFormat:@"%@/images/types/256_256/%ld.png", [[NSUserDefaults standardUserDefaults] stringForKey:UD_ROOT_PATH],typeID];
	
	return url;
}

-(NSString*) urlForImageType:(NSInteger)typeID
{
	NSMutableString *url = [NSMutableString string];
	
	[url appendFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:UD_IMAGE_URL]];
	[url appendFormat:@"/types/256_256/%ld.png",typeID];
	
	return url;
}

-(NSString*) urlForIcon:(NSString*)icon size:(enum ImageSize)size
{	
	NSMutableString *url = [NSMutableString string];
	
	[url appendFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:UD_IMAGE_URL]];
	[url appendFormat:@"/icons/%d_%d/%s.png",(int)size,(int)size,icon];
	
	return url;
}

-(enum DatabaseLanguage) dbLanguage
{
	/*if no key is set, zero is the default, which is english.*/
	return [[NSUserDefaults standardUserDefaults] integerForKey:UD_DATABASE_LANG];

}
-(void) setDbLanguage:(enum DatabaseLanguage)lang
{
	[[NSUserDefaults standardUserDefaults]setInteger:lang forKey:UD_DATABASE_LANG];
}

@end

