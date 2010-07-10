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

#import "XMLDownloadOperation.h"


@implementation XMLDownloadOperation

@synthesize xmlDoc;
@synthesize xmlDocUrl;


-(BOOL) downloadXmlData:(NSString*)fullDocUrl
{
	NSError *error = nil;
	NSURLResponse *response = nil;
	
	NSURL *url = [NSURL URLWithString:fullDocUrl];
	
	NSURLRequest *request = [[[NSURLRequest alloc]initWithURL:url]autorelease];
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	NSLog(@"Downloading %@",url);
	
	if(data == nil){
		NSLog(@"Error downloading %@.  %@",fullDocUrl,[error description]);
		xmlDownloadError = [error retain];
		return NO;
	}
	
	xmlData = [data retain];
	
	return YES;
}

/*
 xmlData pointer must not be nil
 write the XML document to the pending directory.
 */
-(BOOL) writeXmlDocument:(NSString*)savePath
{
	//NSFileManager *fm = [NSFileManager defaultManager];
	
	BOOL rc = [xmlData writeToFile:savePath atomically:NO];
	
	if(!rc){
		NSLog(@"Failed to write XML document %@",savePath);
	}else{
		NSLog(@"Wrote %u bytes to %@",[xmlData length], savePath);
	}
	
	return rc;
}

-(void) main
{
	BOOL rc;
	
	rc = [self downloadXmlData:xmlDocUrl];
	
	if(!rc){
		NSLog(@"Downloading error");
		return;
	}
	
	NSString *fileName = [xmlDoc lastPathComponent];
	NSString *filePath = [[self pendingDirectory]stringByAppendingFormat:@"/%@",fileName];
	
	rc = [self writeXmlDocument:filePath];
}

-(void) dealloc
{
	[xmlData release];
	
	if(xmlDownloadError != nil){
		[xmlDownloadError release];
	}
	
	[xmlDoc release];
	
	[super dealloc];
}

@end
