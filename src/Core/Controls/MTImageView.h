//
//  MTImage.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 2/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MTImageView : NSImageView {
	NSMenu *menu;
}

@property (nonatomic,readwrite,retain) NSMenu* menu;

@end
