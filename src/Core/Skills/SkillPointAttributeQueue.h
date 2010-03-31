//
//  SkillPointAttributeQueue.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 31/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Character;
@class SkillPlan;

@interface SkillPointAttributeQueue : NSObject {
	NSMutableArray *queue;
}

-(SkillPointAttributeQueue*)init;


-(void) addSkillPoints:(NSInteger)skillPoints 
		   primaryAttr:(NSInteger)primary
		 secondaryAttr:(NSInteger)secondary;

/*number of skill attribute objects in this queue*/
-(NSUInteger) count;
/*calculate the training time for an individual entry*/
-(NSInteger) trainingTimeForIndex:(NSUInteger)index withCharacter:(Character*)character;

-(NSInteger) primaryAttributeForIndex:(NSUInteger)index;
-(NSInteger) secondaryAttributeForIndex:(NSUInteger)index;
-(NSInteger) skillPointsForIndex:(NSUInteger)index;

/*calculate the total queue training time for the given character*/
-(NSInteger) calculateTrainingTimeForCharacter:(Character*)character;

-(void) addPlanToQueue:(SkillPlan*)plan;

@end
