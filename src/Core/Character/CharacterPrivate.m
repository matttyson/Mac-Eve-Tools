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

#import "CharacterPrivate.h"

#import "Config.h"
#import "GlobalData.h"
#import "XmlHelpers.h"
#import "CharacterDatabase.h"
#import "SkillPlan.h"

#import "XMLDownloadOperation.h"

#include <libxml/tree.h>
#include <libxml/parser.h>


@implementation Character (CharacterPrivate) 


/*
	Wrapper function that parses all the XML sheets for this character.
 */
-(BOOL) parseCharacterXml:(NSString*)path
{
	NSString *xmlPath;
	xmlDoc *doc;
	BOOL rc = NO;
	
	xmlPath = [path stringByAppendingFormat:@"/%@",[XMLAPI_CHAR_SHEET lastPathComponent]];
	NSLog(@"Parsing %@",xmlPath);
	
	/*Parse CharacterSheet.xml.aspx*/
	doc = xmlReadFile([xmlPath fileSystemRepresentation],NULL,0);
	if(doc == NULL){
		NSLog(@"Failed to read %@",xmlPath);
		return NO;
	}
	rc = [self parseXmlSheet:doc];
	xmlFreeDoc(doc);
	
	if(!rc){
		NSLog(@"Failed to parse %@",xmlPath);
		return NO;
	}
	
	
	/*parse the skill in training.*/
	xmlPath = [path stringByAppendingFormat:@"/%@",[XMLAPI_CHAR_TRAINING lastPathComponent]];
	NSLog(@"Parsing %@",xmlPath);
	
	doc = xmlReadFile([xmlPath fileSystemRepresentation],NULL,0);
	if(doc == NULL){
		NSLog(@"Failed to read %@",xmlPath);
		return NO;
	}
	rc = [self parseXmlTraningSheet:doc];
	xmlFreeDoc(doc);

	if(!rc){
		NSLog(@"Failed to parse %@",xmlPath);
		return NO;
	}
	
	
	/*parse the training queue*/
	xmlPath = [path stringByAppendingFormat:@"/%@",[XMLAPI_CHAR_QUEUE lastPathComponent]];
	doc = xmlReadFile([xmlPath fileSystemRepresentation],NULL,0);
	if(doc == NULL){
		NSLog(@"Failed to read %@",xmlPath);
		return NO;
	}
	rc = [self parseXmlQueueSheet:doc];
	xmlFreeDoc(doc);
	
	if(!rc){
		NSLog(@"Failed to parse %@",xmlPath);
		return NO;
	}
	
	/*
	 All the required XML sheets have been parsed successfully
	 The Character Object is ready for usage.
	 */
	return YES;	
}

-(void) xmlDidFailWithError:(NSError*)xmlErrorMessage xmlPath:(NSString*)path xmlDocName:(NSString*)docName
{
	NSLog(@"Connection failed! (%@)",[xmlErrorMessage localizedDescription]);
}

-(BOOL) xmlValidateData:(NSData*)xmlData xmlPath:(NSString*)path xmlDocName:(NSString*)docName
{
	BOOL rc = YES;
	
	/*Don't try and validate the character portrait*/
	if([docName isEqualToString:PORTRAIT]){
		return YES;
	}
	
	const char *bytes = [xmlData bytes];
	
	xmlDoc *doc = xmlReadMemory(bytes,(int)[xmlData length], NULL, NULL, 0);
	if(doc == NULL){
		return NO;
	}
	xmlNode *root_node = xmlDocGetRootElement(doc);
	if(root_node == NULL){
		xmlFreeDoc(doc);
		return NO;
	}
	xmlNode *result = findChildNode(root_node,(xmlChar*)"error");
	
	if(result != NULL){
		NSLog(@"%s",getNodeText(result));
		rc = NO;
	}
	
	xmlFreeDoc(doc);
	return rc;
}

