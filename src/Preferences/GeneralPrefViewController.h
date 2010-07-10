//
//  GeneralViewController.h
//  Mac Eve Tools
//
//  Created by Sebastian on 17.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBPreferencesController.h"

@interface GeneralPrefViewController : NSViewController <MBPreferencesModule> {

}

- (NSString *)title;
- (NSString *)identifier;
- (NSImage *)image;

- (IBAction) sendStatisticsChanged:(NSButton *)sender;

@end
