//
//  CertPrerequisiteDatasource.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 3/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Cert;
@class Character;


@interface CertPrerequisiteDatasource : NSObject <NSOutlineViewDataSource> {
	Cert *cert;
	Character *character;
}

-(CertPrerequisiteDatasource*) initWithCert:(Cert*)c
										 forCharacter:(Character*)ch;

@end
