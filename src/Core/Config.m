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

@synthesize autoUpdate;
@synthesize batchUpdateCharacters;
@synthesize startupRefresh;
@synthesize submitSystemInformation;
@synthesize updateFeedUrl;
@synthesize dbUpdateUrl;
@synthesize dbSQLUrl;
@synthesize rootPath;
@synthesize picurl;
@synthesize itemDBPath;
@synthesize accounts;
@synthesize imageUrl;
@synthesize databaseMinimumVersion;

static Config *cfg = nil;

-(Config*)privateInit
{
	return [super init];
}

-(id) init
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

+(Config*) sharedInstance
{
	if(cfg == nil)
	{
		cfg = [[Config alloc]privateInit];
		cfg->apiurl = @"http://api.eve-online.com";
		cfg->picurl = @"http://img.eve.is/serv.asp?s=256"; //append &c=charID to get the avatar picture
		cfg->rootPath = [[@"~/Library/Application Support/MacEveApi" stringByExpandingTildeInPath]retain];
		cfg->itemDBPath = [[cfg->rootPath stringByAppendingFormat:@"/database.sqlite"] retain];
		
		cfg->accounts = [[NSMutableArray alloc]init]; /*array of Account objects */
		
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
		cfg->dateFormatter = [[NSDateFormatter alloc]init];
		
		[cfg->dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[cfg->dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		
		cfg->autoUpdate = NO;
		cfg->submitSystemInformation = NO;
		cfg->batchUpdateCharacters = NO;
		
		cfg->updateFeedUrl = @"http://mtyson.id.au/MacEveApi-appcast.xml";
		cfg->dbUpdateUrl = @"http://www.mtyson.id.au/MacEveApi/MacEveApi-database.xml";
		cfg->dbSQLUrl = @"http://www.mtyson.id.au/MacEveApi/database.sql.bz2";
		cfg->imageUrl = @"http://www.mtyson.id.au/MacEveApi/images";//images for icons etc.
		
		cfg->databaseMinimumVersion = 2;
	}
	//not a leak.
	return cfg;
}

/*
-(NSString*) itemDBFallbackPath
{
	return [NSString stringWithFormat:@"%@/database.sqlite",cfg->rootPath];
}
 */

-(void) setSubmitSystemInformation:(BOOL)status
{
	submitSystemInformation = status;
#ifdef HAVE_SPARKLE
	[[SUUpdater sharedUpdater]setSendsSystemProfile:status];
#endif
}

+(NSString*) getApiUrl:(NSString*)xmlPage 
			 accountID:(NSString*)accountId 
				apiKey:(NSString*)apiKey 
				charId:(NSString*)characterId
{
	NSMutableString *str = [[[NSMutableString alloc]init]autorelease];
	
	[str appendFormat:@"%@%@",cfg->apiurl,xmlPage];
	if(accountId && apiKey){
		[str appendFormat:@"?userID=%@&apiKey=%@",accountId,apiKey];
		if(characterId){
			[str appendFormat:@"&characterID=%@",characterId];
		}
	}
	
//	NSLog(@"Generated URL (%@)",str);
	
	return str;
	
}


-(NSString*) getSavePath
{
	return rootPath;
}

+(NSString*) charDirectoryPath:(NSString*)accountId character:(NSString*)characterId
{
	return [NSString stringWithFormat:@"%@/%@/%@",cfg->rootPath,accountId,characterId];
}

/*
	the last parameter MUST be nil
 */
+(NSString*) filePath:(NSString*)xmlApiFile, ...
{
	NSString *str;
	va_list argList;
	NSMutableString *result = [[[NSMutableString alloc]initWithString:cfg->rootPath]autorelease];
	
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
	Config *cfg = [Config sharedInstance];
	return [NSString stringWithFormat:@"%@/%@",[cfg rootPath],file];
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

/*
 read the program config file off disk.
 note that the error checking in here is not very agressive. an XML file with junk in it will
 probably cause a crash.
 */
-(BOOL) readConfig
{
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
		[accounts release];
		accounts = [[NSMutableArray alloc]init];
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
		
		[acct setApiKey:apiKey];
		[acct setAccountID:accountId];
		[acct setAccountName:acctName];
		
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
			
			NSString *charId = findAttribute(charNode,(xmlChar*)"characterID");
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
		cfg->autoUpdate = [self readBoolElement:element];
	}
	
	/*submit usage information*/
	element = findChildNode(root,(xmlChar*)"submitStatistics");
	if(element != NULL){
		[cfg setSubmitSystemInformation:[self readBoolElement:element]];
	}
	
	element = findChildNode(root,(xmlChar*)"batchUpdateCharacters");
	if(element != NULL){
		[cfg setBatchUpdateCharacters:[self readBoolElement:element]];
	}
	
	xmlFreeDoc(doc);
	
	return YES;
}

-(BOOL) saveConfig
{
	xmlDoc *doc;
	xmlNode *node;
	xmlNode *root;
	
	doc = xmlNewDoc((xmlChar*)"1.0");
	
	root = xmlNewNode(NULL,(xmlChar*)"MacEveApi");
	xmlNewProp(root,(xmlChar*)"version",(xmlChar*)"1.0");
	xmlDocSetRootElement(doc, root);
	
	/*rowset of accounts*/
	node = xmlNewChild(root,NULL,(xmlChar*)"rowset",NULL);
	xmlNewProp(node,(xmlChar*)"name",(xmlChar*)"accounts");
	xmlNewProp(node,(xmlChar*)"key",(xmlChar*)"accountID");
	xmlNewProp(node,(xmlChar*)"columns",(xmlChar*)"accountID,apiKey,name");
	
	/*write out each account as a child of the accounts rowset*/
	for(Account *acct in accounts){
		xmlNode *acctNode = xmlNewChild(node,NULL,(xmlChar*)"row",NULL);
		xmlNewPropString(acctNode,(xmlChar*)"accountID",[acct accountID]);
		xmlNewPropString(acctNode,(xmlChar*)"apiKey",[acct apiKey]);
		xmlNewPropString(acctNode,(xmlChar*)"name",[acct accountName]);
		
		/*Write out the character rowset*/
		xmlNode *charRowset = xmlNewChild(acctNode,NULL,(xmlChar*)"rowset",NULL);
		xmlNewProp(charRowset,(xmlChar*)"name",(xmlChar*)"characters");
		xmlNewProp(charRowset,(xmlChar*)"key",(xmlChar*)"characterID");
		xmlNewProp(charRowset,(xmlChar*)"columns",(xmlChar*)"characterID,characterName,primary,active");
		
		/*write out all the characters for this account*/
		for(CharacterTemplate *template in [acct characters]){
			xmlNode *charNode = xmlNewChild(charRowset,NULL,(xmlChar*)"row",NULL);
			
			xmlNewProp(charNode,(xmlChar*)"characterID",(xmlChar*)[[template characterId]UTF8String]);
			xmlNewProp(charNode,(xmlChar*)"characterName",(xmlChar*)[[template characterName]UTF8String]);
			
			xmlNewProp(charNode,(xmlChar*)"primary",[template primary] ? (xmlChar*)"yes" : (xmlChar*)"no");
			xmlNewProp(charNode,(xmlChar*)"active",[template active] ? (xmlChar*)"yes" :(xmlChar*)"no");
		}
	}
	
	xmlNewChild(root,NULL, (xmlChar*)"autoupdate",cfg->autoUpdate ? (xmlChar*)"yes" : (xmlChar*)"no");
	xmlNewChild(root,NULL, (xmlChar*)"submitStatistics",cfg->submitSystemInformation ? (xmlChar*)"yes" : (xmlChar*)"no");
	xmlNewChild(root,NULL, (xmlChar*)"batchUpdateCharacters",cfg->batchUpdateCharacters ? (xmlChar*)"yes" : (xmlChar*)"no");
	
	NSString *path = [Config filePath:@"EveApiConfig.xml",nil];
	
	if(!xmlSaveFormatFileEnc([path fileSystemRepresentation], doc, "UTF-8", XML_CHAR_ENCODING_UTF8)){
		NSLog(@"Failed to write config to (%@)",path);
	}
	
	xmlFreeDoc(doc);
	
	return YES;
}

-(NSInteger) databaseVersion
{
	NSString *path = [self itemDBPath];
	
	if(![[NSFileManager defaultManager]fileExistsAtPath:path]){
		return 0;
	}
	
	CCPDatabase *db = [[CCPDatabase alloc]initWithPath:path];
	
	NSInteger version = [db dbVersion];
	
	[db release];
	
	return version;

}

-(BOOL) databaseUpToDate
{
	NSInteger version = [self databaseVersion];
	
	if(version >= [self databaseMinimumVersion]){
		return YES;
	}
	
	return NO;
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
	for(Account *a in accounts){
		if([[a accountName]isEqualToString:acctName]){
			return -1;
		}
	}
	
	[accounts addObject:acct];
	return [accounts count]-1;
}

-(BOOL) removeAccount:(Account*)acct
{
	NSString *acctName = [acct accountName];
	/*iterate through the list of accounts and find one with that name and remove it.*/
	for(Account *acct in cfg->accounts){
		if([[acct accountName]isEqualToString:acctName]){
			/*found the account. remove it*/
			[cfg->accounts removeObject:acct];
			return YES;
		}
	}
	return NO;
}

-(NSString*) formatDate:(NSDate*)date
{
	return [dateFormatter stringFromDate:date];
}

-(NSArray*) activeCharacters
{
	NSMutableArray *ary = [[[NSMutableArray alloc]init]autorelease];
	
	for(Account *acct in [self accounts]){
		for(CharacterTemplate *template in [acct characters]){
			if([template active]){
				[ary addObject:template];
			}
		}
	}
	
	return ary;
}

-(NSString*) pathForImageType:(NSInteger)typeID
{
	NSMutableString *url = [NSString stringWithFormat:@"%@/images/types/256_256/%ld.png",rootPath,typeID];
	
	return url;
}

-(NSString*) urlForImageType:(NSInteger)typeID
{
	NSMutableString *url = [NSMutableString stringWithString:imageUrl];
	
	[url appendFormat:@"/types/256_256/%ld.png",typeID];
	
	return url;
}

-(NSString*) urlForIcon:(NSString*)icon size:(enum ImageSize)size
{
	NSMutableString *url = [NSString stringWithString:imageUrl];
	
	[url appendFormat:@"/icons/%d_%d/%s.png",(int)size,(int)size,icon];
	
	return url;
}


@end

