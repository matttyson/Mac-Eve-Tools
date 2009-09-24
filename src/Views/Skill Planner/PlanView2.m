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

#import "PlanView2.h"
#import "macros.h"
#import "PlannerColumn.h"

#import "GlobalData.h"
#import "SkillPlan.h"
#import "PlanView2Datasource.h"
#import "Character.h"

//#import "MTSegmentedCellCategory.h"
#import "SkillDetailsWindowController.h"
#import "MTSegmentedCell.h"

#import "Helpers.h"
#import "Config.h"

#import "PlanIO.h"
#import "EvemonXmlPlanIO.h"

@interface PlanView2 (SkillView2Private)

-(void) loadPlan:(SkillPlan*)planIndex;
-(IBAction) displayPlanByPlanId:(NSInteger)tag;
-(void) switchColumns:(NSMutableArray*)colArray;

-(void) deleteSkillPlan:(NSIndexSet*)planIndexes;

-(void) removeSkillsFromPlan:(NSIndexSet*)skillIndexes;
-(void) removeSkillsPopupConfirmation:(NSArray*)antiPlan;
-(void) removeSkillSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

-(void) repositionButton;

@end

@implementation PlanView2 (SkillView2Private)

-(void) deleteSkillPlan:(NSIndexSet*)planIndexes
{
	NSUInteger rowsetCount = [planIndexes count];
	NSUInteger *ary = malloc(sizeof(NSUInteger) * rowsetCount);
	NSUInteger actual = [planIndexes getIndexes:ary maxCount:(sizeof(NSUInteger) * rowsetCount) inIndexRange:nil];
	
	for(NSUInteger i = 0; i < rowsetCount; i++){
		SkillPlan *plan = [character skillPlanAtIndex:ary[i]];
		if(plan == nil){
			continue;
		}
		[[segmentedButton cell]removeCellWithTag:[plan planId]];
		[character removeSkillPlan:plan];
		[segmentedButton setSelectedSegment:0];
		[self refreshPlanView];
	}
	free(ary);
}

-(void) removeSkillSheetDidEnd:(NSWindow *)sheet 
					returnCode:(NSInteger)returnCode 
				   contextInfo:(void *)contextInfo
{
	NSArray *antiPlan = contextInfo;
	if(returnCode == 1){
		[pvDatasource removeSkillsFromPlan:antiPlan];
		[self refreshPlanView];
	}
	[antiPlan release];
}

