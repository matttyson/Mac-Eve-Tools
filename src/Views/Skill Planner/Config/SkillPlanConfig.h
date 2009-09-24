//
//  SkillPlanConfig.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 23/09/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferenceViewController.h"

@interface SkillPlanConfig : PreferenceViewController <NSTableViewDataSource> {
	IBOutlet NSArrayController *arrayController;
	
	IBOutlet NSMutableArray *columnList; //The ordered list of columns.
	
	IBOutlet NSTableView *columnTable;
}

-(void) readDefaults;

@end
