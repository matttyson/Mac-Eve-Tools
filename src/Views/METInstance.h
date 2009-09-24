//
//  METInstance.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 19/09/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
	This allows a view to commiunicate back to the main program.
	When a view is initialized it will be given this instance.
 */

@protocol METInstance

/*
 display a message on the toolbar
 To clear the message, pass nil as the message.
 */
-(void) setToolbarMessage:(NSString*)message;
/*display a time limited message on the toolbar*/
-(void) setToolbarMessage:(NSString*)message time:(NSInteger)seconds;

@end
