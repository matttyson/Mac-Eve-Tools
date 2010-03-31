//
//  SkillAttributeTotal.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 29/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SkillPointAttributeTotal.h"


@implementation SkillPointAttributeTotal

@synthesize primary;
@synthesize secondary;
@synthesize skillPoints;

+(NSUInteger) keyForPrimary:(NSInteger)pri andSecondary:(NSInteger)sec
{
	return (pri << 8) | sec;
}

-(void) addSkillPoints:(NSInteger)points
{
	skillPoints += points;
}

-(BOOL) isEqual:(SkillPointAttributeTotal*)object
{
	if(self.primary == object.primary){
		if(self.secondary == object.secondary){
			return YES;
		}
	}
	return NO;
}

-(NSUInteger)hash
{
	return [SkillPointAttributeTotal keyForPrimary:primary andSecondary:secondary];
}

-(SkillPointAttributeTotal*) initWithPrimary:(NSInteger)pri andSecondary:(NSInteger)sec
{
	self = [super init];
	if(self != nil){
		primary = pri;
		secondary = sec;
		skillPoints = 0;
	}
	return self;
}

-(NSComparisonResult) sortBySkillPoints:(SkillPointAttributeTotal*)rhs
{
	return skillPoints < rhs.skillPoints;
}

@end
