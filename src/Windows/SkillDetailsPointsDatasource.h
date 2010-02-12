//
//  SkillDetailsPointsDatasource.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 12/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Skill;

@interface SkillDetailsPointsDatasource : NSObject <NSTableViewDataSource> {
	Skill *skill;
}

-(id) initWithSkill:(Skill*)s;

@end
