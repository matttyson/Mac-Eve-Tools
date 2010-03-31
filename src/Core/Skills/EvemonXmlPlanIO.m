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

#import "EvemonXmlPlanIO.h"


#import <libxml/parser.h>
#import <libxml/SAX2.h>

#import "zlib.h"


#import "XmlHelpers.h"
#import "GlobalData.h"
#import "SkillTree.h"
#import "SkillPair.h"
#import "SkillPlan.h"
#import "Character.h"

@implementation EvemonXmlPlanIO

-(id)init
{
	if(self = [super init]){
		st = [[GlobalData sharedInstance]skillTree];
	}
	return self;
}

-(void)dealloc
{
	//st is not retained. do not release it.
	[super dealloc];
}
/*
-(BOOL) privateParseEntry:(xmlNode*)node intoPlan:(SkillPlan*)plan
{
	NSInteger skillLevel = 0;
	NSNumber *typeID = nil;
	
	for(xmlNode *cur_node = node;
		cur_node != NULL;
		cur_node = cur_node->next)
	{
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		if(xmlStrcmp(cur_node->name,(xmlChar*)"SkillName") == 0){
			NSString *skillName = getNodeText(cur_node);
			Skill *s = [st skillForName:skillName];
			if(s == nil){
				NSLog(@"nil skill ptr for %@",skillName);
				return NO;
			}
			typeID = [s typeID];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"Level") == 0){
			NSString *levelStr = getNodeText(cur_node);
			skillLevel = [levelStr integerValue];
		}
	}
	if(typeID != nil && skillLevel != 0){
		[plan addSkillToPlan:typeID level:skillLevel];
	}
	return YES;
}

-(BOOL) privateParseXml:(xmlDoc*)doc intoPlan:(SkillPlan*)plan
{
	xmlNode *root_node = xmlDocGetRootElement(doc);
	if(root_node == NULL){
		return NO;
	}
	
	xmlNode *entries = findChildNode(root_node,(xmlChar*)"Entries");
	
	if(entries == NULL){
		NSLog(@"NULL entries pointer");
		return NO;
	}
	
	for(xmlNode *cur_node = entries->children;
		cur_node != NULL;
		cur_node = cur_node->next)
	{
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		if(![self privateParseEntry:cur_node->children intoPlan:plan]){
			return NO;
		}
	}
	return YES;
}
*/

-(BOOL) readEntry:(xmlNode*)node intoPlan:(SkillPlan*)plan
{
	NSInteger skillID;
	NSInteger skillLevel;
	
	NSString *str;
	
	str = findAttribute(node,(xmlChar*)"skillID");
	skillID = [str integerValue];
	
	str = findAttribute(node,(xmlChar*)"level");
	skillLevel = [str integerValue];
	
	[plan addSkillToPlan:[NSNumber numberWithInteger:skillID] level:skillLevel];
	
	return YES;
}

-(BOOL) readXmlData:(xmlDoc*)doc intoPlan:(SkillPlan*)plan
{
	xmlNode *root_node = xmlDocGetRootElement(doc);
	if(root_node == NULL){
		return NO;
	}
	
	for(xmlNode *cur_node = root_node->children;
		cur_node != NULL;
		cur_node = cur_node->next)
	{
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		if(xmlStrcmp(cur_node->name,(xmlChar*)"entry") == 0){
			[self readEntry:cur_node intoPlan:plan];
		}
	}
	
	return [plan skillCount] > 0;
}

-(BOOL) readCompressed:(NSString*)filePath intoPlan:(SkillPlan*)plan
{
#define CHUNK 16384
	
	gzFile *file;
	
	file = gzopen([filePath fileSystemRepresentation], "rb");
	if(file == NULL){
		NSLog(@"Failed to open '%@'",filePath);
		return NO;
	}

	char *buffer = malloc(CHUNK);
	int bytesRead;
	NSMutableData *data = [[NSMutableData alloc]init];
	
	while( (bytesRead = gzread(file,buffer,CHUNK)) != 0){
		[data appendBytes:buffer length:bytesRead];
	}
	
	free(buffer);
	gzclose(file);
	
	
	xmlDoc *doc = xmlReadMemory([data bytes],[data length],NULL,NULL,0);
	
	[data release];
	
	if(doc == NULL){
		NSLog(@"Failed to read XML data");
		return NO;
	}
	
	BOOL rc = [self readXmlData:doc intoPlan:plan];
	
	if(rc){
		[plan savePlan];
	}
	xmlFreeDoc(doc);
	
	return rc;
	
}


/*read the skill plan into the character.*/
-(BOOL) readXml:(NSString*)filePath intoPlan:(SkillPlan*)plan
{
	if(filePath == nil){
		return NO;
	}
	
	xmlDoc *doc = xmlReadFile([filePath fileSystemRepresentation], NULL, 0);
	
	if(doc == NULL){
		NSLog(@"Failed to parse XML plan file");
		return NO;
	}
	
	BOOL rc = [self readXmlData:doc intoPlan:plan];

	xmlFreeDoc(doc);
	
	if(rc){
		[plan savePlan];
	}
	
	
	return rc;
}

-(BOOL) read:(NSString*)filePath intoPlan:(SkillPlan*)plan
{
	if([[filePath pathExtension]caseInsensitiveCompare:@"emp"] == NSOrderedSame){
		return [self readCompressed:filePath intoPlan:plan];
	}else if([[filePath pathExtension]caseInsensitiveCompare:@"xml"] == NSOrderedSame){
		return [self readXml:filePath intoPlan:plan];
	}else{
		NSLog(@"Unknown file %@",filePath);
	}
	
	return NO;
}

/*
-(NSURL*) getFilePath
{
	NSOpenPanel *op = [NSOpenPanel openPanel];
	[op setCanChooseDirectories:NO];
	[op setCanChooseFiles:YES];
	[op setAllowsMultipleSelection:NO];
	[op runModal];
	
	if([[op URLs]count] == 0){
		return nil;
	}
	
	return [[op URLs]objectAtIndex:0];
}
*/
@end
