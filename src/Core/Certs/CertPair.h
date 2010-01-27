//
//  CertPair.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 25/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CertPair : NSObject {
	NSInteger certID;
	NSInteger grade;
}

@property (readonly,nonatomic) NSInteger certID;
@property (readonly,nonatomic) NSInteger grade;

+(CertPair*) createCertPair:(NSInteger)cID certGrade:(NSInteger)cGrade;

@end
