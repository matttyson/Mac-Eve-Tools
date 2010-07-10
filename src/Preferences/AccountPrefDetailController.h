//
//  AccountDetailController.h
//  Mac Eve Tools
//
//  Created by Sebastian Kruemling on 19.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Account.h"

@class AccountPrefTableController;
@interface AccountPrefDetailController : NSObject <NSTableViewDataSource, NSTableViewDelegate, AccountUpdateDelegate> {
	IBOutlet NSButton *updateCharacters;
	IBOutlet NSProgressIndicator *updatingIndicator;
	IBOutlet NSTextField *accountName;
	IBOutlet NSTextField *userId;
	IBOutlet NSTextField *apiKey;
	IBOutlet NSTableView *characterTable;
	IBOutlet AccountPrefTableController *accountTableController;
	
	Account *account;
}

@property (retain) Account *account;
@property (assign) IBOutlet NSButton *updateCharacters;
@property (assign) IBOutlet NSProgressIndicator *updatingIndicator;
@property (assign) IBOutlet NSTextField *accountName;
@property (assign) IBOutlet NSTextField *userId;
@property (assign) IBOutlet NSTextField *apiKey;
@property (assign) IBOutlet NSTableView *characterTable;
@property (assign) IBOutlet AccountPrefTableController *accountTableController;

- (IBAction)updateClicked:(NSButton *)sender;
- (void) accountNameDidChanged;

@end
