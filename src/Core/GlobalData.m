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
#import "CertTree.h"
#import "Config.h"
#import "macros.h"

#import "CCPDatabase.h"

@implementation GlobalData

@synthesize skillTree;
@synthesize dateFormatter;
@synthesize certTree;

static GlobalData *_privateData = nil;

+(SkillTree*) buildSkillTree
{
	CCPDatabase *db = [[CCPDatabase alloc]initWithPath:[[Config sharedInstance]itemDBPath]];
	
	SkillTree *tree = [db buildSkillTree];
	
	[db release];
	
	return tree;
}

+(CertTree*) buildCertTree
{
	CCPDatabase *db = [[CCPDatabase alloc]initWithPath:[[Config sharedInstance]itemDBPath]];
	
	CertTree *tree = [db buildCertTree];
	
	[db release];
	
	return tree;
}

/*not that this will ever be called*/
-(void)dealloc
{
	[skillTree release];
	[certTree release];
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
		SkillTree *st = [GlobalData buildSkillTree];
		CertTree *ct = [GlobalData buildCertTree];
		
		if(st == nil){
			NSLog(@"Error: Failed to construct skill tree");
			return nil;
		}
		
		if(ct == nil){
			NSLog(@"Error: Failed to construct cert tree");
			return nil;
		}
		
		_privateData = [[GlobalData alloc]privateInit];
		
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
		
		_privateData->dateFormatter = [[NSDateFormatter alloc]init];
		[_privateData->dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[_privateData->dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		
		_privateData->skillTree = [st retain];
		_privateData->certTree = [ct retain];
	}
	
	//Not a leak.
	return _privateData;
	
}

@end
