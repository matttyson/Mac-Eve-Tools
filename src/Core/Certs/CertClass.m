//
//  CertClass.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 25/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CertClass.h"


@implementation CertClass

@synthesize classID;
@synthesize certClassName;

-(void)dealloc
{
	[certClassName release];
	[certArray release];
	[super dealloc];
}

-(CertClass*)initWithClass:(NSInteger)cID desc:(NSString*)cDesc
{
	if((self = [super init])){
		classID = cID;
		certClassName = [cDesc retain];
	}
	return self;
}

+(CertClass*) createCertClass:(NSInteger)cID desc:(NSString*)cDesc
{
	CertClass *class = [[CertClass alloc]initWithClass:cID desc:cDesc];
	return [class autorelease];
}

-(NSInteger)certCount
{
	return [certArray count];
}

-(Cert*) certAtIndex:(NSInteger)index
{
	return [certArray objectAtIndex:index];
}

-(void) setCertArray:(NSArray*)cArray
{
	[certArray release];
	certArray = [cArray retain];
}


@end
