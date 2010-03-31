//
//  MTImage.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 2/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MTImageView : NSImageView {
	SEL selector;
	id delegate;
	NSMenu *menu;
}

@property (nonatomic,readwrite,retain) NSMenu* menu;
@property (nonatomic,readwrite,assign) SEL selector;
@property (nonatomic,readwrite,assign) id delegate;

@end
