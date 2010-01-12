//
//  CCPTypeAttribute.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 6/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CCPTypeAttribute.h"


@implementation CCPTypeAttribute

@synthesize attributeID;

//@synthesize attributeName;
//@synthesize attributeDesc;

@synthesize displayName;
@synthesize unitDisplay;
@synthesize graphicID;

@synthesize valueInt;
@synthesize valueFloat;

-(CCPTypeAttribute*) init
{
	if((self = [super init])){
		
	}
	return self;
}

-(void)dealloc
{
	[displayName release];
	[unitDisplay release];
	[super dealloc];
}

+(CCPTypeAttribute*) createTypeAttribute:(NSInteger)attributeId 
								dispName:(NSString*)dispName
							 unitDisplay:(NSString*)unitDisp
							   graphicId:(NSInteger)gID
								valueInt:(NSInteger)vInt
							  valueFloat:(CGFloat)vFloat
{
	CCPTypeAttribute *ta = [[CCPTypeAttribute alloc]init];
	if(ta == nil){
		return nil;
	}
	
	ta->attributeID = attributeId;
	ta->displayName = [dispName retain];
	ta->unitDisplay = [unitDisp retain];
	ta->graphicID = gID;
	ta->valueInt = vInt;
	ta->valueFloat = vFloat;
	
	[ta autorelease];
	
	return ta;
	
}

@end
