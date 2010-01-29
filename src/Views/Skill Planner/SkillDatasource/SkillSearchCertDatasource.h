//
//  SkillSearchCertDatasource.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 25/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Character;
@class CertTree;

#import "SkillSearchView.h"


@interface SkillSearchCertDatasource : NSObject <SkillSearchDatasource> {
	Character *character;
	CertTree *certs;
	NSDictionary *characterSkills;
	
	NSString *searchString;
	NSMutableArray *foundSearchObjects;
	NSMutableArray *certClasses;
}

@end
