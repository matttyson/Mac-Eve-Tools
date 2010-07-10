//
//  DatabasePrefViewController.h
//  Mac Eve Tools
//
//  Created by Sebastian on 20.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBPreferencesController.h"


@interface DatabasePrefViewController : NSViewController <MBPreferencesModule> {
	IBOutlet NSTextField *dbVersionLabel;
	IBOutlet NSPopUpButton *langSelector;
	IBOutlet NSTextField *restartWarning;
	IBOutlet NSTextField *dbSize;
}

- (NSString *)title;
- (NSString *)identifier;
- (NSImage *)image;

-(IBAction) languageSelectionClick:(id)sender;

@end
