//
//  AttributeModifierDatasource.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 29/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class Character;
@class SkillPointAttributeQueue;

@interface AttributeModifierDatasource : NSObject <NSTableViewDataSource> {
	Character *character;
	SkillPointAttributeQueue *attrQueue;
}

-(AttributeModifierDatasource*) initWithQueue:(SkillPointAttributeQueue*)queue 
								 forCharacter:(Character*)ch;


@end