-(void) removeSkillsPopupConfirmation:(NSArray*)antiPlan
{
	if([antiPlan count] == 1){
		[pvDatasource removeSkillsFromPlan:antiPlan];
		[self refreshPlanView];
		return;
	}
	
	SkillTree *st = [[GlobalData sharedInstance]skillTree];
	
	NSRect panelRect = basePanelSize;
	
	NSMutableString *str = [[NSMutableString alloc]init];
	
	for(SkillPair *sp in antiPlan){
		Skill *s = [st skillForId:[sp typeID]];
		[str appendFormat:@"%@ %@\n",[s skillName],romanForInteger([sp skillLevel])];	
	}
	[planSkillList setStringValue:str];
	[str release];
	
	/*magic number. I can't seem to work out how to get the size of a text field, but this seems to work. fix later.*/
	//Note to self: attributed strings
	panelRect.size.height = basePanelSize.size.height + [antiPlan count] * 17; 
	
	[skillRemovePanel setFrame:panelRect display:YES];
	
	//[planSkillToRemove sizeToFit];
	[planSkillList sizeToFit];
	
	[NSApp beginSheet:skillRemovePanel
	   modalForWindow:[self window]
		modalDelegate:self
	   didEndSelector:@selector(removeSkillSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:[antiPlan retain]];
}

-(void) removeSkillsFromPlan:(NSIndexSet*)rowset
{
	NSUInteger rowsetCount = [rowset count];
	NSUInteger *ary = malloc(sizeof(NSUInteger) * rowsetCount);
	NSUInteger actual = [rowset getIndexes:ary maxCount:(sizeof(NSUInteger) * rowsetCount) inIndexRange:nil];
	
	assert(actual == rowsetCount);
	
	NSArray *antiPlan = [[pvDatasource currentPlan] constructAntiPlan:ary arrayLength:rowsetCount];
	free(ary);
	
	[self removeSkillsPopupConfirmation:antiPlan];
}

/*This is for the new plan sheet*/
- (void)sheetDidEnd:(NSWindow *)sheet 
		 returnCode:(NSInteger)returnCode 
		contextInfo:(void *)contextInfo
{	
	if(returnCode != 1){
		[newPlanName setObjectValue:nil];
		return;
	}
	
	NSString *str = [newPlanName stringValue];
	
	if([str length] == 0){
		return;
	}
	
	SkillPlan *plan = [delegate createNewPlan:str];
	
	if(plan != nil){
		[self refreshPlanView];
		[self loadPlan:plan];
		[self displayPlanByPlanId:[plan planId]];
	}
	[newPlanName setObjectValue:nil];
}


-(void) switchColumns:(NSMutableArray*)colArray
{
	NSArray *tableCols = [[tableView tableColumns]copy];
	for(NSTableColumn *col in tableCols){
		[tableView removeTableColumn:col];
	}
	[tableCols release];
	
	for(NSTableColumn *col in colArray){
		[tableView addTableColumn:col];
	}
}

-(void) loadPlan:(SkillPlan*)plan;
{
	//SkillPlan *plan = [character skillPlanAtIndex:planIndex];
	
	if(![[segmentedButton cell]selectSegmentWithTag:[plan planId]]){
		NSInteger buttonCount = [segmentedButton segmentCount];
		[segmentedButton setSegmentCount:buttonCount + 1];
		[[segmentedButton cell]setTag:[plan planId] forSegment:buttonCount];
		[[segmentedButton cell]setLabel:[plan planName] forSegment:buttonCount];
		[[segmentedButton cell]selectSegmentWithTag:[plan planId]];
		[segmentedButton sizeToFit];
		[self repositionButton];
	}
	[self displayPlanByPlanId:[plan planId]];
}

-(void) repositionButton
{
	NSRect newSize = [segmentedButton frame];
	NSRect viewSize = [self bounds];
	newSize.origin.x = (viewSize.size.width / 2) - (newSize.size.width / 2);
	[segmentedButton setFrameOrigin:newSize.origin];
}

-(void)toobarMessageForPlan:(SkillPlan*)plan
{
	NSString *trainingTime = stringTrainingTime([plan trainingTime]);
	NSString *message = [NSString stringWithFormat:@"%ld skills planned. Total training time: %@",
						 [plan skillCount],trainingTime];
	[delegate setToolbarMessage:message];
}

/*-1 is a special plan ID which triggers the overview*/
-(IBAction) displayPlanByPlanId:(NSInteger)tag
{
	if(tag == currentTag){
		return;
	}
	
	if(tag == -1){ //if we are switching to the overview
		[self switchColumns:overviewColumns];
		[pvDatasource setMode:SPMode_overview];
		[delegate setToolbarMessage:nil];
	}else if(currentTag == -1){ //if we are switching FROM the overview
		[self switchColumns:skillPlanColumns];
		[pvDatasource setMode:SPMode_plan];
		[pvDatasource setPlanId:tag];
	}else{ // we are switching from plan A to plan B
		[pvDatasource setPlanId:tag];
	}
	
	currentTag = tag;
	[self refreshPlanView];
}

@end


@implementation PlanView2

@synthesize delegate;

-(void) refreshPlanView
{
	[tableView reloadData];
	if([pvDatasource mode] == SPMode_plan){
		[self toobarMessageForPlan:[pvDatasource currentPlan]];
	}
}

-(void) buildSkillPlanColumnArray
{
	NSTableColumn *col;
	
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"skill_plan_config"];
	NSArray *ary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	for(PlannerColumn *pcol in ary){
		if([pcol active]){
			col = [[NSTableColumn alloc]initWithIdentifier:[pcol identifier]];
			[col setWidth:[pcol columnWidth]];
			[[col headerCell]setStringValue:[pcol columnName]];
			[skillPlanColumns addObject:col];
			[col release];
		}
	}
}

