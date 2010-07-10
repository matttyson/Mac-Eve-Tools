//
//  AccountDetailController.m
//  Mac Eve Tools
//
//  Created by Sebastian on 19.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AccountPrefDetailController.h"
#import "CharacterTemplate.h"


@implementation AccountPrefDetailController

@synthesize account, updateCharacters, updatingIndicator, accountName, userId, apiKey, characterTable, accountTableController;

- (void) updateAllControls {
	BOOL hasAccount = self.account != NULL;
	[accountName setEditable:hasAccount];
	[userId setEditable:hasAccount];
	[apiKey setEditable:hasAccount];
	[updateCharacters setEnabled:hasAccount];
	[characterTable setEnabled:hasAccount];
	
	[characterTable reloadData];
}

- (void) awakeFromNib {
	[self addObserver:self forKeyPath:@"account" options:0 context:NULL];
	
	[updatingIndicator setHidden:YES];
	[self updateAllControls];
}

- (void) dealloc
{
	[self removeObserver:self forKeyPath:@"account"];
	[self.account release];
	[super dealloc];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"account"]) {
		
		if ([self.account accountName] != nil) {
			[accountName setStringValue:[self.account accountName]];
		}
		else {
			[accountName setStringValue:@""];
		}

		if ([self.account accountID] != nil) {
			[userId setStringValue:[self.account accountID]];
		}
		else {
			[userId setStringValue:@""];
		}
		
		if ([self.account apiKey] != nil) {
			[apiKey setStringValue:[self.account apiKey]];
		}
		else {
			[apiKey setStringValue:@""];
		}
		
		[self updateAllControls];
	}
}

- (void) updateDataFromControls:(id)sender withValue:(NSString *) value {
	if (self.account == NULL) {
		return;
	}
	
	if (sender == accountName) {
		self.account.accountName = value;
		[accountTableController accountNameDidChanged];
	}
	
	if (sender == userId) {
		self.account.accountID = value;
	}
	
	if (sender == apiKey) {
		self.account.apiKey = value;
	}
}

-(void) accountDidUpdate:(id)acct didSucceed:(BOOL)success
{
	[updatingIndicator stopAnimation:self];
	[updatingIndicator setHidden:YES];
	NSLog(@"account update finished");
	[self updateAllControls];
}

- (IBAction)updateClicked:(NSButton *)sender {	
	
	/* get the latest data from the input controls */
	[self updateDataFromControls:accountName withValue:[accountName stringValue]];
	[self updateDataFromControls:userId withValue:[userId stringValue]];
	[self updateDataFromControls:apiKey withValue:[apiKey stringValue]];
	
	[self.account loadAccount:self];
	
	[updatingIndicator setHidden:NO];
	[updatingIndicator startAnimation:self];
}

- (void) accountNameDidChanged {
	if ([self.account accountName] != nil) {
		[accountName setStringValue:[self.account accountName]];
	}
	else {
		[accountName setStringValue:@""];
	}
}

- (void) controlTextDidEndEditing:(NSNotification *)obj {
	NSLog(@"Editing end");
	[self updateDataFromControls:[obj object] withValue:[[obj object] stringValue]];
}

#pragma mark -
#pragma mark Table methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	NSLog(@"found %ld chars",[self.account.characters count]);
	return [self.account.characters count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	CharacterTemplate *template = [self.account.characters objectAtIndex:row];
	
	if([[tableColumn identifier]isEqualToString:@"NAME"]){
		return template.characterName;
	}if([[tableColumn identifier]isEqualToString:@"ACTIVE"]){		
		if(template.active){
			return [NSNumber numberWithInteger:NSOnState];
		}else{
			return [NSNumber numberWithInteger:NSOffState];
		}
	}
	return nil;
}

- (void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	CharacterTemplate *item = [self.account.characters objectAtIndex:row];
	item.active = [object boolValue];
}


@end
