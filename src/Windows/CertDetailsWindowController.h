//
//  CertDetailsWindowController.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 27/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class Cert;
@class Character;

@interface CertDetailsWindowController : NSWindowController <NSOutlineViewDataSource> {

	IBOutlet NSOutlineView *certPrerequisites;
	IBOutlet NSTextField *certDescription;
	
	IBOutlet NSImageView *miniPortrait;
	IBOutlet NSTextField *trainingTime;
	
	Cert *cert;
	Character *character;
}

+(void) displayWindowForCert:(Cert*)cer character:(Character*)ch;

@end
