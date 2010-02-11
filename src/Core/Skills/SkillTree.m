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

#import "SkillTree.h"

#import <libxml/tree.h>
#import <libxml/parser.h>
#import "XMLhelpers.h"
#import "Helpers.h"
#import "macros.h"

/*Methods for building a reference skilltree from the XML listing all skill*/

@interface SkillTree (SkillTreePrivate)

-(BOOL) privateParseSkillGroup:(xmlNode*)groups;
-(BOOL) privateParseXML:(NSString*)xmlPath;

/*Parse all the skills within a group*/
-(BOOL) privateParseSkillsForSkillGroup:(xmlNode*)skillNode skillGroup:(SkillGroup*)group;

/*parse the skill itself into a Skill object*/
-(BOOL) privateParseSkillItems:(xmlNode*)skillNode skillObject:(Skill*)s;

-(BOOL) privateParseSkillBonuses:(xmlNode*)rowset skillObject:(Skill*)s;

-(BOOL) privateParseSkillPrerequisites:(xmlNode*)rowset skillObject:(Skill*)s;
@end


@implementation SkillTree (SkillTreePrivate)

-(BOOL)privateParseXML:(NSString*)xmlPath
{
	//NSData *dat = [[NSData alloc]initWithContentsOfFile:xmlPath];
	
	/*
	 recurse through the XML finding the skill groups, with all the skills they contain
	 */
	
	NSLog(@"Attempting to read %@",xmlPath);
	xmlDoc *doc = xmlReadFile([xmlPath fileSystemRepresentation],NULL,0);
	
	if(doc == NULL){
		NSLog(@"Failed to open Skill Tree XML document");
		[[NSFileManager defaultManager]removeItemAtPath:xmlPath error:NULL];
		return NO;
	}
	
	xmlNode *root_node = xmlDocGetRootElement(doc);
	
	if(root_node == NULL){
		xmlFreeDoc(doc);
		return NO;
	}
	
	xmlNode *resultNode = findChildNode(root_node,(xmlChar*)"result");
	if(resultNode == NULL){
		xmlFreeDoc(doc);
		return NO;
	}
	
	xmlNode *resultset = findChildNode(resultNode,(xmlChar*)"rowset");
	
	if(resultset == NULL){
		xmlFreeDoc(doc);
		return NO;
	}
	
	/*we now have the top level rowset, which contains the skill groups and the skills contained within each group*/
	[self privateParseSkillGroup:resultset];
	xmlFreeDoc(doc);
	
	NSLog(@"Successfully parsed the XML skill tree document");
	
	return YES;
}

-(BOOL) privateParseSkillGroup:(xmlNode*)groups
{
	xmlNode *groupRowset = findChildNode(groups,(xmlChar*)"row");
	xmlNode *cur_node;
	
	for(cur_node = groupRowset; cur_node != NULL; cur_node = cur_node->next){
		NSString *groupName;
		NSString *groupID;
		
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		/*replace with xmlGetProp*/
		groupName = findAttribute(cur_node,(xmlChar*)"groupName");
		groupID = findAttribute(cur_node,(xmlChar*)"groupID");
		
		//NSLog(@"%@ - %@",groupName,groupID);
		
		SkillGroup *sg = [[SkillGroup alloc]
						  initWithDetails:groupName 
						  group:[NSNumber numberWithInteger:[ groupID integerValue]]];
		
		/*We have the parent skill here, any children of cur_node are the child of this node*/

		[self addSkillGroup:sg];
		[self privateParseSkillsForSkillGroup:findChildNode(cur_node,(xmlChar*)"rowset") skillGroup:sg];
	}
	
	return YES;
}

/*<rowset name="skills" key="typeID" columns="typeName,groupID,typeID">*/
-(BOOL) privateParseSkillsForSkillGroup:(xmlNode*)skillNode skillGroup:(SkillGroup*)group
{
	xmlNode *cur_node;
	
	for(cur_node = skillNode->children;
		cur_node != NULL;
		cur_node = cur_node->next)
	{
		NSString *skillName;
		NSString *typeID;
		NSString *groupID;
		/*<row typeName="Anchoring" groupID="266" typeID="11584">*/
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		skillName = findAttribute(cur_node,(xmlChar*)"typeName");
		typeID = findAttribute(cur_node,(xmlChar*)"typeID");
		groupID = findAttribute(cur_node, (xmlChar*)"groupID");
		
		//NSLog(@"%@ - %@ - %@",skillName, typeID, groupID);
		
		Skill *s = [[Skill alloc] initWithDetails:skillName
											group:[NSNumber numberWithInteger:[groupID integerValue]]
											 type:[NSNumber numberWithInteger:[typeID integerValue]]
					];
		
		/*
			for the children of the skill node, parse out the items such as prerequisites and primary / secondary attributes
		 */		
		[self privateParseSkillItems:cur_node->children skillObject:s];
		
		/*Attach the skill to the list of ALL skills*/
		[self addSkill:s toGroup:[group groupID]];
	}
	return YES;
}

