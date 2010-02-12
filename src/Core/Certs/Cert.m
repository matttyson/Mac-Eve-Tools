//
//  Cert.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 25/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Cert.h"
#import "GlobalData.h"
#import "CertPair.h"
#import "CertTree.h"
#import "CertClass.h"

@implementation Cert

@synthesize certID;
@synthesize certGrade;
@synthesize certDescription;

@synthesize skillPrereqs;
@synthesize certPrereqs;

@synthesize parent;

-(void) dealloc
{
	[certDescription release];
	[skillPrereqs release];
	[certPrereqs release];
	[super dealloc];
}

-(NSString*)certGradeText
{
	NSString *grade;
	switch (certGrade) {
		case 1:
			grade = @"Basic";
			break;
		case 2:
			grade = @"Standard";
			break;
		case 3:
			grade = @"Improved";
			break;
		case 4:
			grade = @"Advanced";
			break;
		case 5:
			grade = @"Elite";
			break;
			
		default:
			grade = @"???";
	}
	
	return grade;
}

-(NSString*) fullCertName
{
	return [NSString stringWithFormat:@"%@ - %@",[parent certClassName],[self certGradeText]];
}


-(Cert*) initWithDetails:(NSInteger)cID 
				   grade:(NSInteger)cGrade 
					text:(NSString*)cDesc
				skillPre:(NSArray*)sPre
				 certPre:(NSArray*)cPre
			   certClass:(CertClass*)cC
{
	if((self = [super init])){
		certID = cID;
		certGrade = cGrade;
		certDescription = [cDesc retain];
		skillPrereqs = [sPre retain];
		certPrereqs = [cPre retain];
		parent = cC; //NOT RETAINED
	}
	return self;
}

+(Cert*) createCert:(NSInteger)cID 
			  grade:(NSInteger)cGrade 
			   text:(NSString*)cDesc
		   skillPre:(NSArray*)sPre
			certPre:(NSArray*)cPre
		  certClass:(CertClass*)cC
{
	Cert *c = [[Cert alloc]initWithDetails:cID 
									 grade:cGrade 
									  text:cDesc
								  skillPre:sPre
								   certPre:cPre
								 certClass:cC];
	return [c autorelease];
}

/*
 recursivley add all the prerequisites for this cert and all the subcerts.
 */
-(void) certSkillPrereqs:(NSMutableArray*)skillArray  forCert:(Cert*)c
{	
	//Do it in order of the most advanced cert first.
	[skillArray addObjectsFromArray:[c skillPrereqs]];
	
	for(CertPair *pair in [c certPrereqs]){
		Cert *preCert = [[[GlobalData sharedInstance]certTree]certForID:[pair certID]];
		[self certSkillPrereqs:skillArray forCert:preCert];
	}
}

-(NSArray*)certChainPrereqs
{
	NSMutableArray *ary = [[[NSMutableArray alloc]init]autorelease];
	
	[self certSkillPrereqs:ary forCert:self];
	
	return ary;
}

-(NSComparisonResult) gradeComparitor:(Cert*)rhs
{
	if(rhs->certGrade < self->certGrade){
		return NSOrderedAscending;
	}
	return NSOrderedDescending;
}


@end