-(void) buildSkillOverviewColumnArray
{
	NSTableColumn *col;
	
	col = [[NSTableColumn alloc]initWithIdentifier:COL_POV_NAME];
	[col setWidth:270.0];
	[[col headerCell]setStringValue:@"Plan Name"];
	[overviewColumns addObject:col];
	[col release];
	
	col = [[NSTableColumn alloc]initWithIdentifier:COL_POV_SKILLCOUNT];
	[col setWidth:90.0];
	[[col headerCell]setStringValue:@"Skill Count"];
	[overviewColumns addObject:col];
	[col release];

	col = [[NSTableColumn alloc]initWithIdentifier:COL_POV_TIMELEFT];
	[col setWidth:160.0];
	[[col headerCell]setStringValue:@"Training Time"];
	[overviewColumns addObject:col];
	[col release];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		overviewColumns = [[NSMutableArray alloc]init];
		skillPlanColumns = [[NSMutableArray alloc]init];
		pvDatasource = [[PlanView2Datasource alloc]init];
		[pvDatasource setViewDelegate:self];
		[self buildSkillOverviewColumnArray];
		[self buildSkillPlanColumnArray];
		currentTag = -1;
	}
	return self;
}

-(void) dealloc
{
	[overviewColumns release];
	[skillPlanColumns release];
	[character release];
	[pvDatasource release];
	[super dealloc];
}

-(void) awakeFromNib
{
	[self switchColumns:overviewColumns];
	[pvDatasource setMode:SPMode_overview];
	[tableView setDataSource:pvDatasource];
	
	[tableView registerForDraggedTypes:[NSArray arrayWithObjects:MTSkillArrayPBoardType,MTSkillIndexPBoardType,nil]];
	
	[tableView setDelegate:self];
	[tableView setTarget:self];
	[tableView setDoubleAction:@selector(rowDoubleClick:)];
	
	basePanelSize = [skillRemovePanel frame];
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
}

-(IBAction) plusMinusButtonClick:(id)sender
{
	NSInteger tag = [sender tag];
	
	if(tag == TAG_PLUS_BUTTON){
		[NSApp beginSheet:newPlan
		   modalForWindow:[self window]
			modalDelegate:self
		   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
			  contextInfo:NULL];
		
	}else if(tag == TAG_MINUS_BUTTON){
		if([tableView selectedRow] == -1){
			return;
		}
		
		NSInteger segment = [segmentedButton selectedSegment];
		if(segment == 0){
			[self deleteSkillPlan:[tableView selectedRowIndexes]];
		}else{
			/*	This code will delete the plan, which on 2nd thought is not what we want at all.
			NSInteger planId = [[segmentedButton cell] tagForSegment:[segmentedButton selectedSegment]];
			[[segmentedButton cell]removeCellAtIndex:segment];
			[character removeSkillPlanById:planId];
			[segmentedButton setSelectedSegment:0];
			[self displayPlanByPlanId:-1];
			*/
			[self removeSkillsFromPlan:[tableView selectedRowIndexes]];
		}
	}
}

-(IBAction) planButtonClick:(id)sender
{
	[NSApp endSheet:newPlan returnCode:[sender tag]];
	[newPlan orderOut:sender];
}
-(IBAction) antiPlanButtonClick:(id)sender
{
	[NSApp endSheet:skillRemovePanel returnCode:[sender tag]];
	[skillRemovePanel orderOut:sender];
}

/*this is for importing a plan*/
-(void) importSheetDidEnd:(NSWindow *)sheet 
			   returnCode:(NSInteger)returnCode 
			  contextInfo:(NSString *)filePath
{
	[filePath autorelease];
	
	NSString *planName = [newPlanName stringValue];
	
	SkillPlan *plan = [delegate createNewPlan:planName];
	if(plan == nil){
		NSLog(@"Failed to create plan %@",planName);
		return;
	}
	
	/*import the evemon plan*/
	PlanIO *pio = [[EvemonXmlPlanIO alloc]init];
	
	BOOL rc = [pio read:filePath intoPlan:plan];
	
	[PlanIO release];
	
	if(!rc){
		NSLog(@"Failed to read plan!");
		[character removeSkillPlan:plan];
	}else{
		//If we are in overview mode, reload the datasource
		if([pvDatasource mode] == SPMode_overview){
			[self refreshPlanView];
		}
	}
}

