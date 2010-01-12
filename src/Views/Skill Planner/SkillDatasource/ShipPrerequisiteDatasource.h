//
//  ShipPrerequisiteDatasource.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 9/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CCPType;
@class Character;

@interface ShipPrerequisiteDatasource : NSObject <NSOutlineViewDataSource> {
	CCPType *ship;
	Character *character;
}

-(ShipPrerequisiteDatasource*) initWithShip:(CCPType*)type forCharacter:(Character*)ch;

@end
