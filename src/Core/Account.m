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

#import "Account.h"
#import "Config.h"
#import "XmlFetcher.h"
#import "XmlHelpers.h"
#import "Character.h"
#import "CharacterTemplate.h"

#import <libxml/parser.h>
#import <libxml/tree.h>


@interface Account (AccountPrivate) <XmlFetcherDelegate>
-(void) xmlDocumentFinished:(BOOL)status xmlPath:(NSString*)path xmlDocName:(NSString*)docName;

-(void) downloadXml;

-(NSString*)savePath;

-(BOOL) parseXmlDocument:(xmlDoc*) doc;
-(BOOL) loadXmlDocument;

@end

@implementation Account (AccountPrivate)

/*Generate the save path*/
-(NSString*)savePath
{
	NSString *str = [Config filePath:XMLAPI_CHAR_LIST,accountID,nil];
	return str;
}

-(BOOL) parseXmlDocument:(xmlDoc*)doc
{
	xmlNode *root = xmlDocGetRootElement(doc);
	if(root == NULL){
		NSLog(@"error parsing XML document");
		return NO;
	}
	xmlNode *result = findChildNode(root,(xmlChar*)"result");
	if(result == NULL){
		NSLog(@"error parsing XML document");
		return NO;
	}
	xmlNode *rowset = findChildNode(result,(xmlChar*)"rowset");
	if(rowset == NULL){
		NSLog(@"error parsing XML document");
		return NO;
	}
	
	[self.characters removeAllObjects];
	
	for(xmlNode *cur_node = rowset->children;
		cur_node != NULL;
		cur_node = cur_node->next)
	{
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		NSString *name = findAttribute(cur_node,(xmlChar*)"name");
		NSString *characterID = findAttribute(cur_node,(xmlChar*)"characterID");
		
		CharacterTemplate *template;
		template = [[CharacterTemplate alloc]
					initWithDetails:name 
					accountId:self.accountID
					apiKey:self.apiKey 
					charId:characterID 
					active:NO 
					primary:NO];
		
		[characters addObject:template];
		[template release];

	}
	
	return YES;
}

-(void) downloadXml:(BOOL)modalDelegate
{
	XmlFetcher *f = [[XmlFetcher alloc]initWithDelegate:self];
	
	NSString *apiUrl = [Config getApiUrl:XMLAPI_CHAR_LIST 
							   accountID:self.accountID 
								  apiKey:self.apiKey
								  charId:nil];
	
	if(modalDelegate){
		[f saveXmlDocument:apiUrl
				   docName:XMLAPI_CHAR_LIST
				  savePath:[self savePath]
			   runLoopMode:NSModalPanelRunLoopMode];
		
	}else{
		[f saveXmlDocument:apiUrl
			   docName:XMLAPI_CHAR_LIST
			  savePath:[self savePath]];
	}
	[f release];	
}

-(void) downloadXml
{
	[self downloadXml:NO];
}

-(BOOL)loadXmlDocument
{
	xmlDoc *doc = xmlReadFile([[self savePath] fileSystemRepresentation],NULL, 0);	
	
	if(doc == NULL){
		NSLog(@"Failed to read %@",[self savePath]);
		return NO;
	}
	
	BOOL rc = [self parseXmlDocument:doc];
	
	xmlFreeDoc(doc);
	
	return rc;
}

-(void) xmlDocumentFinished:(BOOL)status xmlPath:(NSString*)path xmlDocName:(NSString*)docName
{
	if(status == NO){
		NSLog(@"Failed to download %@ to %@",docName,path);
		[delegate accountDidUpdate:self didSucceed:NO];
		return;
	}
	
	BOOL rc = [self loadXmlDocument];
	
	[delegate accountDidUpdate:self didSucceed:rc];
}

