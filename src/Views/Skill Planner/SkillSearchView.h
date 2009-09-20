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

/*
This class should display the possible skill choices to the user.

 it is a bridge between the SkillSearchView and the SkillPlanController class
*/

@protocol SkillSearchDatasource

/*
 must implement the NSOutlineView datasource delegates
 the right click delegate in MTTableView.h (retard apple)
*/

-(NSString*) skillSearchName; /*the name of the datasource to display in the segment button */

/*this will be called with a search string the user wants to search for.*/
-(void) skillSearchFilter:(id)sender;


@end


/*the skill search view will call these methods when it wants to do something or other*/
@protocol SkillSearchDelegate

/*these delegates will be called when the user wants to add a skill to the plan.*/

/*return an NSArray of SkillPrerequisite objects to be added to the plan*/
-(void) planAddSkillArray:(NSArray*)skills; 

/*the character we are operating on*/
-(Character*) character;

@end


@interface SkillSearchView : NSView <NSOutlineViewDelegate, NSOutlineViewDataSource>
{
	IBOutlet NSTextField *filter; /*label*/
	IBOutlet NSSearchField *search; /**/
	
	IBOutlet NSSegmentedControl *skillSearchCategories; /*skill, ship etc*/
	IBOutlet NSSegmentedControl *skillGroups; /*trained, not trained etc*/
	
	IBOutlet NSOutlineView *skillList; /*list of all skills in the game*/
	
	NSInteger currentDatasource;
	NSMutableArray *datasources;
	id<SkillSearchDelegate> delegate;
}

-(id<SkillSearchDelegate>) delegate;
-(void) setDelegate:(id<SkillSearchDelegate>)del;

-(void) reloadDatasource:(id<SkillSearchDatasource>) ds; /*notifiy the outline view that the datasouce has changed*/
-(void) addDatasource:(id<SkillSearchDatasource>)anObject;
-(void) removeDatasources; /*reset the array*/

-(void) menuAddSkillClick:(id)sender;

-(IBAction) skillSearchCategoriesClick:(id)sender;
-(IBAction) skillGroupsClick:(id)sender;

/*load the Skills panel. nasty hack*/
-(void) selectDefaultGroup;


@end
