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

-(NSDictionary*) allCerts
{
	return allCerts;
}

/*
-(CertTree*) initWithXml:(NSString*)xmlPath
{
	NSLog(@"Certs from XML has been removed. use the database");
	[self doesNotRecognizeSelector:_cmd];
}
 */

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

-(CertTree*) initWithCats:(NSArray*)certCats 
				  andDict:(NSDictionary*)dict
{
	if((self = [super init])){
		certCategories = [certCats retain];
		allCerts = [dict retain];
	}
	return self;
}

+(CertTree*) createCertTree:(NSArray*)certCats 
				   certDict:(NSDictionary*)certs
{
	CertTree *tree = [[CertTree alloc]initWithCats:certCats andDict:certs];
	[tree autorelease];
	return tree;
}

@end
