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

#import "XmlFetcher.h"
#import "Config.h"

#pragma mark XmlFetcher delegate methods

@interface  XmlFetcher (XmlFetcherDelegates)

/*internal delegate methods*/
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

- (void)finishedCleanup;
- (BOOL) writeData:(NSData*)data toFile:(NSString*)file;
@end

#pragma mark -

@implementation XmlFetcher (XmlFetcherDelegates)

-(void)finishedCleanup
{
	if(xmlData != nil){
		[xmlData release];
		xmlData = nil;
	}
	
	if(docName != nil){
		[docName release];
		docName = nil;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"Received Response");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[xmlData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Conection failed with error %@!",[error localizedDescription]);
	
	[delegate xmlDidFailWithError:error xmlPath:savePath xmlDocName:docName];
	[delegate xmlDocumentFinished:NO xmlPath:nil xmlDocName:docName];
	
	[self finishedCleanup];
	[connection autorelease];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	BOOL rc = NO;
	
	NSLog(@"Validating (%@)",savePath);
	if([delegate xmlValidateData:xmlData xmlPath:savePath xmlDocName:docName]){
		rc = [self writeData:xmlData toFile:savePath];
		NSLog(@"Writing (%@)",savePath);
	}else{
		NSLog(@"Validation failed (%@)",savePath);
	}
	[delegate xmlDocumentFinished:rc xmlPath:savePath xmlDocName:docName];
	
	[self finishedCleanup];
	[connection autorelease];
}

-(BOOL) writeData:(NSData*)data toFile:(NSString*)file
{
	/*Test the whole path exsits, if it does not, create the directory*/
	NSFileManager *fm = [NSFileManager defaultManager];
	if(! [fm fileExistsAtPath:[file stringByDeletingLastPathComponent] isDirectory:nil]){
		if(![fm createDirectoryAtPath:[file stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil]){
			NSLog(@"Could not create directory %@",[file stringByDeletingLastPathComponent]);
		}else{
			NSLog(@"Created directory %@",[file stringByDeletingLastPathComponent]);
		}
	}
	
	/*write the data to the file*/
	BOOL rc = [data writeToFile:file atomically:NO];
	
	if(!rc){
		NSLog(@"Failed to write XML document %@",file);
	}else{
		NSLog(@"Wrote %d bytes to %@",[data length],file);
	}
	
	return rc;
}

@end


#pragma mark XmlFetcher

@implementation XmlFetcher

-(void) dealloc
{
	[self finishedCleanup];
	[super dealloc];
}

-(XmlFetcher*) init
{
	if(self = [super init]){
		
	}
	
	return self;
}

-(XmlFetcher*) initWithDelegate:(id <XmlFetcherDelegate>)del
{
	if([self init])
	{
		delegate = del;
	}
	return self;
}


-(void) saveXmlDocument:(NSString*)fullDocUrl docName:(NSString*)name savePath:(NSString*)path runLoopMode:(NSString*)mode
{
	docName = [name retain];
	savePath = [path retain];
	
	xmlData = [[NSMutableData alloc]init];
	
	//NSLog(@"Requesting URL %@",fullDocUrl);
	
	NSURLRequest *apiRequest = [NSURLRequest requestWithURL: [ NSURL URLWithString: fullDocUrl]
												cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
	
	NSURLConnection *apiConnection = [[NSURLConnection alloc] initWithRequest:apiRequest delegate:self startImmediately:NO];
	
	[apiConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
	[apiConnection start];
}


-(void) saveXmlDocument:(NSString*)fullDocUrl docName:(NSString*)name savePath:(NSString*)path;
{
	[self saveXmlDocument:fullDocUrl docName:name savePath:path runLoopMode:NSDefaultRunLoopMode];
}

-(void) setDelegate:(id <XmlFetcherDelegate>)del
{
	delegate = del;
}

/*syncronous method*/
-(BOOL) saveXmlDocument:(NSString*)fullDocUrl savePath:(NSString*)path
{
	NSData *data;
	NSMutableURLRequest *request;
	NSError *err = nil;
	NSURLResponse *resp = nil;
	
	request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:fullDocUrl]];
	[request autorelease];
	
	data = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
	
	if(err != nil){
		NSLog(@"Error downloading (%@) %@",fullDocUrl,[err localizedDescription]);
		return NO;
	}
	
	[self writeData:data toFile:path];
	
	return YES;
}

@end
