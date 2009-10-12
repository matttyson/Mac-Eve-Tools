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

#import "AccountOverviewController.h"

#import "CharacterTemplate.h"
#import "Character.h"

@implementation AccountOverviewController

-(AccountOverviewController*) init
{
	if(self = [super initWithNibName:@"PreferencesAccountMaster" bundle:nil]){
		name = @"Accounts";
	}
	
	return self;
}

-(void) reloadAccounts
{
	BOOL primarySet = NO;
	[charactersForAccount removeAllItems];
	
	Config *cfg = [Config sharedInstance];
		
	NSMenu *menu = nil;
	NSMenuItem *primary = nil;
	menu = [[NSMenu alloc] initWithTitle:@""];
	
	for(Account *acct in [cfg accounts]){
		for(CharacterTemplate *template in [acct characters]){
			if(![template active]){
				continue;
			}
		
			NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[template characterName] action:nil keyEquivalent:@""];
			[item setRepresentedObject:template];
			[menu addItem:item];
		
			if([template primary]){
				primarySet = YES;
				primary = item;
			}
			[item release];
		}
	}
	
	if(!primarySet){
		NSMenuItem *item = [[NSMenuItem alloc]initWithTitle:@"Not Set" action:nil keyEquivalent:@""];
		[menu insertItem:item atIndex:0];
		[item release];
	}
	
	[charactersForAccount setMenu:menu];
	if(primary != nil){
		[charactersForAccount selectItem:primary];
	}
	[menu release];
	
}

-(IBAction) accountListClick:(id)sender
{
	NSMenuItem *item = [sender selectedItem];
	Account *a = [item representedObject];
		
	[charactersForAccount removeAllItems];
	
	NSMenu *menu;
	menu = [[NSMenu alloc] initWithTitle:@""];
	
	for(Character *c in [a characters])
	{
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[c characterName] action:nil keyEquivalent:@""];
		[item setRepresentedObject:c];
		[menu addItem:item];
		[item release];
	}
	[charactersForAccount setMenu:menu];
	[menu release];
}

-(IBAction) characterListClick:(id)sender
{
	/*go though all the accounts, deselect them as primary, set this one as primary*/
	
	Config *cfg = [Config sharedInstance];
	
	for(Account *a in [cfg accounts]){
		for(CharacterTemplate *template in [a characters]){
			[template setPrimary:NO];
		}
	}
	
	NSMenuItem *item = [sender selectedItem];
	[[item representedObject]setPrimary:YES];
}

@end