-(void) xmlDocumentFinished:(BOOL)status xmlPath:(NSString*)path xmlDocName:(NSString*)docName;
{
	if(status == NO){
		NSLog(@"Failed to download XML %@",docName);
		return;
	}
	
	BOOL rc = NO;
	
	if([docName isEqualToString:XMLAPI_CHAR_TRAINING]){
		xmlDoc *doc = xmlReadFile([path fileSystemRepresentation],NULL,0);
		
		if(doc == NULL){
			NSLog(@"Error reading %@",path);
		}else{
			rc = [self parseXmlTraningSheet:doc];
			xmlFreeDoc(doc);
		}
	}else if([docName isEqualToString:XMLAPI_CHAR_SHEET]){
		xmlDoc *doc = xmlReadFile([path fileSystemRepresentation],NULL,0);
		
		if(doc == NULL){
			NSLog(@"Error reading %@",path);
		}else{
			rc = [self parseXmlSheet:doc];
			xmlFreeDoc(doc);
			
			NSLog(@"%@ finished update procedure",characterName);		
			for(SkillPlan *plan in skillPlans){
				if([plan purgeCompletedSkills] > 0){
					NSLog(@"Purging plan %@",[plan planName]);
					/*we prob don't need to post this notification anymore*/
					[[NSNotificationCenter defaultCenter]
					 postNotificationName:CHARACTER_SKILL_PLAN_PURGED
					 object:plan];	
				}
			}
			
			[[NSNotificationCenter defaultCenter]
				postNotificationName:CHARACTER_SHEET_UPDATE_NOTIFICATION 
								object:self];
		}
	}else if([docName isEqualToString:PORTRAIT]){
		rc = status;
	}else if([docName isEqualToString:XMLAPI_CHAR_QUEUE]){
		xmlDoc *doc = xmlReadFile([path fileSystemRepresentation],NULL,0);
		
		if(doc == NULL){
			NSLog(@"Error reading %@",path);
		}else{
			rc = [self parseXmlQueueSheet:doc];
			xmlFreeDoc(doc);
		}
		
	}else{
		NSLog(@"Unknown callback %@",docName);
		assert(0);
	}
}

/*
-(XMLDownloadOperation*) buildOperation:(NSString*)docPath
{

	NSString *apiUrl = [Config getApiUrl:docPath 
							   accountID:[account accountID] 
								  apiKey:[account apiKey]
								  charId:characterId];

	
	NSString *characterDir = [Config charDirectoryPath:[account accountID] 
											 character:[self characterId]];
	
	XMLDownloadOperation *op;
	
	op = [[XMLDownloadOperation alloc]init];
	[op setXmlDocUrl:apiUrl];
	[op setCharacterDirectory:characterDir];
	[op setXmlDoc:docPath];
	
	[op autorelease];
	
	return op;
}
*/


/*
 Build the SkillTree Object for the Character Skill Rowset.
 Requres the (hopefully) already constructed global skill tree
 so we can get the skill ID and determine what group it belongs to.
 
 for each skill
 find the group
 does the group exist in the tree?
 yes: add to that group
 no: create the group
 add the group to the tree
 add the skill to the group.
 
 this will give us a complete skill tree for this character
 */
-(BOOL) buildSkillTree:(xmlNode*)rowset;
{
	xmlNode *cur_node;
	SkillTree *master = [[GlobalData sharedInstance]skillTree];
	
	if(st != nil){
		[st release];
		st = nil;
	}
	
	st = [[SkillTree alloc]init];
	
	for(cur_node = rowset->children;
		cur_node != NULL;
		cur_node = cur_node->next)
	{
		NSString *typeID;
		NSString *skillPoints;
		NSString *level;
		
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		typeID = findAttribute(cur_node,(xmlChar*)"typeID");
		skillPoints = findAttribute(cur_node,(xmlChar*)"skillpoints");
		level = findAttribute(cur_node,(xmlChar*)"level");
		
		/*
		 Here we have all the details we can get from the character sheet for the skill.
		 Now we need to build up a skill tree using the details
		 */
		
		//NSLog(@"%@ %@ %@",typeID, skillPoints, level);
		Skill *temp = [master skillForIdInteger:[typeID integerValue]];
		if(temp == nil){
			NSLog(@"Error: cannot find skill %@ in skill tree! - skipping skill",typeID);
			continue;
		}
		Skill *s = [temp copy];
		[s setSkillPoints:[skillPoints integerValue]];
		[s setSkillLevel:[level integerValue]];
		
		SkillGroup *sg;
		if((sg = [st groupForId:[s groupID]]) == nil){ /*If the skill group does not exist*/
			SkillGroup *masterGroup = [master groupForId:[s groupID]];
			assert(masterGroup != nil);
			sg = [[SkillGroup alloc]initWithDetails:[masterGroup groupName] group:[masterGroup groupID]];
			[st addSkillGroup:sg]; /*add the skill group to the tree*/
			[sg autorelease];
		}
		[st addSkill:s toGroup:[s groupID]];
		[s release];
	}
	
	/*once the skill tree has been parsed, we can read the training plans*/
	[self readSkillPlans];
	
	return YES;
}

