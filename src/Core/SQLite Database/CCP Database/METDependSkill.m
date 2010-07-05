//
//  METDependSkill.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 4/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "METDependSkill.h"


@implementation METDependSkill

@synthesize itemTypeID;
@synthesize itemName;
@synthesize itemSkillPreTypeID;
@synthesize itemSkillPreLevel;
@synthesize itemCategory;

-(METDependSkill*) initWithData:(NSInteger)itemTID 
					   itemName:(NSString*)iName 
					skillPreTID:(NSInteger)sPTID 
					skillPLevel:(NSInteger)sPL
				   itemCategory:(NSInteger)iCat
{
	if((self = [super init])){
		itemTypeID = itemTID;
		itemName = [iName retain];
		itemSkillPreTypeID = sPTID;
		itemSkillPreLevel = sPL;
		itemCategory = iCat;
	}
	return self;
}

-(void)dealloc
{
	[itemName release];
	[super dealloc];
}



@end
