//
//  CertTree.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 25/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CertTree.h"

#import "Cert.h"
#import "CertClass.h"
#import "CertCategory.h"

#import "SkillPair.h"
#import "CertPair.h"

#import <libxml/tree.h>
#import <libxml/parser.h>

#import "Helpers.h"
#import "XmlHelpers.h"


@implementation CertTree


-(NSArray*) privateCertSkillPrereqs:(xmlNode*)skillRow
{
	NSMutableArray *array = [[[NSMutableArray alloc]init]autorelease];
	
	xmlNode *cur_node;
	
	for(cur_node = skillRow->children; cur_node != NULL; cur_node = cur_node->next){
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		NSString *typeID = findAttribute(cur_node,(xmlChar*)"typeID");
		NSString *level = findAttribute(cur_node,(xmlChar*)"level");
		
		SkillPair *pair = [[SkillPair alloc]initWithSkill:
						   [NSNumber numberWithInteger:[typeID integerValue]] 
													level:[level integerValue]];
		
		[array addObject:pair];
	}
	
	if([array count] == 0){
		return nil;
	}
	
	return array;
}


-(NSArray*) privateCertCertPrereqs:(xmlNode*)skillRow
{
	NSMutableArray *array = [[[NSMutableArray alloc]init]autorelease];
	
	xmlNode *cur_node;
	
	for(cur_node = skillRow->children; cur_node != NULL; cur_node = cur_node->next){
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		NSString *certID = findAttribute(cur_node,(xmlChar*)"certificateID");
		NSString *grade = findAttribute(cur_node,(xmlChar*)"grade");
		
		CertPair *pair = [CertPair createCertPair:[certID integerValue] certGrade:[grade integerValue]];
		
		[array addObject:pair];
	}
	
	if([array count] == 0){
		return nil;
	}
	
	return array;
}

-(NSArray*) privateParseCert:(xmlNode*)cert certClass:(CertClass*)parent
{
	xmlNode *cur_node;
	
	NSMutableArray *array = [[[NSMutableArray alloc]init]autorelease];
	
	for(cur_node = cert->children; cur_node != NULL; cur_node = cur_node->next){
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		NSString *certID = findAttribute(cur_node,(xmlChar*)"certificateID");
		NSString *certGrade = findAttribute(cur_node,(xmlChar*)"grade");
		NSString *certDesc = findAttribute(cur_node,(xmlChar*)"description");
		
		NSArray *skillArray;
		NSArray *certArray;
		
		xmlNode *cur_child;
		
		for(cur_child = cur_node->children; 
			cur_child != NULL; 
			cur_child = cur_child->next)
		{
			if(cur_child->type != XML_ELEMENT_NODE){
				continue;
			}
			
			NSString *rowName = findAttribute(cur_child,(xmlChar*)"name");
			
			if([rowName isEqualToString:@"requiredSkills"]){
				skillArray = [self privateCertSkillPrereqs:cur_child];
				
			}else if([rowName isEqualToString:@"requiredCertificates"]){
				certArray = [self privateCertCertPrereqs:cur_child];
			}
		}
		
		Cert *c = [Cert createCert:[certID integerValue] 
							 grade:[certGrade integerValue] 
							  text:certDesc 
						  skillPre:skillArray
						   certPre:certArray
						 certClass:parent];
		
		
		[allCerts setObject:c forKey:[NSNumber numberWithInteger:[certID integerValue]]];
		
		[array addObject:c];
		
		[c release];
	}
	
	[array sortUsingSelector:@selector(gradeComparitor:)];
	
	return array;
}

/*
	parse the "classes" rowsets
 */
-(NSArray*) privateParseClassRowset:(xmlNode*)classRowset
{
	xmlNode *cur_node;
	NSMutableArray *certClassArray = [[[NSMutableArray alloc]init]autorelease];
	
	for(cur_node = classRowset->children; cur_node != NULL; cur_node = cur_node->next){
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		NSString *className = findAttribute(cur_node,(xmlChar*)"className");
		NSString *classID = findAttribute(cur_node,(xmlChar*)"classID");
		
		xmlNode *certNode = findChildNode(cur_node,(xmlChar*)"rowset");
		
		//The certClass needs to be passed to the cert objects, so the 
		//cert objects have a reference to their parent.
		CertClass *cc = [CertClass createCertClass:[classID integerValue]
											  desc:className];
		
		//All the certs belonging to this class
		NSArray *certArray = [self privateParseCert:certNode certClass:cc];
		
		
		[cc setCertArray:certArray];
		
		[certClassArray addObject:cc];
		
	}
	return certClassArray;
}


-(NSArray*) privateParseCatRowset:(xmlNode*)catRowset
{
	xmlNode *setBegin;
	xmlNode *cur_node;
	
	NSMutableArray *array = [[[NSMutableArray alloc]init]autorelease];
	
	setBegin = catRowset->children;
	
	for(cur_node = setBegin; cur_node != NULL; cur_node = cur_node->next){
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		NSString *catName = findAttribute(cur_node,(xmlChar*)"categoryName");
		NSString *catID = findAttribute(cur_node,(xmlChar*)"categoryID");
				
		xmlNode *classRowset = findChildNode(cur_node,(xmlChar*)"rowset");
		
		NSArray *certClassArray = [self privateParseClassRowset:classRowset];
		
		CertCategory *ccat = [CertCategory createCertCategory:[catID integerValue] 
														 name:catName 
													   cClass:certClassArray];
		
		[array addObject:ccat];
	}
	
	return array;
}

-(BOOL) privateParseXML:(NSString*)xmlPath
{
	NSLog(@"Attempting to read %@",xmlPath);
	
	xmlDoc *doc = xmlReadFile([xmlPath fileSystemRepresentation],NULL,0);
	
	if(doc == NULL){
		NSLog(@"Failed to open cert XML document");
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
	
	xmlNode *catRowset = findChildNode(resultNode,(xmlChar*)"rowset");
	if(catRowset == NULL){
		xmlFreeDoc(doc);
		return NO;
	}
	
	NSArray *certCats = [self privateParseCatRowset:catRowset];
	
	certCategories = [certCats retain];
	
	xmlFreeDoc(doc);
	
	return YES;
}

-(NSDictionary*) allCerts
{
	return allCerts;
}

-(CertTree*) initWithXml:(NSString*)xmlPath
{
	if((self = [super init])){
		allCerts = [[NSMutableDictionary alloc]init];
		[self privateParseXML:xmlPath];
	}
	
	return self;
}

-(void)dealloc
{
	[allCerts release];
	[certCategories release];
	[super dealloc];
}

-(NSInteger) catCount
{
	return [certCategories count];
}
-(CertCategory*) catAtIndex:(NSInteger)index
{
	return [certCategories objectAtIndex:index];
}

-(Cert*) certForID:(NSInteger)certID
{
	return [allCerts objectForKey:[NSNumber numberWithInteger:certID]];
}

@end
