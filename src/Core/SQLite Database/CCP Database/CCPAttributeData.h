//
//  AttributeTest.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 4/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CCPAttributeData : NSObject {
	NSInteger attributeID;
	CGFloat value;
	NSString *name;
}

-(CCPAttributeData*) initWithValues:(NSInteger)attrID value:(CGFloat)val name:(NSString*)n;

@property (nonatomic,readonly) NSInteger attributeID;
@property (nonatomic,readonly) CGFloat value;
@property (nonatomic,readonly) NSString* name;


@end
