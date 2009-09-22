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

enum SkillPlanMode{
	SPMode_overview,
	SPMode_plan,
	SPMode_none
};

@class Character;
@class SkillPlan;

@protocol PlanView2Delegate

/*called when you want to update the */
-(void) refreshPlanView;

@end


@interface PlanView2Datasource : NSObject <NSTableViewDelegate, NSTableViewDataSource> {
	NSDictionary *masterSkillSet;
	Character *character;
	NSInteger planId;
	enum SkillPlanMode mode;
	id<PlanView2Delegate> viewDelegate;
}

@property (readwrite,nonatomic) NSInteger planId;
@property (readwrite,nonatomic) enum SkillPlanMode mode;

-(id) init;

-(void) setViewDelegate:(id<PlanView2Delegate>)delegate;

-(Character*) character;
-(void) setCharacter:(Character*)c;

/*returns the current skill plan, or nil if no skill plan is available*/
-(SkillPlan*) currentPlan;

/*remove these skills from the current plan*/
-(void) removeSkillsFromPlan:(NSArray*)antiPlan;

-(void) addSkillArrayToActivePlan:(NSArray*)skillArray;

@end