-(BOOL) xmlValidateData:(NSData*)xmlData xmlPath:(NSString*)path xmlDocName:(NSString*)docName
{
	BOOL rc = YES;
	const char *bytes = [xmlData bytes];
	
	xmlDoc *doc = xmlReadMemory(bytes,(int)[xmlData length], NULL, NULL, 0);
	
	xmlNode *root_node = xmlDocGetRootElement(doc);
	xmlNode *result = findChildNode(root_node,(xmlChar*)"error");
	
	if(result != NULL){
		NSLog(@"%@",getNodeText(result));
		rc = NO;
	}
	
	xmlFreeDoc(doc);
	return rc;
}

-(void) xmlDidFailWithError:(NSError*)xmlErrorMessage xmlPath:(NSString*)path xmlDocName:(NSString*)docName
{
	NSLog(@"Connection failed! (%@)",[xmlErrorMessage localizedDescription]);
	
	NSRunAlertPanel(@"Error Account XML",[xmlErrorMessage localizedDescription],@"Close",nil,nil);
}

@end



@implementation Account

@synthesize accountID;
@synthesize apiKey;
@synthesize accountName;
@synthesize characters;


-(void) addCharacter:(CharacterTemplate*)template
{
	[self.characters addObject:template];
}


-(CharacterTemplate*) findCharacter:(NSString*)charName
{
	for(CharacterTemplate *template in characters){
		if([[template characterName]isEqualToString:charName]){
			return template;
		}
	}
	return nil;
}

-(void) loadAccount:(id<AccountUpdateDelegate>)del runForModalWindow:(BOOL)modal
{
	delegate = del;
	[self downloadXml:modal];
}

-(void)loadAccount:(id<AccountUpdateDelegate>)del
{
#ifdef MACEVEAPI_DEBUG
	[self loadAccount:del runForModalWindow:NO];
#else
	[self loadAccount:del runForModalWindow:YES];	
#endif
}

-(NSInteger)characterCount
{
	if(self.characters != nil){
		return [self.characters count];
	}
	return 0;
}

-(void) fetchCharacters:(id<AccountUpdateDelegate>)del
{
	delegate = del;
	[self downloadXml];
}

-(void) dealloc
{
	[self.accountID release];
	[self.apiKey release];
	[self.characters release];
	[self.accountName release];
	[super dealloc];
}

-(Account*) init
{
	if(self = [super init]){
		self.characters = [[[NSMutableArray alloc] init] autorelease];
	}
	return self;
}

-(Account*) initWithDetails:(NSString*)acctID acctKey:(NSString*)key
{
	if([self init]){
		self.accountID = [acctID retain];
		self.apiKey = [key retain];
	}
	
	return self;
}

-(Account*) initWithName:(NSString*)name
{
	if([self init]){
		self.accountName = name;
	}
	return self;
}

/*

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	NSLog(@"found %ld chars",[characters count]);
	return [characters count];
}

- (id)tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSInteger)rowIndex
{
	CharacterTemplate *template = [characters objectAtIndex:rowIndex];
	
	if([[aTableColumn identifier]isEqualToString:@"NAME"]){
		return [template characterName];
	}if([[aTableColumn identifier]isEqualToString:@"ACTIVE"]){
		BOOL active = [template active];
		
		if(active){
			return [NSNumber numberWithInteger:NSOnState];
		}else{
			return [NSNumber numberWithInteger:NSOffState];
		}
	}
	return nil;
}
*/

#pragma mark -
#pragma mark NSCoding protocol
- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self != nil) {
		self.accountName = [aDecoder decodeObjectForKey:@"accountName"];
		self.accountID = [aDecoder decodeObjectForKey:@"accountID"];
		self.apiKey = [aDecoder decodeObjectForKey:@"apiKey"];
		self.characters = [aDecoder decodeObjectForKey:@"characters"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.accountName forKey:@"accountName"];
	[aCoder encodeObject:self.accountID forKey:@"accountID"];
	[aCoder encodeObject:self.apiKey forKey:@"apiKey"];
	[aCoder encodeObject:self.characters forKey:@"characters"];
}

@end