-(BOOL) parseXmlQueueSheet:(xmlDoc*)document;
{
	xmlNode *root_node;
	xmlNode *result;
	
	root_node = xmlDocGetRootElement(document);
	
	result = findChildNode(root_node,(xmlChar*)"result");
	if(result == NULL){
		xmlNode *xmlErrorMessage = findChildNode(root_node,(xmlChar*)"error");
		if(xmlErrorMessage != NULL){
			errorMessage[CHAR_ERROR_TRAININGSHEET] = [[NSString stringWithString:getNodeText(xmlErrorMessage)]retain];
			error[CHAR_ERROR_TRAININGSHEET] = YES;
			NSLog(@"EVE error: %@",errorMessage[CHAR_ERROR_TRAININGSHEET]);
		}		
		return NO;
	}
	
	if(trainingQueue != nil){
		[trainingQueue release];
		trainingQueue = nil;
	}
	
	trainingQueue = [[SkillPlan alloc]initWithName:@"Training Queue" character:self];
	
	
	xmlNode *rowset = findChildNode(result,(xmlChar*)"rowset");
	
	for(xmlNode *cur_node = rowset->children;
		cur_node != NULL;
		cur_node = cur_node->next)
	{
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		NSString *type = findAttribute(cur_node,(xmlChar*)"typeID");
		NSString *level = findAttribute(cur_node,(xmlChar*)"level");
		
		if(type == nil){
			NSLog(@"Error parsing skill plan. typeID is nil");
			return NO;
		}
		if(type == nil){
			NSLog(@"Error parsing skill plan. typeID is nil");
			return NO;
		}
			
		[trainingQueue secretAddSkillToPlan:[NSNumber numberWithInteger:[type integerValue]]
							 level:[level integerValue]];
	}
	
	return YES;
}

-(BOOL) parseXmlTraningSheet:(xmlDoc*)document
{
	xmlNode *root_node;
	xmlNode *result;
	
	root_node = xmlDocGetRootElement(document);
	
	result = findChildNode(root_node,(xmlChar*)"result");
	if(result == NULL){
		NSLog(@"Failed to find result tag");
		xmlNode *xmlErrorMessage = findChildNode(root_node,(xmlChar*)"error");
		if(xmlErrorMessage != NULL){
			errorMessage[CHAR_ERROR_TRAININGSHEET] = [[NSString stringWithString:getNodeText(xmlErrorMessage)]retain];
			error[CHAR_ERROR_TRAININGSHEET] = YES;
			NSLog(@"EVE error: %@",errorMessage[CHAR_ERROR_TRAININGSHEET]);
		}		
		return NO;
	}
	
	for(xmlNode *cur_node = result->children;
		cur_node != NULL;
		cur_node = cur_node->next)
	{
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		/*
		 since we are essentially grabbing everything we could probably do away with the 
		 xmlStrcmp() functions and stuff everything into the dictionary.
		 */
		
		if(xmlStrcmp(cur_node->name,(xmlChar*)"trainingEndTime") == 0){
			[self addToDictionary:cur_node->name value:getNodeText(cur_node)];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"trainingStartTime") == 0){
			[self addToDictionary:cur_node->name value:getNodeText(cur_node)];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"trainingTypeID") == 0){
			[self addToDictionary:cur_node->name value:getNodeText(cur_node)];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"trainingStartSP") == 0){
			[self addToDictionary:cur_node->name value:getNodeText(cur_node)];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"trainingDestinationSP") == 0){
			[self addToDictionary:cur_node->name value:getNodeText(cur_node)];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"trainingToLevel") == 0){
			[self addToDictionary:cur_node->name value:getNodeText(cur_node)];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"skillInTraining") == 0){
			/*
			 if this is equal to zero, there is no skill in training 
			 the existing skill training data will need to be removed from the dictionary.
			 or the skillInTraining flag set, and the skill panel set or ignored based on that
			 */
			[self addToDictionary:cur_node->name value:getNodeText(cur_node)];
		}
	}
	
	/*clear out error information*/
	error[CHAR_ERROR_TRAININGSHEET] = NO;
	if(errorMessage[CHAR_ERROR_TRAININGSHEET] != nil){
		[errorMessage[CHAR_ERROR_TRAININGSHEET] release];
		errorMessage[CHAR_ERROR_TRAININGSHEET] = nil;
	}	
	
	return YES;
}

