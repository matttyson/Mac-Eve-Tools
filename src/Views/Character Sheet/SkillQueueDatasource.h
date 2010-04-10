//
//  SkillQueueDatasource.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 10/04/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class SkillPlan;
@class Character;

@interface SkillQueueDatasource : NSObject <NSTableViewDataSource,NSTableViewDelegate> {
	SkillPlan *plan;
	Character *character;
	
	NSInteger firstSkillCountdown;
}

@property (nonatomic,readwrite,retain) SkillPlan* plan;
@property (nonatomic,readwrite,retain) Character* character;

@property (nonatomic,readwrite,assign) NSInteger firstSkillCountdown;

-(void)tick;

@end
