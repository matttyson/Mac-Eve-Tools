/*
 This file is part of Mac Eve Tools.
 
 Mac Eve Tools is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Mac Eve Tools is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Mac Eve Tools.  If not, see <http://www.gnu.org/licenses/>.
 
 Copyright Matt Tyson, 2009.
 */

#import <Cocoa/Cocoa.h>

#import "METInstance.h"
#import "PlanView2Datasource.h"
#import "AttributeModifierController.h"

@class SkillPlan;

@protocol SkillView2Delegate <METInstance>

/*
 the plan summary wants to create a new plan
 returns YES on success. NO if a plan was not created
 */
-(SkillPlan*) createNewPlan:(NSString*)name;

/*
 Remove a plan from the queue
 YES on success NO on failure
 */
-(BOOL) removePlan:(NSInteger)planId;

/*
 the user wants to move the plan in the plan list
 return YES if allowed, NO if not
 */
-(BOOL) planMovedFromIndex:(NSInteger)from toIndex:(NSInteger)to;

@end

@class PlanView2Datasource;
@class Character;

@interface PlanView2 : NSView <NSTableViewDelegate,PlanView2Delegate> {
	IBOutlet NSButton *plusButton;
	IBOutlet NSButton *minusButton;
	IBOutlet NSButton *attributeModifierButton;
	
	IBOutlet NSSegmentedControl *segmentedButton;
	IBOutlet NSTableView *tableView;
	
	IBOutlet NSPanel *newPlan;
	IBOutlet NSTextField *newPlanName;
	
	IBOutlet NSPanel *skillRemovePanel;
	IBOutlet NSTextField *planSkillList;
	
	IBOutlet AttributeModifierController *attributeModifier;
	IBOutlet NSPanel *attributeModifierPanel;
	
	NSRect basePanelSize;
	
	NSMutableArray *overviewColumns;
	NSMutableArray *skillPlanColumns;
	
	PlanView2Datasource *pvDatasource;
	
	Character *character;
	
	NSInteger currentTag;
	
	id<SkillView2Delegate> delegate;
}

@property (readwrite,nonatomic,assign) id<SkillView2Delegate> delegate;

-(IBAction) plusMinusButtonClick:(id)sender;
-(IBAction) segmentedButtonClick:(id)sender;
-(IBAction) planButtonClick:(id)sender;
-(IBAction) antiPlanButtonClick:(id)sender;

-(IBAction) attributeModifierButtonClick:(id)sender;

-(void) addSkillArrayToActivePlan:(NSArray*)skillArray;

-(void) setCharacter:(Character*)c;
-(Character*) character;

//Import a plan at this path
-(void) performPlanImport:(NSString*)filePath;


-(void) refreshPlanView;

@end
