//
//  SkillPrerequisiteDatasource.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 12/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Skill;
@class Character;

@interface SkillPrerequisiteDatasource : NSObject <NSOutlineViewDataSource>{
	NSArray *skills;
	Character *character;
}

/*
	An array of skills that are the prerequisites
 */
-(id) initWithSkill:(NSArray*)s forCharacter:(Character*)ch;

@end