-(void) performPlanImport:(NSString*)filePath
{
	[NSApp beginSheet:newPlan
	   modalForWindow:[NSApp mainWindow]//[self window]
		modalDelegate:self
	   didEndSelector:@selector(importSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:[filePath retain]];
}

-(IBAction) segmentedButtonClick:(id)sender
{
	NSInteger tag = [[sender cell]tagForSegment:[sender selectedSegment]];
	[self displayPlanByPlanId:tag];
}

-(void) rowDoubleClick:(id)sender
{
	NSInteger selectedRow = [sender selectedRow];
	
	if(selectedRow == -1){
		return;
	}
	
	if([pvDatasource mode] == SPMode_overview){
		/*if this is in skill plan mode, */
		SkillPlan *plan = [character skillPlanAtIndex:selectedRow];
		[self loadPlan:plan];
	}else{
		/*we are in skill view mode. display a popup window for that skill*/
		NSNumber *typeID = [[[character skillPlanById:[pvDatasource planId]]skillAtIndex:selectedRow]typeID];
		[SkillDetailsWindowController displayWindowForTypeID:typeID forCharacter:character];
	}
}


-(void) setCharacter:(Character*)c
{
	if(c == character){
		return;
	}
	
	[character release];
	character = [c retain];
	[segmentedButton setSegmentCount:1];
	[pvDatasource setCharacter:c];
	[self displayPlanByPlanId:-1];
	[self refreshPlanView];
}

-(Character*) character
{
	return character;
}

#pragma mark TableView Delegate methods

-(void) tableView:(NSTableView*)aTableView keyDownEvent:(NSEvent*)theEvent
{
	NSString *chars = [theEvent characters];
	if([chars length] == 0){
		return;
	}
	unichar ch = [chars characterAtIndex:0];
	/*if the user pressed a delete key, delete all the selected skills or plans*/
	if((ch == NSDeleteCharacter) || (ch == NSBackspaceCharacter) || (ch == NSDeleteFunctionKey))
	{	
		NSIndexSet *rowset = [tableView selectedRowIndexes];
		
		if([rowset count] > 0){
			if([pvDatasource mode] == SPMode_plan){
				[self removeSkillsFromPlan:rowset];
			}else if([pvDatasource mode] == SPMode_overview){
				[self deleteSkillPlan:rowset];
			}
		}
	}
}
 /*menu delegates*/
-(void) removeSkillPlanFromOverview:(id)sender
{
	NSNumber *planId = [sender representedObject];
	[self deleteSkillPlan:[NSIndexSet indexSetWithIndex:[planId unsignedIntegerValue]]];
}

-(void) removeSkillFromPlan:(id)sender
{
	NSNumber *planId = [sender representedObject];
	[self removeSkillsFromPlan:[NSIndexSet indexSetWithIndex:[planId unsignedIntegerValue]]];
}

-(void) addSkillArrayToActivePlan:(NSArray*)skillArray
{
	[pvDatasource addSkillArrayToActivePlan:skillArray];
	[[pvDatasource currentPlan]savePlan];
	[self refreshPlanView];
}

- (BOOL)tableView:(NSTableView *)aTableView 
shouldEditTableColumn:(NSTableColumn *)aTableColumn 
			  row:(NSInteger)rowIndex
{
	return NO;
}

- (void)tableViewColumnDidResize:(NSNotification *)aNotification
{
	NSTableColumn *col = [[aNotification userInfo]objectForKey:@"NSTableColumn"];
	NSLog(@"resized %@ to %.2f",[col identifier],(double)[col width]);
	
	//Save the column width
}


@end