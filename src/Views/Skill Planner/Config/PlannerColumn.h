//
//  PlannerColumn.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 23/09/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PlannerColumn : NSObject <NSCoding> {
	NSString *columnName;
	NSString *identifier;
	float columnWidth;
	BOOL active;
}

-(PlannerColumn*) initWithName:(NSString*)name 
					identifier:(NSString*)idName 
						status:(BOOL)isActive
						 width:(float)colWidth;

@property (readonly,nonatomic) NSString* columnName;
@property (readwrite,nonatomic,assign) BOOL active;
@property (readwrite,nonatomic,assign) float columnWidth;
@property (readonly,nonatomic) NSString *identifier;

@end
