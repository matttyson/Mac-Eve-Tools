//
//  CCPTypeAttribute.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 6/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
	This class represents a row in the TypeAttribute table.
	It's a mix of both the dgmTypeAttribute and the dgmAttributeType tables
	and contains data from both to represent the one object.
 */

@interface CCPTypeAttribute : NSObject {
	NSInteger attributeID;
	
	//NSString attributeName;
	//NSString attributeDesc;
	
	NSString *displayName;
	NSString *unitDisplay;
	
	NSInteger graphicID;
	
	NSInteger valueInt;
	CGFloat valueFloat;
}

+(CCPTypeAttribute*) createTypeAttribute:(NSInteger)attributeId 
								dispName:(NSString*)dispName
							 unitDisplay:(NSString*)unitDisp
							   graphicId:(NSInteger)gID
								valueInt:(NSInteger)vInt
							  valueFloat:(CGFloat)vFloat;

@property (readonly,nonatomic) NSInteger attributeID;

//@property (readonly,nonatomic) NSString* attributeName;
//@property (readonly,nonatomic) NSString* attributeDesc;

@property (readonly,nonatomic) NSString* displayName;
@property (readonly,nonatomic) NSString* unitDisplay;
@property (readonly,nonatomic) NSInteger graphicID;

@property (readonly,nonatomic) NSInteger valueInt; //WILL BE NSIntegerMax if NULL
@property (readonly,nonatomic) CGFloat valueFloat; //WILL BE CGFLOAT_MAX if NULL

@end
