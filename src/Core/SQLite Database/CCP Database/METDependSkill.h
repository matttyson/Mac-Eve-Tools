//
//  METDependSkill.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 4/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
	Used to calculate dependices for the "what items does this skill enable"
	window in the SkillDetailsWindow
 */

@interface METDependSkill : NSObject {
	NSInteger itemTypeID;
	NSString *itemName;
	NSInteger itemSkillPreTypeID;
	NSInteger itemSkillPreLevel;
	NSInteger itemCategory;
}

@property (readonly,nonatomic) NSInteger itemTypeID;
@property (readonly,nonatomic) NSString* itemName;
@property (readonly,nonatomic) NSInteger itemSkillPreTypeID;
@property (readonly,nonatomic) NSInteger itemSkillPreLevel;
@property (readonly,nonatomic) NSInteger itemCategory;

-(METDependSkill*) initWithData:(NSInteger)itemTID 
					   itemName:(NSString*)iName 
					skillPreTID:(NSInteger)sPTID 
					skillPLevel:(NSInteger)sPL
				   itemCategory:(NSInteger)iCat;

@end
