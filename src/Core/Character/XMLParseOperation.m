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

#import "Character.h"
#import "CharacterPrivate.h"

#import "XMLParseOperation.h"
#import "XMLDownloadOperation.h"

#import "XmlHelpers.h"

#import "UpdateError.h"

#include <libxml/tree.h>

@interface XMLParsePair : NSObject
{
	NSString *xmlSheet;
	NSString *characterDir;
}

@property (readwrite,nonatomic,retain) NSString* xmlSheet;
@property (readwrite,nonatomic,retain) NSString* characterDir;

@end

@implementation XMLParsePair

@synthesize xmlSheet;
@synthesize characterDir;

-(id)init
{
	if((self = [super init])){
		xmlSheet = nil;
		characterDir = nil;
	}
	return self;
}

-(void)dealloc
{
	[xmlSheet release];
	[characterDir release];
	[super dealloc];
}

@end




@implementation XMLParseOperation

@synthesize delegate;
@synthesize callback;
@synthesize object;

-(id)init
{
	if(self = [super init]){
		xmlFiles = [[NSMutableArray alloc]init];
		//delegate = nil;
		//object = nil;
	}
	return self;
}

-(void)dealloc
{
	[xmlFiles release];
	[super dealloc];
}

-(void) addCharacterDir:(NSString*)characterDir forSheet:(NSString*)xmlSheet
{
	XMLParsePair *pair = [[XMLParsePair alloc]init];
	[pair setCharacterDir:characterDir];
	[pair setXmlSheet:xmlSheet];
	
	[xmlFiles addObject:pair];
	[pair release];
}


-(BOOL) didXmlSheetError:(NSString*)xmlSheet
{
	xmlDoc *doc;
	xmlNode *root_node;
	xmlNode *result;
	BOOL rc = YES;
	
	doc = xmlReadFile([xmlSheet fileSystemRepresentation],NULL,0);
	if(doc == NULL){
		NSLog(@"Error: could not read %@",xmlSheet);
		return NO;
	}
	
	root_node = xmlDocGetRootElement(doc);
	if(root_node == NULL){
		xmlFreeDoc(doc);
		NSLog(@"No root element for document %@",xmlSheet);
		return NO;
	}
	
	result = findChildNode(root_node,(xmlChar*)"result");
	if(result == NULL){
		xmlNode *xmlErrorMessage = findChildNode(root_node,(xmlChar*)"error");
		if(xmlErrorMessage != NULL){
			NSString *errorString = getNodeText(xmlErrorMessage);
			NSString *errorNum = findAttribute(xmlErrorMessage,(xmlChar*)"code");
			/*
			UpdateError *error = [[UpdateError alloc]initWithError:[errorNum integerValue]
														   message:errorString 
													  forCharacter:
			*/
			NSLog(@"EVE XML error: %@",errorString);
		}		
		rc = NO;
	}
	xmlFreeDoc(doc);
	return rc;
}

-(BOOL) validateXmlFile:(NSString*)xmlDocFile
{
	if(![[NSFileManager defaultManager] fileExistsAtPath:xmlDocFile]){
		NSLog(@"%@ does not exist. cannot process",xmlDocFile);
		return NO;
	}

	/*now we need to parse it to see if it errored*/
	BOOL isXmlValid = [self didXmlSheetError:xmlDocFile];
	if(!isXmlValid){
		NSLog(@"Validation for %@ failed!",xmlDocFile);
		return NO;
	}
	
	return YES; //XML file is valid
}

// Also run in the main thread.
-(void) charUpdateProcedureIsFinished:(NSNumber*)boolval
{
	/*
	 This used to work differently in the old character updating scheme.
	 Now it should notifiy the character manager to say that there were errors
	 validating the sheets.
	 */
	BOOL rc = [boolval boolValue];
	
	
}

-(void)main
{
	/*
	 Open up the Pending directory
	 verify an XML file
	 move it to the parent directory
	 
	 this is not quite perfect, as it assumes that CharacterSheet.xml.aspx was downloaded every time.
	 
	 rewrite this to use the SAX parser, it will probably be faster?
	 worry about it later.
	 */
	
	NSFileManager *manager = [NSFileManager defaultManager];
	
	for(XMLParsePair *pair in xmlFiles){
		NSString *charDir = [pair characterDir];
		NSString *pendingDir = [charDir stringByAppendingString:@"/pending"];
		NSString *sheet = [pair xmlSheet];
		
		NSString *pendingFile = [pendingDir stringByAppendingFormat:@"/%@",[sheet lastPathComponent]];
		BOOL isValid = [self validateXmlFile:pendingFile];
		
		if(!isValid){
			NSLog(@"Failed to validate %@",pendingFile);
			/*
			Failed to validate this particular XML file. don't process it
			This should extract the type of error (file does not exist, XML api server error)
			and return an error message to the user.
			 
			 Save them up in an error array and and pass it off to the user in the callback.
			*/
		}else{
			/*
			 File is valid.
			 Move the pending file into the character directory.
			 */
			NSString *fileName = [sheet lastPathComponent];
			NSString *fromDir = [pendingDir stringByAppendingFormat:@"/%@",fileName];
			NSString *toDir = [charDir stringByAppendingFormat:@"/%@",fileName];
			NSError *error = nil;
			
			if([manager fileExistsAtPath:toDir]){
				if(![manager removeItemAtPath:toDir error:&error]){
					NSLog(@"ERROR: Failed to remove %@ (%@)",toDir,[error localizedDescription]);
				}
			}
			
			if(![manager moveItemAtPath:fromDir toPath:toDir error:&error]){
				NSLog(@"ERROR: Failed to move %@! (%@)",fileName,[error localizedDescription]);
			}
			
			NSLog(@"Validated %@",pendingFile);
		}
	}
	
	for(XMLParsePair *pair in xmlFiles){
		//Remove all the pending directories, and their contents.
		NSError *error = nil;
		NSString *pendingDir = [[pair characterDir] stringByAppendingString:@"/pending"];
		if([manager fileExistsAtPath:pendingDir]){
			if(![manager removeItemAtPath:pendingDir error:&error]){
				NSLog(@"Failed to delete '%@' (%@)",pendingDir,[error localizedDescription]);
			}
		}
	}
	
	/*
	 All update operations are complete, notifiy the delegate that operations are done and
	 if there are erros, this method must block until completion so the data can be passed
	 to the delegate safely
	 */
	if(delegate != nil){
		if([delegate respondsToSelector:callback]){
			/*notify on done, pass through the error array when i get it done.*/
			[self performSelectorOnMainThread:@selector(callDelegate:)
									   withObject:nil //error array
									waitUntilDone:YES];
		}
	}
	
}

-(void) callDelegate:(NSArray*)errorArray
{
	/*call the delegate function on the main thread*/
	[delegate performSelector:callback
				   withObject:object
				   withObject:errorArray];
}

@end
