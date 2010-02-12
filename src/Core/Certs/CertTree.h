//
//  CertTree.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 25/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CertCategory;
@class Cert;

@interface CertTree : NSObject {
	NSMutableArray *certCategories;
	
	NSMutableDictionary *allCerts;
}

-(NSInteger) catCount;
-(CertCategory*) catAtIndex:(NSInteger)index;

-(Cert*) certForID:(NSInteger)certID;
-(NSDictionary*) allCerts;

+(CertTree*) createCertTree:(NSArray*)certCats certDict:(NSDictionary*)certs;

@end
