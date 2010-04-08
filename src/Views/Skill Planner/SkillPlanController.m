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

#import "SkillPlanController.h"
#import "GlobalData.h"
#import "SkillSearchView.h"
#import "Helpers.h"
#import "PlanView2Datasource.h"

/*datasources*/
#import "SkillSearchCharacterDatasource.h"
#import "SkillSearchShipDatasource.h"
#import "SkillSearchCertDatasource.h"

#import "METInstance.h"

@interface SkillPlanController (SkillPlanControllerPrivate)

/*delegate methods for the splitting panel*/
- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset;
//- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset;
- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize;

/*private methods for managing the panels*/

@end


@implementation SkillPlanController (SkillPlanControllerPrivate) 

- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset
{
	if(offset == 0){
		return [[[sender subviews] objectAtIndex:offset]bounds].size.width;
	}
	return proposedMin;
}

/*
- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset
{
	return proposedMax;
}
*/

/*
	FFS. you think they could make the splitview come with code like this built in. it must
	be a fairly common way to want the view to resize.
 */
- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{	
	// http://www.wodeveloper.com/omniLists/macosx-dev/2003/May/msg00261.html
	// http://snipplr.com/view/2452/resize-nssplitview-nicely/
	// grab the splitviews
    NSView *left = [[sender subviews] objectAtIndex:0];
    NSView *right = [[sender subviews] objectAtIndex:1];
	
	CGFloat minLeftWidth = [skillSearchView bounds].size.width;
    CGFloat dividerThickness = [sender dividerThickness];
	
	// get the different frames
    NSRect newFrame = [sender frame];
    NSRect leftFrame = [left frame];
    NSRect rightFrame = [right frame];
	
	// change in width for this redraw
	CGFloat	dWidth  = newFrame.size.width - oldSize.width;
	
	// ratio of the left frame width to the right used for resize speed when both panes are being resized
	CGFloat rLeftRight = (leftFrame.size.width - minLeftWidth) / rightFrame.size.width;
	
	// resize the height of the left
    leftFrame.size.height = newFrame.size.height;
    leftFrame.origin = NSMakePoint(0,0);
	
	// resize the left & right pane equally if we are shrinking the frame
	// resize the right pane only if we are increasing the frame
	// when resizing lock at minimum width for the left panel
	if(leftFrame.size.width <= minLeftWidth && dWidth < 0) {
		rightFrame.size.width += dWidth;
	} else if(dWidth > 0) {
		rightFrame.size.width += dWidth;
	} else {
		leftFrame.size.width += dWidth * rLeftRight;
		rightFrame.size.width += dWidth * (1 - rLeftRight);
	}
	
	rightFrame.size.width = newFrame.size.width - leftFrame.size.width - dividerThickness;
	rightFrame.size.height = newFrame.size.height;
	rightFrame.origin.x = leftFrame.size.width + dividerThickness;
	
	[left setFrame:leftFrame];
	[right setFrame:rightFrame];
}

#pragma mark characterDidUpdate
-(void) characterDidUpdate:(Character*)c didSucceed:(BOOL)success docPath:(NSString*)docPath
{
	if(success && [docPath isEqualToString:XMLAPI_CHAR_SHEET]){
		[skillCharDatasource setCharacter:c];
		[skillSearchView reloadDatasource:skillCharDatasource]; /*datasouce has changed.*/
	}
}

@end


@implementation SkillPlanController

-(SkillPlanController*) init
{
	if((self = [super initWithNibName:@"SkillPlan" bundle:nil])){
		
	}
	return self;
}


-(void) awakeFromNib
{
	st = [[[GlobalData sharedInstance]skillTree] retain];
	
	/*Add the subviews. skillSearchView on the left, and the plan view on the right*/
	[splitView addSubview:skillSearchView];
	//[splitView addSubview:planTabView];
	[splitView addSubview:skillView2];
	[splitView setPosition:([skillSearchView bounds].size.width) ofDividerAtIndex:0];
	
	[splitView setDelegate:self]; /*to control the resizing*/
	[skillSearchView setDelegate:self]; /*this class will receive notifications about skills that have been selected*/
	
	skillCharDatasource = [[SkillSearchCharacterDatasource alloc]init];
	[skillCharDatasource setSkillTree:st];
	if(activeCharacter != nil){
		[skillCharDatasource setCharacter:activeCharacter];
	}
	[skillSearchView addDatasource:skillCharDatasource];
	
	skillCertDatasource = [[SkillSearchCertDatasource alloc]init];
	if(skillSearchView != nil){
		[skillSearchView addDatasource:skillCertDatasource];
	}	
	
	skillShipDatasource = [[SkillSearchShipDatasource alloc]initWithCategory:DB_CATEGORY_SHIP];
	if(skillShipDatasource != nil){
		[skillSearchView addDatasource:skillShipDatasource];
	}
		
	[skillView2 setDelegate:self];
}

