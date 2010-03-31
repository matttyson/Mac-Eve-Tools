//
//  SkillAttribute.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 29/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SkillAttribute.h"


@implementation SkillAttribute

@synthesize valueInt;
@synthesize valueFloat;
@synthesize isInt;
@synthesize attributeID;


-(SkillAttribute*) initWithAttributeID:(NSInteger)attrID 
							  intValue:(NSInteger)valInt
							floatValue:(CGFloat)valFloat
							   valType:(BOOL)type
{
	if((self = [super init])){
		attributeID = attrID;
		valueInt = valInt;
		valueFloat = valFloat;
		isInt = type;
	}
	
	return self;	
}

@end
