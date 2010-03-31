//
//  SkillAttribute.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 29/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SkillAttribute : NSObject {
	NSInteger attributeID;
	NSInteger valueInt;
	CGFloat valueFloat;
	BOOL isInt;
}

@property (nonatomic,readonly) NSInteger attributeID;
@property (nonatomic,readonly) NSInteger valueInt;
@property (nonatomic,readonly) CGFloat valueFloat;
@property (nonatomic,readonly) BOOL isInt;

-(SkillAttribute*) initWithAttributeID:(NSInteger)attrID 
							  intValue:(NSInteger)valInt
							floatValue:(CGFloat)valFloat
							   valType:(BOOL)type;

@end
