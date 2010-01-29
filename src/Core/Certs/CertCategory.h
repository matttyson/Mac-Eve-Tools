//
//  CertCategory.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 25/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CertClass;

@interface CertCategory : NSObject {
	NSInteger categoryID;
	NSString *catName;
	
	NSArray *classArray;
}

@property (readonly,nonatomic) NSInteger categoryID;
@property (readonly,nonatomic) NSString* catName;
@property (readonly,nonatomic) NSArray* classArray;

-(NSInteger) classCount;
-(CertClass*) classAtIndex:(NSInteger)index;

+(CertCategory*) createCertCategory:(NSInteger)cID name:(NSString*)cName cClass:(NSArray*)cClasses;

@end