-(BOOL) privateParseSkillItems:(xmlNode*)skillNode skillObject:(Skill*)s
{
	xmlNode *cur_node;
	
	for(cur_node = skillNode; cur_node != NULL; cur_node = cur_node->next){
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		if(xmlStrcmp(cur_node->name,(xmlChar*)"description") == 0){
			s.skillDescription = getNodeText(cur_node);
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"rank") == 0){
			s.skillRank = [getNodeText(cur_node) integerValue];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"rowset") == 0){
			/*perform rowset parsing here*/
			NSString *name = findAttribute(cur_node,(xmlChar*)"name");
			if([name isEqualToString:@"requiredSkills"]){
				/*parse the required skills here*/
				if(cur_node->children != NULL){
					[self privateParseSkillPrerequisites:cur_node->children skillObject:s];
				}
			}else if([name isEqualToString:@"skillBonusCollection"]){
				if(cur_node->children != NULL){
					[self privateParseSkillBonuses:cur_node->children skillObject:s];
				}
			}
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"requiredAttributes") == 0){
			for(xmlNode *child = cur_node->children;
				child != NULL;
				child = child->next)
			{
				if(child->type != XML_ELEMENT_NODE){
					continue;
				}
				if(xmlStrcmp(child->name,(xmlChar*)"primaryAttribute") == 0){
					[s setPrimaryAttr:attrCodeForString( getNodeText(child))];
				}else if(xmlStrcmp(child->name,(xmlChar*)"secondaryAttribute") == 0){
					[s setSecondaryAttr:attrCodeForString( getNodeText(child))];
				}
			}
		}
		
	}
	return YES;
}


-(BOOL) privateParseSkillBonuses:(xmlNode*)rowset skillObject:(Skill*)s
{
	for(xmlNode *cur_node = rowset;
		cur_node != NULL;
		cur_node = cur_node->next)
	{
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		NSString *bonusType = findAttribute(cur_node,(xmlChar*)"bonusType");
		NSString *bonusValue = findAttribute(cur_node,(xmlChar*)"bonusValue");
		
		[s addBonus:bonusType bonusValue:bonusValue];
	}
	return YES;
}

-(BOOL) privateParseSkillPrerequisites:(xmlNode*)rowset skillObject:(Skill*)s
{
	for(xmlNode *cur_node = rowset;
		cur_node != NULL;
		cur_node = cur_node->next)
	{
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		NSString *typeID = findAttribute(cur_node,(xmlChar*)"typeID");
		NSString *skillLevel = findAttribute(cur_node,(xmlChar*)"skillLevel");

		[s addPrerequiste:[NSNumber numberWithInteger:[typeID integerValue]]
					level:[skillLevel integerValue]];
	}
	return YES;
}

@end

@implementation SkillTree

-(void)dealloc
{
	[skillGroups release];
	[skills release];
	[skillGroupArray release];
	[skillSet release];
	
	[super dealloc];
}

-(SkillTree*) init
{
	if(self = [super init])
	{
		skillGroups = [[NSMutableDictionary alloc]init];
		skills = [[NSMutableDictionary alloc]init];
	}
	return self;
}


-(SkillTree*) copyWithZone:(NSZone*)zone
{
	SkillTree *st = [[SkillTree allocWithZone:zone]init];
	if(st != nil){
		[st->skillGroups release];
		[st->skills release];
		
		st->skillGroups = [skillGroups mutableCopy];
		st->skills = [skills mutableCopy];
		st->skillGroupArray = nil;
		st->skillPointTotal = 0;
	}
	
	return st;
}

-(SkillTree*) initWithXml:(NSString*)xmlPath
{
	if([self init]){
		BOOL rc = [self privateParseXML:xmlPath];
		if(!rc){
			[self autorelease];
			return nil;
		}
	}
	return self;
}

-(Skill*) skillForIdInteger:(NSInteger)skillID
{
	return [self skillForId:[NSNumber numberWithInteger:skillID]];
}

-(Skill*) skillForId:(NSNumber*)skillID
{
	return [skills objectForKey:skillID]; 
}


/*
 This is ineffiecent due to skills being keyed on TypeID and not skill name.
 A dictionary with mulitple keys would be useful.
 */
-(Skill*) skillForName:(NSString*)skillName
{
	Skill *s = nil;
	NSEnumerator *e = [skills objectEnumerator];
	
	while((s = [e nextObject]) != nil){
		if([[s skillName]isEqualToString:skillName]){
			return s;
		}
	}
	return nil;
}

