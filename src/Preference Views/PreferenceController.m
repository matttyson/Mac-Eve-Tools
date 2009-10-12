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

#import "PreferenceController.h"
#import "PreferenceViewController.h"
#import "AccountViewController.h"
#import "AccountOverviewController.h"
#import "GeneralSettingsController.h"

#import "SkillPlanConfig.h"

#define PLUS_TAG 0
#define MINUS_TAG 1

#define PREF_ACCOUNT_OVERVIEW 0
//#define PREF_ACCOUNT 1
#define PREF_GENERAL 1

@interface PreferenceController (PreferenceControllerPrivate)

-(Account*) getSelectedAccount;

-(void) activateAccountOverview:(id)item;
-(void) activateAccountConfig:(Account*) acct;

//-(void) selectionChanged

@end

@implementation PreferenceController (PreferenceControllerPrivate)

-(void) activateAccountOverview:(id)item
{
	[plusButton setEnabled:YES]; /*add account*/
	[minusButton setEnabled:NO]; /*nothing to remove*/
	[box setContentView:[item view]];
	[item reloadAccounts];
}

-(void) activateAccountConfig:(Account*) acct
{
	
	[avc setAccount:acct];
	[box setContentView:[avc view]];
	[minusButton setEnabled:YES];
}

-(void) displayPane:(PreferenceViewController*)pvc
{
	[box setContentView:[pvc view]];
}

-(Account*) getSelectedAccount
{
	NSInteger rowNum = [prefList selectedRow];
	if(rowNum == -1){
		return nil;
	}
	id item = [prefList itemAtRow:rowNum];
	
	if([item isKindOfClass:[Account class]]){
		return (Account*) item;
	}
	   
	return nil;
}
@end


@implementation PreferenceController

-(id)init
{
	if(self = [super initWithWindowNibName:@"Preferences"]){
		cfg = [Config sharedInstance];		
		avc = [[AccountViewController alloc]init];
		[avc setPc:self];

		PreferenceViewController *vc;
		
		viewControllers = [[NSMutableArray alloc]init];
		
		vc = [[AccountOverviewController alloc]init];
		[viewControllers addObject:vc];
		[vc setPc:self];
		[vc release];
		
		vc = [[GeneralSettingsController alloc]init];
		[viewControllers addObject:vc];
		[vc setPc:self];
		[vc release];
		
		vc = [[SkillPlanConfig alloc]init];
		[viewControllers addObject:vc];
		[vc setPc:self];
		[vc release];
	}
	
	return self;
}

-(void) awakeFromNib
{
	[prefList setDataSource:self];
	[prefList setDelegate:self];
	
	[plusButton setEnabled:NO];
	[minusButton setEnabled:NO];
	
	if([[cfg accounts] count] > 0){
		[prefList expandItem:[viewControllers objectAtIndex:0] expandChildren:YES];
	}
}

-(IBAction) doneButtonClick:(id)sender
{
	NSLog(@"Writing out config");
	[cfg saveConfig];
	
	/*need to write out the viewcontrollers*/
	for(PreferenceViewController *pvc in viewControllers){
		if([pvc respondsToSelector:@selector(writeDefaults)]){
			[pvc performSelector:@selector(writeDefaults)];
		}
	}
		
	
	[[self window]close];
}

-(IBAction) plusMinusButtonClick:(id)sender
{
	
	/*if the account row is active, create a new account*/
	NSInteger row = [prefList selectedRow];
	if(row == -1){
		NSLog(@"invalid row selected. button should not be active");
		return;
	}
	
	id item = [prefList itemAtRow:[prefList selectedRow]];
	
	if([sender tag] == PLUS_TAG){
		if([item isKindOfClass:[AccountOverviewController class]]){
			/*create a new account*/
			Account *a = [[Account alloc]initWithName:@"New Account"];
			NSInteger idx = [cfg addAccount:a];
			if(idx != -1){
				[prefList reloadItem:item reloadChildren:YES];
				[prefList expandItem:item];
				[prefList selectRowIndexes:[NSIndexSet indexSetWithIndex:idx+1] byExtendingSelection:NO];
				[self activateAccountConfig:a];
			}
			[a release];
		}
	}else if([sender tag] == MINUS_TAG){
		if([item isKindOfClass:[Account class]]){
			/*someone clicked minus on an account*/
			Account *acct = [self getSelectedAccount];
			if(acct != nil){
				[cfg removeAccount:acct];
				/*if needed, optimize this to only reload the Accounts top level menu*/
				[prefList reloadItem:nil reloadChildren:YES];
				/*for the moment just punt the user back to the accounts screen*/
				
				/*this does not seem to post the notification that the selection has changed. do so manually*/
				[prefList selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
				[self activateAccountOverview:[viewControllers objectAtIndex:0]];
			}else {
				NSLog(@"There was an error attempting to remove account %@",[acct accountName]);
			}
		}
	}
}

-(void) updatePrefList
{
	[prefList reloadItem:nil reloadChildren:YES];
}

-(id) outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(id)item
{
	if(item == nil){
		return [viewControllers objectAtIndex:index];
	}
	
	//Return all accounts
	if([item isKindOfClass:[AccountOverviewController class]]){
		/*should only be one of these overview classes. list all sub accounts*/
		return [[cfg accounts]objectAtIndex:index];
	}
	
	return nil;
}
-(NSInteger) outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item
{
	if(item == nil){
		return [viewControllers count];
	}
	
	if([item isKindOfClass:[AccountOverviewController class]]){
		/*return the number of accounts in the config object*/
		NSLog(@"%d accounts in config array",[[cfg accounts]count]);
		return [[cfg accounts]count];
	}
	
	return 0;
}
-(BOOL) outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item
{
	if([item isKindOfClass:[AccountOverviewController class]]){
		return [[cfg accounts] count] > 0;
	}
	
	return NO;
}
-(id) outlineView:(NSOutlineView *)outlineView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
		   byItem:(id)item
{
	if([item isKindOfClass:[Account class]]){
		return [item accountName];
	}
	
	return [item name];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView 
shouldEditTableColumn:(NSTableColumn *)tableColumn 
			   item:(id)item
{
	return NO;
}

-(void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	[plusButton setEnabled:NO];
	[minusButton setEnabled:NO];
	
	NSInteger rowNum = [prefList selectedRow];
	if(rowNum == -1){
		return;
	}
	id item = [prefList itemAtRow:rowNum];
	
	if(item != nil)
	{
		NSLog(@"%@",[item class]);
		if([item isKindOfClass:[PreferenceViewController class]]){
			if([item isKindOfClass:[AccountOverviewController class]]){
				[self activateAccountOverview:item];
			}else{
				[self displayPane:item];
			}
		}else if([item isKindOfClass:[Account class]]){
			NSLog(@"An account was clicked");
			[self activateAccountConfig:(Account*)item];
		}
	}
}

-(Config*) config
{
	return cfg;
}

@end
