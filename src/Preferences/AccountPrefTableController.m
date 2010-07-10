//
//  AccountTableController
//  Mac Eve Tools
//
//  Created by Sebastian on 19.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AccountPrefTableController.h"
#import "Account.h"
#import "macros.h"
#import "Config.h"

@implementation AccountPrefTableController

@synthesize accounts, accountDetailController, addAccount, removeAccount, accountTable;

#pragma mark -
#pragma mark Initialization

-(void) awakeFromNib {
	[self refreshAccountsFromSettings];
}

- (void) dealloc
{	
	self.accounts = NULL;
	[super dealloc];
}

- (void) savePreferences {
	if (self.accounts != nil) {
		NSLog(@"Saving Accounts");
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:self.accounts];
		[defaults setObject:archive forKey:UD_ACCOUNTS];
		[defaults synchronize];
		
		[[Config sharedInstance] clearAccounts];
		for(Account *acct in self.accounts){
			[[Config sharedInstance] addAccount:acct];
		}
		[[Config sharedInstance] readConfig];		
	}
}

- (void) accountNameDidChanged {
	[accountTable display];
}

- (void) refreshAccountsFromSettings {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *archive = [defaults objectForKey:UD_ACCOUNTS];
	NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
	
	if (self.accounts == nil) {
		self.accounts = [[NSMutableArray alloc] init];
	}
	else {
		[self.accounts removeAllObjects];
	}
	
	[self.accounts addObjectsFromArray:array];
	[self.accountTable reloadData];
	[self.removeAccount setEnabled:NO];
	
	if ([self.accounts count] > 0) {
		[self.accountTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:TRUE];		
		[self tableViewSelectionDidChange:nil];
	}
}

#pragma mark -
#pragma mark Table methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [self.accounts count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	Account *item = [self.accounts objectAtIndex:row];
	return [item valueForKey:[tableColumn identifier]];
}

- (void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	Account *item = [self.accounts objectAtIndex:row];
	item.accountName = object;
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification {
	NSIndexSet *indexes = [self.accountTable selectedRowIndexes];
	if ([indexes count] == 1) {
		self.accountDetailController.account = [self.accounts objectAtIndex:[indexes firstIndex]];
		[self.removeAccount setEnabled:YES];
		[self.addAccount setEnabled:YES];
	}
	else {
		self.accountDetailController.account = NULL;
		[self.removeAccount setEnabled:NO];
		[self.addAccount setEnabled:YES];
	}
}

#pragma mark -
#pragma mark Control actions & events

- (IBAction)addAccountClicked:(NSButton *)sender {
	[self.accounts addObject:[[Account alloc] initWithName: NSLocalizedString(@"Untitled", @"Untitled")]];
	[self.accountTable noteNumberOfRowsChanged];
	NSInteger newRowIndex = [self.accounts count] - 1;
	NSIndexSet *index = [NSIndexSet indexSetWithIndex:newRowIndex];
	[self.accountTable selectRowIndexes:index byExtendingSelection:NO];
	[self.accountTable editColumn:[self.accountTable columnWithIdentifier:@"accountName"] row:newRowIndex withEvent:nil select:YES];
}

- (IBAction)removeAccountClicked:(NSButton *)sender {
	NSIndexSet *index = [self.accountTable selectedRowIndexes];
	[self.accountTable deselectAll:self];
    [self.accounts removeObjectsAtIndexes:index];
	[self.accountTable noteNumberOfRowsChanged];
	self.accountDetailController.account = NULL;	
}

@end