-(BOOL) parseXmlSheet:(xmlDoc*)document
{
	xmlNode *root_node;
	xmlNode *result;
	
	root_node = xmlDocGetRootElement(document);
	
	result = findChildNode(root_node,(xmlChar*)"result");
	if(result == NULL){
		NSLog(@"Could not get result tag");
		
		xmlNode *xmlErrorMessage = findChildNode(root_node,(xmlChar*)"error");
		if(xmlErrorMessage != NULL){
			errorMessage[CHAR_ERROR_CHARSHEET] = [[NSString stringWithString:getNodeText(xmlErrorMessage)]retain];
			error[CHAR_ERROR_CHARSHEET] = YES;
			NSLog(@"EVE error: %@",errorMessage[CHAR_ERROR_CHARSHEET]);
		}
		return NO;
	}
	
	for(xmlNode *cur_node = result->children; 
		cur_node != NULL;
		cur_node = cur_node->next)
	{
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		if(xmlStrcmp(cur_node->name,(xmlChar*)"characterID") == 0){
			
			NSString *charIdString = getNodeText(cur_node);
			
			characterId = (NSUInteger) [charIdString integerValue];
			[self addToDictionary:cur_node->name value:charIdString];
			
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"name") == 0){
			
			characterName = getNodeText(cur_node);
			[characterName retain];
			[self addToDictionary:cur_node->name value:characterName];
			
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"race") == 0){
			[self addToDictionary:cur_node->name value:getNodeText(cur_node)];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"bloodLine") == 0){
			[self addToDictionary:cur_node->name value:getNodeText(cur_node)];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"gender") == 0){
			[self addToDictionary:cur_node->name value:getNodeText(cur_node)];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"corporationName") == 0){
			[self addToDictionary:cur_node->name value:getNodeText(cur_node)];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"corporationID") == 0){
			[self addToDictionary:cur_node->name value:getNodeText(cur_node)];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"cloneName") == 0){
			[self addToDictionary:cur_node->name value:getNodeText(cur_node)];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"cloneSkillPoints") == 0){
			[self addToDictionary:cur_node->name value:getNodeText(cur_node)];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"balance") == 0){
			[self addToDictionary:cur_node->name value:getNodeText(cur_node)];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"attributeEnhancers") == 0){
			/*process the attribute enhancers in a seperate function*/
			[self parseAttributeImplants:cur_node];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"attributes") == 0){
			/*process attributes here*/
			[self parseAttributes:cur_node];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"rowset") == 0){
			
			xmlChar* rowset_name = xmlGetProp(cur_node,(xmlChar*)"name");
			
			if(xmlStrcmp(rowset_name,(xmlChar*)"skills") == 0){
				/*process the skills for the character here.*/
				[self buildSkillTree:cur_node];
			}
			
			xmlFree(rowset_name);
		}
	}
	
	/*
		we have to look at the learning skills and apply those modifiers to the character attributes
	 */
	[self calculateLearningSkills];
	/*sum all the values*/
	[self processAttributeSkills];
	
	/*
		The Characater must have been completly built up and is ready for use
	 */
	
	error[CHAR_ERROR_CHARSHEET] = NO;
	if(errorMessage[CHAR_ERROR_CHARSHEET] != nil){
		[errorMessage[CHAR_ERROR_CHARSHEET] release];
	}
	
	return YES;
}

