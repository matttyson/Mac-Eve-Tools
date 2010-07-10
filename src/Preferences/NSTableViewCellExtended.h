//
//  NSTableViewCellExtended.h
//  Mac Eve Tools
//
//  Created by Sebastian Kruemling on 20.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AccountPrefDetailController.h"

@interface NSTableViewCellExtended : NSTableView {
	IBOutlet AccountPrefDetailController *controller;
}
@property (assign) IBOutlet AccountPrefDetailController *controller;

- (void)textDidEndEditing:(NSNotification *)aNotification;

@end