-(NSInteger) skillPointTotal
{
	if(skillPointTotal == 0){
		NSEnumerator *e = [skillGroups objectEnumerator];
		SkillGroup *sg;
		while((sg = [e nextObject]) != nil){
			skillPointTotal += [sg groupSPTotal];
		}
	}
	return skillPointTotal;
}

-(NSInteger) skillsAtV
{
	NSInteger levelV = 0;
	NSEnumerator *e = [skills objectEnumerator];
	Skill *s;
	while((s = [e nextObject]) != nil){
		if([s skillLevel] == 5){
			levelV++;
		}
	}
	return levelV;
}

-(NSUInteger) skillCount
{
	return [skills count];
}

-(SkillGroup*) skillGroupAtIndex:(NSUInteger)index;
{
	if(skillGroupArray == nil){
		/*get the skill array, sort them alphabeticly*/
		skillGroupArray = [[[skillGroups allValues]sortedArrayUsingSelector:@selector(sortByName:)]retain];
	}
	
	return [skillGroupArray objectAtIndex:index];
}

-(SkillGroup*) groupForId:(NSNumber*)groupID
{
	return [skillGroups objectForKey:groupID];
}
-(void) addSkillGroup:(SkillGroup*)group
{
	[skillGroups setObject:group forKey:[group groupID]];
	
	/*invalidate the old cached sorted array*/
	if(skillGroupArray != nil){
		[skillGroupArray release];
		skillGroupArray = nil;
	}
	
	/* add all the skills to the gobal array?*/
}


-(NSUInteger) skillGroupCount
{
	return [skillGroups count];
}

-(BOOL) addSkill:(Skill*)skill toGroup:(NSNumber*)groupID
{
	SkillGroup *sg = [skillGroups objectForKey:groupID];
	if(sg == nil){
		NSLog(@"Skill Group %@ does not exist",groupID);
		return NO;
	}
	
	[sg addSkill:skill];
	[skills setObject:skill forKey:[skill typeID]];
	skillPointTotal = 0;
	
	if(skillSet != nil){
		[skillSet release];
		skillSet = nil;
	}
	return YES;
}


#pragma mark NSOutlineView datasource

-(NSInteger) outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item
{
	if(item == nil){
		return [self skillGroupCount];
	}else if([item isKindOfClass:[SkillGroup class]]){
		return [item skillCount];
	}
	return 0;
}

-(BOOL) outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item
{
	if([item isKindOfClass:[SkillGroup class]]){
		if([item skillCount] > 0){
			return YES;
		}
	}
	return NO;
}


/*
 if item is nil, return the root item.
 */
-(id) outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(id)item
{
	if(item == nil){
		return [self skillGroupAtIndex:index];
	}else if([item isKindOfClass:[SkillGroup class]]){
		return [item getSkillAtIndex:index];
	}
	return nil;
}


- (id)outlineView:(NSOutlineView *)outlineView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
		   byItem:(id)item
{
	//NSLog(@"%@",[tableColumn identifier] );
	
	if([item isKindOfClass:[SkillGroup class]]){
		if([[tableColumn identifier] isEqualToString:COL_SKILL_NAME]){
			return [item groupName];
		}else if([[tableColumn identifier] isEqualToString:COL_SKILL_POINTS]){
			return [NSNumber numberWithInteger:[item groupSPTotal]]; 
		}
	}else if([item isKindOfClass:[Skill class]]){
		if([[tableColumn identifier] isEqualToString:COL_SKILL_NAME]){
			return [item skillName];
		}else if([[tableColumn identifier] isEqualToString:COL_SKILL_CURLEVEL]){
			return [NSNumber numberWithInteger:[item skillLevel]];
		}else if([[tableColumn identifier] isEqualToString:COL_SKILL_RANK]){
			return [NSNumber numberWithInteger:[item skillRank]];
		}else if([[tableColumn identifier] isEqualToString:COL_SKILL_POINTS]){
			return [NSNumber numberWithInteger:[item skillPoints]];
		}
	}
	
	//NSLog(@"id: %@ class %@",[tableColumn identifier],[item class]);
	return nil;
}

- (NSString *)outlineView:(NSOutlineView *)ov 
		   toolTipForCell:(NSCell *)cell 
					 rect:(NSRectPointer)rect 
			  tableColumn:(NSTableColumn *)tc 
					 item:(id)item 
			mouseLocation:(NSPoint)mouseLocation
{
	if(![item isKindOfClass:[Skill class]]){
		return nil;
	}
	NSMutableString *str = [[[NSMutableString alloc]init]autorelease];
	[str appendFormat:@"Skill: %@\n\n",[item skillName]];
	[str appendFormat:@"Description: %@",[item skillDescription]];
	return str;
}

#pragma mark NSOutlineView delegate

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	return NO;
}

-(NSDictionary*) skillSet
{
	if(skillSet == nil){
		skillSet = [[NSDictionary dictionaryWithDictionary:skills]retain];
	}
	return skillSet;
}


@end
