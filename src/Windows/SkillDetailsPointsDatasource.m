//
//  SkillDetailsPointsDatasource.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 12/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SkillDetailsPointsDatasource.h"
#import "macros.h"

#import "Skill.h"

@implementation SkillDetailsPointsDatasource

- (id)init {
	[self doesNotRecognizeSelector:_cmd];
}

-(id) initWithSkill:(Skill*)s
{
	if((self = [super init])){
		skill = [s retain];
	}
	return self;
}

-(void)dealloc
{
	[skill release];
	[super dealloc];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return 5;
}

- (id)tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSInteger)rowIndex
{
	if([[aTableColumn identifier]isEqualToString:SD_LEVEL]){
		return [NSNumber numberWithInteger:rowIndex + 1];
	}else if([[aTableColumn identifier]isEqualToString:SD_SP_LEVEL]){
		return [NSNumber numberWithInteger:[skill totalSkillPointsForLevel:rowIndex + 1]];
	}else if([[aTableColumn identifier]isEqualToString:SD_SP_DIFF]){
		return [NSNumber numberWithInteger:
				[skill totalSkillPointsForLevel:rowIndex+1] - 
				[skill totalSkillPointsForLevel:rowIndex]];
	}
	return nil;
}


@end
