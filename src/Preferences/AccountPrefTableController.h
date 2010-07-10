//
//  AccountTableController.h
//  Mac Eve Tools
//
//  Created by Sebastian on 19.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AccountPrefDetailController.h"
#import "NSTableViewCellExtended.h"

@interface AccountPrefTableController : NSObject<NSTableViewDataSource, NSTableViewDelegate> {
	IBOutlet NSButton *addAccount;
	IBOutlet NSButton *removeAccount;
	IBOutlet NSTableViewCellExtended *accountTable;
	IBOutlet AccountPrefDetailController *accountDetailController;
	
	NSMutableArray *accounts;
}

@property (retain) NSMutableArray *accounts;
@property (assign) IBOutlet AccountPrefDetailController *accountDetailController;
@property (assign) IBOutlet NSButton *addAccount;
@property (assign) IBOutlet NSButton *removeAccount;
@property (assign) IBOutlet NSTableViewCellExtended *accountTable;

- (IBAction)addAccountClicked:(NSButton *)sender;
- (IBAction)removeAccountClicked:(NSButton *)sender;

- (void) savePreferences;
- (void) accountNameDidChanged;
- (void) refreshAccountsFromSettings;

@end