-(void) dealloc
{
	[super dealloc];
}

#pragma mark METPluggableView stuff

-(void) setCharacter:(Character*)c
{
	if(c == nil){
		return;
	}
	if(c == activeCharacter){
		return;
	}
	if(activeCharacter != nil){
		[activeCharacter release];
	}

	[skillView2 setCharacter:c];
	
	activeCharacter = [c retain];
	
	[skillCharDatasource setCharacter:c];
	[skillSearchView reloadDatasource:skillCharDatasource]; /*datasouce has changed.*/
}

-(Character*) character;
{
	return activeCharacter;
}

-(void) viewIsInactive
{	
	if(activeCharacter != nil){
		[activeCharacter release];
		activeCharacter = nil;
	}
}

-(void) viewIsActive
{
	[skillCharDatasource setSkillTree:st];
	[skillCharDatasource setCharacter:activeCharacter];
	
	[skillSearchView reloadDatasource:skillCharDatasource];
	[skillSearchView selectDefaultGroup];
	
	[skillView2 refreshPlanView];
}

-(void) viewWillBeDeactivated
{
}
-(void) viewWillBeActivated
{
}

/*construct the toolbar menu*/
-(NSMenuItem*) menuItems
{
	NSMenu *menu;
	NSMenuItem *topLevel;
	NSMenuItem *item;
	
	topLevel = [[NSMenuItem allocWithZone:[NSMenu menuZone]]initWithTitle:@"Planner"
																   action:NULL
															keyEquivalent:@""];
	[topLevel autorelease];
	
	menu = [[NSMenu allocWithZone:[NSMenu menuZone]]initWithTitle:@"Planner"];
	[topLevel setSubmenu:menu];
	[menu release];
	
	
	item = [[NSMenuItem alloc]initWithTitle:@"Import Plan" 
									 action:@selector(importEvemonPlan:)
							  keyEquivalent:@""];
	[item setTarget:self];
	[menu addItem:item];
	[item release];
	
	item = [[NSMenuItem alloc]initWithTitle:@"Export Plan"
									 action:@selector(exportEvemonPlan:) 
							  keyEquivalent:@""];
	[item setTarget:self];
	[menu addItem:item];
	[item release];
	
	return topLevel;
}

-(NSView*) view
{
	return [super view];
}


/*Skill search delegate controls.  called when the SkillSearchView wants to add a skill to a plan*/
#pragma mark SkillSearchViewDelegate

-(void) planAddSkillArray:(NSArray*)skills
{
	[skillView2 addSkillArrayToActivePlan:skills];
}

#pragma mark SkillView2Delegate

-(SkillPlan*) createNewPlan:(NSString*)planName;
{
	SkillPlan *plan = [activeCharacter createSkillPlan:planName];
	
	return plan;
}


/*planid is the index in the array of skill plans*/
-(BOOL) removePlan:(NSInteger)planId
{
	SkillPlan *sp = [activeCharacter skillPlanAtIndex:planId];
	if(sp == nil){
		NSLog(@"SkillPlan %ld not found in character %@",planId,[activeCharacter characterName]);
		return NO;
	}
	
	[activeCharacter removeSkillPlanAtIndex:planId];
	return YES;
}

-(BOOL) planMovedFromIndex:(NSInteger)from toIndex:(NSInteger)to
{
	return NO;
}

#pragma mark Plan import / export

-(void) importEvemonPlan:(id)sender
{
	NSOpenPanel *op = [NSOpenPanel openPanel];
	[op setCanChooseDirectories:NO];
	[op setCanChooseFiles:YES];
	[op setAllowsMultipleSelection:NO];
	[op setAllowedFileTypes:[NSArray arrayWithObjects:@"emp",@"xml",nil]];
	
	if([op runModal] == NSFileHandlingPanelCancelButton){
		return;
	}
	
	if([[op URLs]count] == 0){
		return;
	}
	
	NSURL *url = [[op URLs]objectAtIndex:0];
	if(url == nil){
		return;
	}
	
	/*
	 now we import the plan.
	 the evemon format doesn't have the plan name encoded
	 in the xml (and there could be a clash anyway) so prompt
	 the user for the plan name.
	 */
	[skillView2 performPlanImport:[url path]];
}

-(void) exportEvemonPlan:(id)sender
{
	[skillView2 performPlanExport:@""];
}

-(void) setInstance:(id<METInstance>)instance
{
	//Don't retain.
	mainApp = instance;
}

-(void) setToolbarMessage:(NSString *)message
{
	//Set a permanat message
	[mainApp setToolbarMessage:message];
}

-(void) setToolbarMessage:(NSString*)message time:(NSInteger)seconds
{
	[mainApp setToolbarMessage:message time:seconds];
}



@end
