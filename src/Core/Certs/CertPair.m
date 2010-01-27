//
//  CertPair.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 25/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CertPair.h"


@implementation CertPair

@synthesize certID;
@synthesize grade;

-(CertPair*) initWithID:(NSInteger)cID certGrade:(NSInteger)cGrade
{
	if((self = [super init])){
		certID = cID;
		grade = cGrade;
	}
	return self;
}

+(CertPair*) createCertPair:(NSInteger)cID certGrade:(NSInteger)cGrade
{
	CertPair *cp = [[[CertPair alloc]initWithID:cID certGrade:cGrade]autorelease];
	return cp;
}

@end