-(void)calculateLearningSkills
{
	memset(learningTotals,0,sizeof(learningTotals));
	
	/*find all the basic and advanced learning skills and apply them to the character attribute total*/
	Skill *skill;
	/*Analytical mind. type 3377. +1 int*/
	
	skill = [st skillForIdInteger:3377];
	if(skill != nil){
		learningTotals[ATTR_INTELLIGENCE] += [skill skillLevel];
	}
	/*Logic. type 12376. +1 int*/
	skill = [st skillForIdInteger:12376];
	if(skill != nil){
		learningTotals[ATTR_INTELLIGENCE] += [skill skillLevel];
	}
	/*Spatial Awareness. type 3379. +1 perc*/
	skill = [st skillForIdInteger:3379];
	if(skill != nil){
		learningTotals[ATTR_PERCEPTION] += [skill skillLevel];
	}
	/*Clarity. type 12387. +1 perc*/
	skill = [st skillForIdInteger:12387];
	if(skill != nil){
		learningTotals[ATTR_PERCEPTION] += [skill skillLevel];
	}
	
	/*Instant Recall. 3378.  +1 mem*/
	skill = [st skillForIdInteger:3378];
	if(skill != nil){
		learningTotals[ATTR_MEMORY] += [skill skillLevel];
	}
	/*Eidetic Memory. type 12385. +1 mem*/
	skill = [st skillForIdInteger:12385];
	if(skill != nil){
		learningTotals[ATTR_MEMORY] += [skill skillLevel];
	}
	
	/*Empathy. type 3376. +1 chr*/
	skill = [st skillForIdInteger:3376];
	if(skill != nil){
		learningTotals[ATTR_CHARISMA] += [skill skillLevel];
	}
	/*Presence. type 12383. +1 chr*/
	skill = [st skillForIdInteger:12383];
	if(skill != nil){
		learningTotals[ATTR_CHARISMA] += [skill skillLevel];
	}
	/*Iron Will. 3375. +1 will*/
	skill = [st skillForIdInteger:3375];
	if(skill != nil){
		learningTotals[ATTR_WILLPOWER] += [skill skillLevel];
	}
	/*Focus. type 12386. +1 will*/
	skill = [st skillForIdInteger:12386];
	if(skill != nil){
		learningTotals[ATTR_WILLPOWER] += [skill skillLevel];
	}
}

/*base attributes before any modifiers are applied*/
-(BOOL) parseAttributes:(xmlNode*)attributes
{
	for(xmlNode *cur_node = attributes->children;
		cur_node != NULL;
		cur_node = cur_node->next)
	{
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		NSInteger value = [getNodeText(cur_node) integerValue];
		
		if(xmlStrcmp(cur_node->name,(xmlChar*)"intelligence") == 0){
			baseAttributes[ATTR_INTELLIGENCE] = value;
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"memory") == 0){
			baseAttributes[ATTR_MEMORY] = value;
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"charisma") == 0){
			baseAttributes[ATTR_CHARISMA] = value;
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"perception") == 0){
			baseAttributes[ATTR_PERCEPTION] = value;
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"willpower") == 0){
			baseAttributes[ATTR_WILLPOWER] = value;
		}
	}
	return YES;
}

-(BOOL) parseAttributeImplants:(xmlNode*)attrs
{
	/*this loop will iterate over the <perceptionBonus> type tags*/
	for(xmlNode *attr_node = attrs->children;
		attr_node != NULL;
		attr_node = attr_node->next)
	{
		if(attr_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		xmlNode *node = findChildNode(attr_node,(xmlChar*)"augmentatorValue");
		if(node == NULL){
			continue;
		}
		
		NSInteger bonus = [getNodeText(node) integerValue];
		
		if(xmlStrcmp(attr_node->name,(xmlChar*)"perceptionBonus") == 0){
			implantAttributes[ATTR_PERCEPTION] = bonus;
		}else if(xmlStrcmp(attr_node->name,(xmlChar*)"memoryBonus") == 0){
			implantAttributes[ATTR_MEMORY] = bonus;
		}else if(xmlStrcmp(attr_node->name,(xmlChar*)"willpowerBonus") == 0){
			implantAttributes[ATTR_WILLPOWER] = bonus;
		}else if(xmlStrcmp(attr_node->name,(xmlChar*)"intelligenceBonus") == 0){
			implantAttributes[ATTR_INTELLIGENCE] = bonus;
		}else if(xmlStrcmp(attr_node->name,(xmlChar*)"charismaBonus") == 0){
			implantAttributes[ATTR_CHARISMA] = bonus;
		}
	}
	return YES;
}

-(void) addToDictionary:(const xmlChar*)xmlKey value:(NSString*)value
{
	[data setValue:value forKey:[NSString stringWithUTF8String:(const char*)xmlKey]];
}

/*
 read the character skill plans from the sqlite database. delete the internal list if it exists
*/

-(NSInteger) readSkillPlans
{
	if(skillPlans != nil){
		[skillPlans release];
	}
	
	skillPlans = [[db readSkillPlans:self]retain];
	
	return [skillPlans count];
}

-(BOOL) writeSkillPlan
{
	return [db writeSkillPlans:skillPlans];
}

@end
