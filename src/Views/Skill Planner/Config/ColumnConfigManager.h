//
//  ColumnConfigManager.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 26/09/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PlannerColumn.h"

@interface ColumnConfigManager : NSObject {
	NSMutableArray *columnList;
}

-(void) readConfig;
-(void) writeConfig;
-(void) eraseConfig;

-(BOOL) setWidth:(CGFloat)width forColumn:(NSString*)columnId;
-(BOOL) setOrder:(NSInteger)position forColumn:(NSString*)columnId;

-(NSArray*) columns;

@end
