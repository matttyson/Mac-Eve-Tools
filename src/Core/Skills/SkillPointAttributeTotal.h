//
//  SkillAttributeTotal.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 29/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SkillPointAttributeTotal : NSObject {
	NSInteger primary;
	NSInteger secondary;
	NSInteger skillPoints;
}

@property (nonatomic,readonly) NSInteger primary;
@property (nonatomic,readonly) NSInteger secondary;
@property (nonatomic,readonly) NSInteger skillPoints;

-(void) addSkillPoints:(NSInteger)points;

-(SkillPointAttributeTotal*) initWithPrimary:(NSInteger)pri andSecondary:(NSInteger)sec;

+(NSUInteger) keyForPrimary:(NSInteger)pri andSecondary:(NSInteger)sec;

-(NSComparisonResult) sortBySkillPoints:(SkillPointAttributeTotal*)rhs;

@end
