//
//  CertCategory.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 25/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CertCategory.h"

#import "CertClass.h"

@implementation CertCategory

@synthesize catName;
@synthesize categoryID;

-(void)dealloc
{
	[catName release];
	[classArray release];
	[super dealloc];
}

-(CertCategory*) initWithClasses:(NSInteger)cID name:(NSString*)cName cClass:(NSArray*)cClasses
{
	if((self = [super init])){
		categoryID = cID;
		catName = [cName retain];
		classArray = [cClasses retain];
	}
	return self;
}

+(CertCategory*) createCertCategory:(NSInteger)cID name:(NSString*)cName cClass:(NSArray*)cClasses
{
	CertCategory *cc = [[CertCategory alloc]initWithClasses:cID
													   name:cName
													 cClass:cClasses];
	return [cc autorelease];
}

-(NSInteger) classCount
{
	return [classArray count];
}

-(CertClass*) classAtIndex:(NSInteger)index
{
	return [classArray objectAtIndex:index];
}


@end
