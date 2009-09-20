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
#import "METPluggableView.h"

#import "SkillTree.h"
#import "Character.h"

#import "SkillSearchView.h"

#import "SkillSearchCharacterDatasource.h"
#import "SkillSearchShipDatasource.h"

//#import "PlanTabView.h"
//#import "PlanSummaryView.h"
//#import "PlanView.h"
//#import "SkillPlanOverviewDatasource.h"
//#import "SkillPlanViewDatasource.h"

#import "PlanView2.h"
@class PlanView2Datasource;

/*
	This class is responsable for mananging the subviews that are used to build the skill planner interface,
	and also managing and building the skill plans
 */


@interface SkillPlanController : NSViewController 
	<METPluggableView, SkillSearchDelegate,SkillView2Delegate,NSSplitViewDelegate> 
{
	IBOutlet NSSplitView *splitView;
	
	IBOutlet SkillSearchView *skillSearchView;
	IBOutlet PlanView2 *skillView2;
	
	Character *activeCharacter; /*the character we are displaying*/	
	SkillTree *st; /*master skill tree*/
	
	/*datasources*/
	SkillSearchCharacterDatasource *skillCharDatasource; /*this is one possible datasource for the SkillSearchView*/
	SkillSearchShipDatasource *skillShipDatasource;
}

-(void) setCharacter:(Character*)c;

-(void) planAddSkillArray:(NSArray*)skills;



@end
