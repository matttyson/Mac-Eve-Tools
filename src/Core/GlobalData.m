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
@synthesize database;

static GlobalData *_privateDataSingleton = nil;

/*not that this will ever be called*/
-(void)dealloc
{
	[skillTree release];
	[certTree release];
	[dateFormatter release];
	[database release];
	[super dealloc];
}

-(id) init
{
	self = [super init];
    _privateDataSingleton = self;
	 
	self.database = [[CCPDatabase alloc] initWithPath:[[NSUserDefaults standardUserDefaults] stringForKey:UD_ITEM_DB_PATH]];
	
    SkillTree *st = [database buildSkillTree];
	CertTree *ct = [database buildCertTree];
	
	if(st == nil){
		NSLog(@"Error: Failed to construct skill tree");
		return nil;
	}
	
	if(ct == nil){
		NSLog(@"Error: Failed to construct cert tree");
		return nil;
	}
		
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
	
	self.dateFormatter = [[NSDateFormatter alloc]init];
	[self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	
	self.skillTree = st;	
	self.certTree = ct;
		
    return self;
}

+(id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (_privateDataSingleton == nil) {
            _privateDataSingleton = [super allocWithZone:zone];
            return _privateDataSingleton;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

-(id)copyWithZone:(NSZone *)zone {
    return self;
}

-(id)retain {
    return self;
}


-(unsigned long)retainCount {
    return UINT_MAX;  //denotes an object that cannot be release
}


-(void)release {
    //do nothing    
}


-(id)autorelease {
    return self;    
}

+(GlobalData*) sharedInstance
{
	@synchronized(self) {
        if (_privateDataSingleton == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return _privateDataSingleton;	
}

-(NSString*) formatDate:(NSDate*)date
{
	return [dateFormatter stringFromDate:date];
}

-(NSInteger) databaseVersion
{
	NSString *path = [[NSUserDefaults standardUserDefaults] stringForKey:UD_ITEM_DB_PATH];
	
	if(![[NSFileManager defaultManager]fileExistsAtPath:path]){
		return 0;
	}
	
	CCPDatabase *db = [[CCPDatabase alloc]initWithPath:path];
	
	NSInteger version = [db dbVersion];
	
	[db release];
	
	return version;
	
}

-(BOOL) databaseUpToDate
{
	NSInteger version = [self databaseVersion];
	
	if(version >= [[NSUserDefaults standardUserDefaults] integerForKey:UD_DATABASE_MIN_VERSION]){
		return YES;
	}
	
	return NO;
}

@end
