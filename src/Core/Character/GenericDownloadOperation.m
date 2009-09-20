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


#import "GenericDownloadOperation.h"


@implementation GenericDownloadOperation

@synthesize urlPath;
@synthesize savePath;

-(void)dealloc
{
	[urlPath release];
	[savePath release];
	[super dealloc];
}

-(void)main
{
	NSError *error = nil;
	NSURLResponse *response = nil;
	
	NSURL *url = [NSURL URLWithString:urlPath];
	
	NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
	
	NSLog(@"Downloading %@",urlPath);
	NSData *data = [NSURLConnection sendSynchronousRequest:request 
										 returningResponse:&response
													 error:&error];
	[request release];
	
	if(data == nil){
		NSLog(@"Error downloading %@.  %@",urlPath,[error localizedDescription]);
		return;
	}
	
	[data writeToFile:savePath atomically:NO];
	
}

@end
