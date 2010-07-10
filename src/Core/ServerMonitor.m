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

#import "ServerMonitor.h"
#import "Config.h"

#import "XmlHelpers.h"

#include <libxml/tree.h>
#include <libxml/parser.h>

@implementation ServerMonitor

@synthesize status;
@synthesize numPlayers;

-(ServerMonitor*) init
{
	if(self = [super init]){
		xmlData = [[NSMutableData alloc]init];
	}
	return self;
}

-(void) startMonitoring
{
#ifndef MACEVEAPI_DEBUG
	timer = 
	[NSTimer scheduledTimerWithTimeInterval:300.0
									 target:self
								   selector:@selector(timerFired:)
								   userInfo:nil 
									repeats:YES];
	[self checkServerStatus];
#endif
}

-(void) stopMonitoring
{
	[timer invalidate];
	timer = nil;
}

-(void) timerFired:(NSTimer*)theTimer
{
	[self checkServerStatus];
}

-(void) notifyListeners
{
	[[NSNotificationCenter defaultCenter]postNotificationName:SERVER_STATUS_NOTIFICATION object:self];
}

-(void) checkServerStatus
{
	NSString *urlPath = [Config getApiUrl:XMLAPI_SERVER_STATUS accountID:nil apiKey:nil charId:nil];
	NSURL *url = [NSURL URLWithString:urlPath];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[NSURLConnection connectionWithRequest:request delegate:self];
}

-(BOOL) parseXmlData:(NSData*)data
{
	xmlDoc *doc;
	xmlNode *node;
	
	//Default to unknown status.
	status = ServerUnknown;
	numPlayers = 0;
	
	const char *ptr = [data bytes];
	NSInteger length = [data length];
	
	if(length == 0){
		NSLog(@"Zero bytes returned for Server Status data");
		return NO;
	}
	
	doc = xmlReadMemory(ptr, (int)length, NULL, NULL, 0);
	
	node = xmlDocGetRootElement(doc);
	
	if(node == NULL){
		xmlFreeDoc(doc);
		return NO;
	}
	
	node = findChildNode(node, (xmlChar*)"result");
	if(node == NULL){
		//the API server returned an error, abandon processing.
		xmlFreeDoc(doc);
		return NO;
	}
	
	if(node->children == NULL){
		xmlFreeDoc(doc);
		return NO;
	}
	
	for(xmlNode *cur_node = node->children;
		cur_node != NULL;
		cur_node = cur_node->next)
	{
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		if(xmlStrcmp(cur_node->name, (xmlChar*)"serverOpen") == 0){
			const xmlChar *nodeText = getNodeCText(cur_node);
			if(xmlStrcasecmp(nodeText,(xmlChar*)"true") == 0){
				//server is up
				status = ServerUp;
			}else if(xmlStrcasecmp(nodeText,(xmlChar*)"false") == 0){
				status = ServerDown;
			}else{
				status = ServerUnknown;
			}
		}else if(xmlStrcmp(cur_node->name, (xmlChar*)"onlinePlayers") == 0){
			const xmlChar *text = getNodeCText(cur_node);
			
			numPlayers = (NSInteger) strtol((char*)text,NULL,10);
		}
	}
	
	xmlFreeDoc(doc);
	
	return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[xmlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self parseXmlData:xmlData];
	[xmlData setLength:0];
	
	NSLog(@"Tranquility: %@ (%ld)",
		  status == ServerUp ? @"online" : @"offline",
		  numPlayers);
	[self notifyListeners];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	/*error fetching URL*/
	[xmlData setLength:0];
	status = ServerUnknown;
	NSLog(@"Error fetching server status (%@)",[error localizedDescription]);
	[self notifyListeners];
}

@end
