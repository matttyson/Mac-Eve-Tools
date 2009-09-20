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

#import "PreferenceViewController.h"
#import "Account.h"


@interface AccountViewController : PreferenceViewController <NSTableViewDataSource,NSTextFieldDelegate>{

	IBOutlet NSTextField *acctName;
	IBOutlet NSTextField *acctId;
	IBOutlet NSTextField *acctKey;
	
	IBOutlet NSTextField *url;
	
	IBOutlet NSButton *updateButton;
	IBOutlet NSProgressIndicator *progressIndicator;
	
	IBOutlet NSTableView *characterList;
	
	Account *account;
}

-(AccountViewController*) init;
-(AccountViewController*) initWithAccount:(Account*)acct;

-(Account*) account;
-(void) setAccount:(Account*)acct;

-(NSString*) accountName;
-(void) setAccountName:(NSString*)accountName;

-(NSString*) accountId;
-(void) setAccountId:(NSString*)accountId;

-(NSString*) apiKey;
-(void) setApiKey:(NSString*)newApiKey;

-(IBAction) updateButtonClick:(id)sender;

-(IBAction) characterActiveCellButtonClick:(id)sender;

- (void)controlTextDidEndEditing:(NSNotification *)aNotification;
@end
