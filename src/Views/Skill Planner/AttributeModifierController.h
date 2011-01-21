//
//  AttributeModifierController.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 29/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Character;
@class SkillPlan;
@class SkillPointAttributeQueue;
@class AttributeModifierDatasource;


@interface AttributeModifierController : NSObject {
	IBOutlet NSTableView *skillPointTotals;
	
	IBOutlet NSTextField *lrnField;
	IBOutlet NSTextField *intField;
	IBOutlet NSTextField *perField;
	IBOutlet NSTextField *chrField;
	IBOutlet NSTextField *wilField;
	IBOutlet NSTextField *memField;
	
	IBOutlet NSStepper *lrnStepper;
	IBOutlet NSStepper *intStepper;
	IBOutlet NSStepper *perStepper;
	IBOutlet NSStepper *chrStepper;
	IBOutlet NSStepper *wilStepper;
	IBOutlet NSStepper *memStepper;
	
	IBOutlet NSTextField *intValue;
	IBOutlet NSTextField *perValue;
	IBOutlet NSTextField *chrValue;
	IBOutlet NSTextField *wilValue;
	IBOutlet NSTextField *memValue;
	
	IBOutlet NSTextField *origTrainTime;
	IBOutlet NSTextField *newTrainTime;
	IBOutlet NSTextField *diffTrainTime;
	
	IBOutlet NSTextField *totalAttributePoints;
	
	NSInteger intelligence;
	NSInteger perception;
	NSInteger charisma;
	NSInteger willpower;
	NSInteger memory;
	
	NSInteger totalPoints;
	
	NSInteger origTrainTimeSeconds;
	NSInteger newTrainTimeSeconds;
	
	IBOutlet NSButton *closeButton;
	IBOutlet NSPanel *sheet;
	
	Character *character;
	SkillPlan *plan;
	
	SkillPointAttributeQueue *attrQueue;
	AttributeModifierDatasource *attrDS;
}

-(void)setCharacter:(Character*)ch andPlan:(SkillPlan*)pl;

-(IBAction) closeButtonClick:(id)sender;
-(IBAction) resetButtonClick:(id)sender;

-(IBAction) willpowerUpdate:(id)sender;
-(IBAction) intelligenceUpdate:(id)sender;
-(IBAction) charismaUpdate:(id)sender;
-(IBAction) perceptionUpdate:(id)sender;
-(IBAction) memoryUpdate:(id)sender;
@end
