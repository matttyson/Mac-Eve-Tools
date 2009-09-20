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

#import "GlobalData.h"


#import "SkillTree.h"
#import "Config.h"
#import "macros.h"

@implementation GlobalData

@synthesize skillTree;
@synthesize dateFormatter;

static GlobalData *_privateData = nil;

-(SkillTree*) buildSkillTree
{
	NSString *path = [Config filePath:XMLAPI_SKILL_TREE,nil];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if([fm fileExistsAtPath:path]){
		SkillTree *tree = [[SkillTree alloc]initWithXml:path];
		if(tree == nil){
			NSLog(@"Skill tree parse error");
			return nil;
		}
		return tree;
	}
	NSLog(@"Could not read %@",path);
	return nil;
}

/*not that this will ever be called*/
-(void)dealloc
{
	[skillTree release];
	[dateFormatter release];
	[super dealloc];
}

-(GlobalData*) privateInit
{
	return [super init];
}

/*
 don't call this.
 Prevent anyone from calling init without thinking.
 */
-(id) init
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

+(GlobalData*) sharedInstance
{
	if(_privateData == nil)
	{
		_privateData = [[GlobalData alloc]privateInit];
		
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
		
		_privateData->dateFormatter = [[NSDateFormatter alloc]init];
		[_privateData->dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[_privateData->dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		
		_privateData->skillTree = [_privateData buildSkillTree];
	}
	
	return _privateData;
}

@end
