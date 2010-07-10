/*
 This file is part of Mac Eve Tools.
 
 Mac Eve Tools is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Mac Eve Tools is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Mac Eve Tools.  If not, see <http://www.gnu.org/licenses/>.
 
 Copyright Matt Tyson, 2009.
 */

#import "SkillPair.h"
#import "Helpers.h"
#import "GlobalData.h"

@implementation SkillPair

@synthesize typeID;
@synthesize skillLevel;

-(SkillPair*) initWithSkill:(NSNumber*)skill level:(NSInteger)level
{
	if(self = [super init]){
		typeID = [skill retain];
		skillLevel = level;
	}
	
	return self;
}

-(void) dealloc
{
	[typeID release];
	[super dealloc];
}

-(NSString*) roman
{
	SkillTree *st = [[GlobalData sharedInstance]skillTree];
	return [NSString stringWithFormat:@"%@ %@",[[st skillForId:typeID]skillName], romanForInteger(skillLevel)];
}

-(NSString*) description
{
	SkillTree *st = [[GlobalData sharedInstance]skillTree];
	return [NSString stringWithFormat:@"%@ %@ %ld",[st skillForId:typeID], typeID,skillLevel];
}

-(NSComparisonResult) compare:(SkillPair*)rhs
{
	if([self->typeID isEqualToNumber:rhs->typeID]){
		if(self->skillLevel == rhs->skillLevel){
			return NSOrderedSame;
		}
	}
	return NSOrderedAscending;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeInteger:[typeID integerValue] forKey:@"typeID"];
	[encoder encodeInteger:skillLevel forKey:@"skillLevel"];
}
- (id)initWithCoder:(NSCoder *)decoder
{
	if (typeID != NULL) {
		[typeID release];
	}
	
	typeID = [NSNumber numberWithInteger:[decoder decodeIntegerForKey:@"typeID"]];
	skillLevel = [decoder decodeIntegerForKey:@"skillLevel"];
	return [self initWithSkill:typeID level:skillLevel];
}

@end
