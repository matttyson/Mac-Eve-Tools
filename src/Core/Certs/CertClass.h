//
//  CertClass.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 25/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Cert;

/*
	This is a container for all the grades of certs.
 EG: Core Fitting.
 The array certArray contains the individual certs for that level.
 */

@interface CertClass : NSObject {
	NSInteger classID;
	NSString *certClassName;
	
	NSArray *certArray; //Array of cert objects beloning to this class.
}

@property (readonly,nonatomic) NSInteger classID;
@property (readonly,nonatomic) NSString* certClassName; //I would call the method className, but that is used by NSObject

-(NSInteger) certCount;
-(Cert*) certAtIndex:(NSInteger)index;

+(CertClass*) createCertClass:(NSInteger)cID desc:(NSString*)cDesc;


/*this is used as part of the class construction, 
 it is not to be called from anywhere else*/
-(void) setCertArray:(NSArray*)certArray;

@end
