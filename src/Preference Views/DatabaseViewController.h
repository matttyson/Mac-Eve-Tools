//
//  DatabaseViewController.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 3/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PreferenceViewController.h"

@interface DatabaseViewController : PreferenceViewController {
	IBOutlet NSTextField *dbVersionLabel;
	IBOutlet NSPopUpButton *langSelector;
	IBOutlet NSTextField *restartWarning;
	IBOutlet NSTextField *dbSize;
	//IBOutlet NSTextField *dbFilepath;
}

-(IBAction) languageSelectionClick:(id)sender;

@end
