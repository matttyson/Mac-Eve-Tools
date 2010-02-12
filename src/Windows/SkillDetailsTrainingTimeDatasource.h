//
//  SkillDetailsTrainingTimeDatasource.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 12/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Skill;
@class Character;

@interface SkillDetailsTrainingTimeDatasource : NSObject <NSTableViewDataSource> {
	Skill *skill;
	Character *character;
}

-(id) initWithSkill:(Skill*)s forCharacter:(Character*)ch;

@end
