//
//  ShipAttributeDatasource.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 9/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CCPType;
@class CCPDatabase;
@class Character;


@interface ShipAttributeDatasource : NSObject <NSOutlineViewDataSource> {
	CCPType *ship;
	CCPDatabase *db;
	Character *character;
	
	NSMutableArray *attributes;
}

-(ShipAttributeDatasource*) initWithShip:(CCPType*)type forCharacter:(Character*)ch;

@end
