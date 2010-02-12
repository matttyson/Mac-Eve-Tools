//
//  ShipAttributeDatasource.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 9/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ShipAttributeDatasource.h"

#import "CCPType.h"
#import "Character.h"
#import "CCPTypeAttribute.h"
#import "CCPDatabase.h"


@implementation ShipAttributeDatasource

-(void) addAttribute:(NSArray*)attrType groupName:(NSString*)groupName
{
	if(attrType != nil){
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:groupName,@"Name",attrType,@"Data",nil];
		[attributes addObject:dict];
	}
}

-(void) loadAttributes
{
	attributes = [[NSMutableArray alloc]initWithCapacity:8];
	NSInteger typeID = [ship typeID];
	NSArray *attrType;
	NSDictionary *dict;
	
	attrType = [db attributeForType:typeID groupBy:Fitting];
	[self addAttribute:attrType groupName:@"Fitting"];
	
	attrType = [db attributeForType:typeID groupBy:Drones];
	[self addAttribute:attrType groupName:@"Drones"];
	
	attrType = [db attributeForType:typeID groupBy:Structure];
	[self addAttribute:attrType groupName:@"Structure"];
	
	attrType = [db attributeForType:typeID groupBy:Armour];
	[self addAttribute:attrType groupName:@"Armour"];
	
	attrType = [db attributeForType:typeID groupBy:Shield];
	[self addAttribute:attrType groupName:@"Shield"];
	
	attrType = [db attributeForType:typeID groupBy:Cap];
	[self addAttribute:attrType groupName:@"Capacitor"];
	
	attrType = [db attributeForType:typeID groupBy:Targeting];
	[self addAttribute:attrType groupName:@"Targeting"];
	
	attrType = [db attributeForType:typeID groupBy:Other];
	[self addAttribute:attrType groupName:@"Other"];
}

-(void)dealloc
{
	[ship release];
	[character release];
	[attributes release];
	[super dealloc];
}

-(ShipAttributeDatasource*) initWithShip:(CCPType*)type forCharacter:(Character*)ch
{
	if(self = [super init]){
		ship = [type retain];
		character = [ch retain];
		db = [ship database]; //not retained. do not release.
		
		[self loadAttributes];
	}
	
	return self;
}

-(NSInteger)outlineView:(NSOutlineView *)outlineView 
 numberOfChildrenOfItem:(id)item
{
	if(item == nil){
		return [attributes count];
	}
	
	return [[item valueForKey:@"Data"]count];
}

- (id)outlineView:(NSOutlineView *)outlineView 
			child:(NSInteger)index 
		   ofItem:(id)item
{
	if(item == nil){
		return [attributes objectAtIndex:index];
	}
	//return [item objectAtIndex:index];
	
	NSArray *ary = [item valueForKey:@"Data"];
	return [ary objectAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
		   byItem:(id)item
{
	if([item isKindOfClass:[CCPTypeAttribute class]]){
		if([[tableColumn identifier]isEqualToString:@"ATTR_NAME"]){
			return [item displayName];
		}
		if([[tableColumn identifier]isEqualToString:@"ATTR_VALUE"]){
			NSMutableString *str = [[[NSMutableString alloc]init]autorelease];
			
			if([item valueInt] != NSIntegerMax){
				[str appendFormat:@"%ld",[item valueInt]];
			}else{
				[str appendFormat:@"%.2f",(double)[item valueFloat]];
			}
			
			NSString *unit = [item unitDisplay];
			
			if(unit != nil){
				[str appendFormat:@" %@",unit];
			}
			
			return str;
		}
	}
	
	if([item isKindOfClass:[NSDictionary class]]){
		if([[tableColumn identifier]isEqualToString:@"ATTR_NAME"]){
			NSString *str = [item valueForKey:@"Name"];
			return str;
		}
	}
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView 
   isItemExpandable:(id)item
{
	if([item isKindOfClass:[CCPTypeAttribute class]]){
		return NO;
	}
	return YES;
}


@end
