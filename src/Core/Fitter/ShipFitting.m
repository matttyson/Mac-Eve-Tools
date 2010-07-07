//
//  ShipFitting.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 20/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ShipFitting.h"
#import "GlobalData.h"
#import "CCPDatabase.h"

@implementation ShipFitting

-(void)dealloc
{
	[shipSlots release];
	[shipBaseAttributes release];
	[super dealloc];
}

-(ShipFitting*) initWithTypeID:(NSInteger)tID
{
	if((self = [super init])){
		typeID = tID;
		shipSlots = [[NSMutableDictionary alloc]init];
		shipBaseAttributes = [[[GlobalData sharedInstance]database]attributesForType:tID];
	}
	return self;
}

-(NSInteger) slotCount:(enum SlotType)slotType
{
	
}

@end
