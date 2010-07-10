//
//  SkillPlannerPrefView.h
//  Mac Eve Tools
//
//  Created by Sebastian on 20.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBPreferencesController.h"

@interface SkillPlannerPrefViewController : NSViewController <MBPreferencesModule, NSTableViewDataSource, NSTableViewDelegate> {
	IBOutlet NSMutableArray *columnList; //The ordered list of columns.
	IBOutlet NSTableView *columnTable;
	IBOutlet NSButton *defaultButton;
}

@property (assign) IBOutlet NSMutableArray *columnList; //The ordered list of columns.
@property (assign) IBOutlet NSTableView *columnTable;
@property (assign) IBOutlet NSButton *defaultButton;

- (NSString *)title;
- (NSString *)identifier;
- (NSImage *)image;

-(IBAction) resetToDefaults:(id)sender;

@end