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
#import <libxml/xmlwriter.h>
#import <libxml/tree.h>

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

-(BOOL) parseOldEvemonEntry:(xmlNode*)node intoPlan:(SkillPlan*)plan
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

-(BOOL) readOldEvemonPlan:(xmlDoc*)doc intoPlan:(SkillPlan*)plan
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
		if(![self parseOldEvemonEntry:cur_node->children intoPlan:plan]){
			return NO;
		}
	}
	return YES;
}

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
	
	/*
	NSString *planName = findAttribute(root_node,(xmlChar*)"name");
	if(planName != nil){
		[plan setPlanName:planName];
	}
	*/
	
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

-(NSData*) readCompressed:(NSString*)filePath
{	
	gzFile *file;
	const int chunkSize = 16384;
	
	file = gzopen([filePath fileSystemRepresentation], "rb");
	if(file == NULL){
		NSLog(@"Failed to open '%@'",filePath);
		return NO;
	}
	
	char *buffer = (char*) malloc(chunkSize);
	
	if(buffer == NULL){
		NSLog(@"Failed to malloc %d bytes",chunkSize);
		gzclose(file);
		return NO;
	}
	
	int bytesRead;
	NSMutableData *data = [[[NSMutableData alloc]init]autorelease];
	
	while( (bytesRead = gzread(file,buffer,chunkSize)) > 0){
		[data appendBytes:buffer length:bytesRead];
	}
	
	free(buffer);
	gzclose(file);
	
	return data;
}


-(BOOL) readData:(NSData*)data intoPlan:(SkillPlan*)plan
{
	if(data == nil){
		return NO;
	}
	
	xmlDoc *doc = xmlReadMemory([data bytes], [data length],NULL, NULL, 0);
	
	if(doc == NULL){
		NSLog(@"Failed to parse XML plan file");
		return NO;
	}
	
	BOOL rc = [self readXmlData:doc intoPlan:plan];
	
	if(!rc){
		NSLog(@"Failed to import plan.  Attempting import using old format.");
		
		rc = [self readOldEvemonPlan:doc intoPlan:plan];
		
		if(rc){
			NSLog(@"Success using old evemon format");
		}else{
			NSLog(@"Failure using old evemon format");
		}
	}
	
	xmlFreeDoc(doc);
	
	if(rc){
		[plan savePlan];
	}
	
	return rc;
}

-(BOOL) read:(NSString*)filePath intoPlan:(SkillPlan*)plan
{
	NSData *planData = nil;
	
	if([[filePath pathExtension]caseInsensitiveCompare:@"emp"] == NSOrderedSame){
		planData = [self readCompressed:filePath];
	}else if([[filePath pathExtension]caseInsensitiveCompare:@"xml"] == NSOrderedSame){
		planData = [NSData dataWithContentsOfFile:filePath];
	}else{
		NSLog(@"Unknown file %@",filePath);
	}
	
	BOOL rc = [self readData:planData intoPlan:plan];
	
	return rc;
}


/*
	write a 
 */
-(NSData*) writeToBuffer:(SkillPlan*)plan
{
	xmlDoc *doc = xmlNewDoc((xmlChar*)"1.0");
	
	xmlNode *root = xmlNewNode(NULL,(xmlChar*)"plan");
	xmlDocSetRootElement(doc, root);
	
	xmlNewProp(root,(xmlChar*)"xmlns:xsi",(xmlChar*)"http://www.w3.org/2001/XMLSchema-instance");
	xmlNewProp(root,(xmlChar*)"xmlns:xsd",(xmlChar*)"http://www.w3.org/2001/XMLSchema");
	xmlNewProp(root,(xmlChar*)"name",(xmlChar*)[[plan planName]UTF8String]);
	xmlNewProp(root,(xmlChar*)"revision",(xmlChar*)"2138");
	
	xmlNode *child = xmlNewChild(root,NULL,(xmlChar*)"sorting",NULL);
	xmlNewProp(child,(xmlChar*)"criteria",(xmlChar*)"None");
	xmlNewProp(child,(xmlChar*)"order",(xmlChar*)"None");
	xmlNewProp(child,(xmlChar*)"optimizeLearning",(xmlChar*)"false");
	xmlNewProp(child,(xmlChar*)"groupByPriority",(xmlChar*)"false");
	
	NSInteger counter = [plan skillCount];
	
	for(NSInteger i = 0; i < counter; i++){
		SkillPair *sp = [plan skillAtIndex:i];
		Skill *s = [st skillForId:[sp typeID]];
		
		xmlNode *skillNode = xmlNewChild(root,NULL,(xmlChar*)"entry",NULL);
		xmlNewProp(skillNode,(xmlChar*)"skillID",(xmlChar*)
				   [[[sp typeID]descriptionWithLocale:nil]UTF8String]);
		xmlNewProp(skillNode,(xmlChar*)"skill",(xmlChar*)[[s skillName]UTF8String]);
		
		xmlNewProp(skillNode,(xmlChar*)"level",(xmlChar*)
				   /*this is probably a crap way to do it*/
				   [[[NSNumber numberWithInteger:[sp skillLevel]]descriptionWithLocale:nil]UTF8String]
				   );
		
		xmlNewProp(skillNode,(xmlChar*)"priority",(xmlChar*)"1");
		xmlNewProp(skillNode,(xmlChar*)"type",(xmlChar*)"Prerequisite");
	}
	
	xmlBuffer *buf = xmlBufferCreate();
	xmlOutputBuffer *outBuf = xmlOutputBufferCreateBuffer(buf,NULL);
	xmlSaveFormatFileTo(outBuf,doc,"UTF-8",1);
	
	NSData *data = [NSData dataWithBytes:buf->content length:buf->use];
	
	xmlFreeDoc(doc);
	xmlBufferFree(buf);
	
	//xmlOutputBufferClose(outBuf);
	//Do i need to freel the xmlOutputBuffer?
	
	return data;
}

-(BOOL) writeCompressed:(NSData*)data file:(NSString*)filePath
{
	gzFile *fp;
	int rc;
	
	fp = gzopen([filePath fileSystemRepresentation],"wb9");
	
	if(fp == NULL){
		NSLog(@"Error writing file");
		return NO;
	}
	
	rc = gzwrite(fp, [data bytes], [data length]);
	
	if(rc != [data length]){
		NSLog(@"error writing plan?");
	}
	
	gzclose(fp);
	
	return YES;
}


-(BOOL) write:(SkillPlan*)plan toFile:(NSString*)filePath
{
	NSData *xmlPlan = [self writeToBuffer:plan];
	
	if(xmlPlan == nil){
		return NO;
	}
	
	if([[filePath pathExtension]isEqualToString:@"emp"]){
		//write to a gzip compressed file
		return [self writeCompressed:xmlPlan file:filePath];
	}else if([[filePath pathExtension]isEqualToString:@"xml"]){
		//write to a normal xml file
		return [xmlPlan writeToFile:filePath atomically:NO];
	}
	
	return NO;
}

@end
