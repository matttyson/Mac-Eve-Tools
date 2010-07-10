//
//  AccountViewController.h
//  Mac Eve Tools
//
//  Created by Sebastian Kruemling on 19.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBPreferencesController.h"
#import "AccountPrefTableController.h"


@interface AccountPrefViewController : NSViewController <MBPreferencesModule> {
	IBOutlet NSTextField *apiKeyUrl;
	IBOutlet AccountPrefTableController *accountTableController;
}

- (NSString *)title;
- (NSString *)identifier;
- (NSImage *)image;

@end
