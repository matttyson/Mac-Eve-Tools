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

#import "SkillSearchShipDatasource.h"

#import "CCPDatabase.h"
#import "CCPType.h"
#import "CCPCategory.h"
#import "CCPGroup.h"
#import "METSubGroup.h"

#import "Config.h"

#import "macros.h"

@implementation SkillSearchShipDatasource



-(id)init
{
	if(self = [super init]){
		searchObjects = [[NSMutableArray alloc]init];
	}
	return self;
}

-(void) dealloc
{
	[database release];
	[category release];
	[searchObjects release];
	[searchString release];
	[super dealloc];
}

-(id)initWithCategory:(NSInteger)cat
{
	if(self = [self init]){
		NSString *path = [[Config sharedInstance]itemDBPath];
		
		if(![[NSFileManager defaultManager]
			 fileExistsAtPath:path])
		{
			[self autorelease];
			return nil;
		}
		
		database = [[CCPDatabase alloc]initWithPath:path];
		if(database == nil){
			/*fall back to user directory*/
			[self autorelease];
			return nil;
		}
		
		category = [[database category:cat]retain];
	}
	return self;
}

-(NSString*) skillSearchName
{
	return NSLocalizedString(@"Ships",@"Ship picker for skill planner.  Keep the translation short.");
}

-(void) skillSearchFilter:(id)sender
{
	NSString *searchValue = [[sender cell]stringValue];
	
	if([searchValue length] == 0){
		[searchString release];
		searchString = nil;
		[searchObjects removeAllObjects];
		return;
	}
	
	[searchObjects removeAllObjects];
	[searchString release];
	searchString = [searchValue retain];
	
	/*this will need to be an array of typeobjects. jesus.*/
	
	NSInteger groupCount = [category groupCount];
	
	for(NSInteger i = 0; i < groupCount; i++){
		CCPGroup *group = [category groupAtIndex:i];
		NSInteger typeCount = [group typeCount];
		for(NSInteger j = 0; j < typeCount; j++){
			CCPType *type = [group typeAtIndex:j];
			NSRange r = [[type typeName]rangeOfString:searchString options:NSCaseInsensitiveSearch];
			if(r.location != NSNotFound){
				[searchObjects addObject:type];
			}
		}
	}
}

-(NSInteger) outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item
{
	if(item == nil){
		if([searchObjects count] > 0){
			return [searchObjects count];
		}
		return [category groupCount];
	}
	
	if([item isKindOfClass:[CCPGroup class]]){
		return [item subGroupCount];
	}
	
	if([item isKindOfClass:[METSubGroup class]]){
		return [item typeCount];
	}
	
	return 0;
}

-(id) outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(id)item
{
	if(item == nil){
		if([searchObjects count] > 0){
			return [searchObjects objectAtIndex:index];
		}
		return [category groupAtIndex:index];
	}
	if([item isKindOfClass:[CCPGroup class]]){
		//return [item typeAtIndex:index];
		return [item subGroupAtIndex:index];
	}
	if([item isKindOfClass:[METSubGroup class]]){
		return [item typeAtIndex:index];
	}
	return nil;
}

-(BOOL) outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item
{
	if([item isKindOfClass:[CCPType class]]){
		return NO;
	}
	return YES;
}

-(id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	if([item isKindOfClass:[CCPGroup class]]){
		return [item groupName];
	}
	if([item isKindOfClass:[CCPType class]]){
		return [item typeName];
	}
	if([item isKindOfClass:[METSubGroup class]]){
		return [item groupName];
	}
	return nil;
}

-(NSMenu*) outlineView:(NSOutlineView*)outlineView 
menuForTableColumnItem:(NSTableColumn*)column 
				byItem:(id)item
{
	if(![item isKindOfClass:[CCPType class]]){
		return nil;
	}
	
	NSArray *skills = [item prereqs];
	
	
	
	NSMenu *menu = [[[NSMenu alloc]initWithTitle:@"Menu"]autorelease];
	
	NSMenuItem *menuItem;
	menuItem = [[NSMenuItem alloc]initWithTitle:[item typeName] 
									 action:@selector(displayShipWindow:)
							  keyEquivalent:@""];
	[menuItem setRepresentedObject:item];
	[menu addItem:menuItem];
	[menuItem release];
	
	[menu addItem:[NSMenuItem separatorItem]];
	
	menuItem = [[NSMenuItem alloc]initWithTitle:[NSString stringWithFormat:
												 NSLocalizedString(@"Add %@ to plan",
																   @"add a ship to the skill plan"),
												 [item typeName]] 
									 action:@selector(menuAddSkillClick:) 
							  keyEquivalent:@""];
	
	[menuItem setRepresentedObject:skills];
	[menu addItem:menuItem];
	[menuItem release];
	
	return menu;
}

/*display a tooltip*/
- (NSString *)outlineView:(NSOutlineView *)ov 
		   toolTipForCell:(NSCell *)cell 
					 rect:(NSRectPointer)rect 
			  tableColumn:(NSTableColumn *)tc 
					 item:(id)item 
			mouseLocation:(NSPoint)mouseLocation
{
	return nil;
}

#pragma mark drag and drop support

- (BOOL)outlineView:(NSOutlineView *)outlineView 
		 writeItems:(NSArray *)items 
	   toPasteboard:(NSPasteboard *)pboard
{			
	NSMutableArray *array = [[NSMutableArray alloc]init];
	
	//FIXME: TODO: type could also be a CCPGroup item
	
	for(CCPType *type in items){
		if([type isKindOfClass:[CCPType class]]){
			[array addObjectsFromArray:[type prereqs]];
		}else{
			return NO;
		}
	}
	
	[pboard declareTypes:[NSArray arrayWithObject:MTSkillArrayPBoardType] owner:self];
	
	NSMutableData *data = [[NSMutableData alloc]init];
	
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
	[archiver setOutputFormat:NSPropertyListBinaryFormat_v1_0];
	[archiver encodeObject:array];
	[archiver finishEncoding];
	
	[pboard setData:data forType:MTSkillArrayPBoardType];
	
	[archiver release];
	[data release];
	[array release];
	
	return YES;
}

@end
