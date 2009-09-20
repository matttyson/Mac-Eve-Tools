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

#import "LoaderController.h"
#import "XmlFetcher.h"
#import "Config.h"
#import "macros.h"

@implementation LoaderController

-(id) initWithWindowNibName:(NSString*)windowNibName
{
	if(self = [super initWithWindowNibName:windowNibName]){
		filesToDownload = [[NSMutableArray alloc]init];
	}
	return self;
}

-(void) dealloc
{
	NSLog(@"Dealloc %@",[self class]);
	[filesToDownload release];
	[super dealloc];
}

-(void) awakeFromNib
{
	[progress setUsesThreadedAnimation:YES];
}

/*
 determine if there is anything that needs updating. if so build up the files and add them to the list.
 
 In a future release this should connect to a website and download the current list of files to grab
 
-(BOOL) checkStatus
{
	
}
 */

-(BOOL) doSomething:(id)ptr
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *file = [Config filePath:XMLAPI_SKILL_TREE,nil];
	
	BOOL rc = YES;
	
	[progress startAnimation:self];
	
	if(![fm fileExistsAtPath:file]){
		XmlFetcher *f = [[XmlFetcher alloc]init];
		NSString *url = [Config getApiUrl:XMLAPI_SKILL_TREE accountID:nil apiKey:nil charId:nil];
		NSLog(@"Downloading %@",url);
		[textActionDescription setStringValue:url];
		[textActionDescription sizeToFit];
		[textActionDescription display];
		rc = [f saveXmlDocument:url savePath:file];
		[f release];
	}
	
	if(!rc){
		NSLog(@"Downloading data failed!");
	}
			
	[progress stopAnimation:self];
	
	return rc;
}

-(void) setTimeout:(NSInteger)timeout
{
	
}

@end
