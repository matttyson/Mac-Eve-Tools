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
#import "ShipDetailsWindowController.h"
#import "GlobalData.h"
#import "Config.h"
#import "CCPDatabase.h"
#import "CCPType.h"
#import "Character.h"

#import "METShip.h"

@implementation ShipDetailsWindowController

-(void)awakeFromNib
{
	[shipPrerequisites setIndentationMarkerFollowsCell:YES];
}

-(void)dealloc
{
	[ship release];
	[character release];
	[super dealloc];
}

-(ShipDetailsWindowController*)initWithType:(CCPType*)type forCharacter:(Character*)ch
{
	if((self = [super initWithWindowNibName:@"ShipDetails"])){
		ship = [type retain];
		character = [ch retain];
	}
	return self;
}

+(void) displayShip:(CCPType*)type forCharacter:(Character*)ch
{
	ShipDetailsWindowController *wc = [[ShipDetailsWindowController alloc]initWithType:type forCharacter:ch];
	
	[[wc window]makeKeyAndOrderFront:nil];
}

-(void) setLabels
{
	[shipName setStringValue:[ship typeName]];
	[shipName sizeToFit];
	
	[shipDescription setString:[ship typeDescription]];
	
	CCPTypeAttribute *ta = [ship attributeForID:479];
	//[shipDescription setStringValue:[ship typeDescription]];
	//[shipDescription sizeToFit];
}

-(NSInteger) structureAttributes
{
	/*
	 items to check for
	 
	 Structure:
	 Capacity (in invTypes table)
	 Drone Capacity (283)
	 Drone Bandwith (1271)
	 Mass 
	 Volume
	 Inertia Modifier
	 
	 EM/EXP/KIN/THERM damage resist (113,111,109,110)
	 */
}

#pragma mark Delegates

-(void) windowDidLoad
{
	[[self window]setTitle:[NSString stringWithFormat:@"%@ - %@",[[self window]title],[ship typeName]]];
	
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self
	 selector:@selector(windowWillClose:)
	 name:NSWindowWillCloseNotification
	 object:[self window]];
	
	[self setLabels];
	
	[shipPrerequisites setDataSource:self];
	[shipPrerequisites expandItem:nil expandChildren:YES];
}

-(void) windowWillClose:(NSNotification*)sender
{
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	[self autorelease];
}

#pragma mark Delegates for the attributes

- (BOOL)tableView:(NSTableView *)aTableView 
shouldEditTableColumn:(NSTableColumn *)aTableColumn 
			  row:(NSInteger)rowIndex
{
	return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView 
shouldEditTableColumn:(NSTableColumn *)tableColumn 
			   item:(id)item
{
	return NO;
}

-(NSInteger)outlineView:(NSOutlineView *)outlineView 
 numberOfChildrenOfItem:(id)item
{
	if(item == nil){
		return [[ship prereqs]count];
	}
	
	return [[[[[GlobalData sharedInstance]skillTree] skillForId:[item typeID]]prerequisites]count];
	
	/*item should be a skill.  return all the dependicies of this skill*/
}

- (id)outlineView:(NSOutlineView *)outlineView 
			child:(NSInteger)index 
		   ofItem:(id)item
{
	if(item == nil){
		return [[ship prereqs]objectAtIndex:index];
	}
	
	return [[[[[GlobalData sharedInstance]skillTree] skillForId:[item typeID]]prerequisites]objectAtIndex:index];
}


- (id)outlineView:(NSOutlineView *)outlineView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
		   byItem:(id)item
{
	NSString *textValue = [item roman];
	
	Skill *s = [[character st]skillForId:[item typeID]];
	NSMutableAttributedString *str = [[[NSMutableAttributedString alloc]initWithString:textValue]autorelease];
	
	NSColor *color;
	if(s == nil){
		color = [NSColor redColor];
	}else if([s skillLevel] < [item skillLevel]){
		color = [NSColor orangeColor];
	}else{
		color = [NSColor blueColor];
	}
	[str addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0,[str length])];
	return str;
	
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView 
   isItemExpandable:(id)item
{
	Skill *s = [[[GlobalData sharedInstance]skillTree] skillForId:[item typeID]];
	return [[s prerequisites]count] > 0;
}

/*
 Armor:
 Armour amount (265)
 Damage Resist 
 EM (267)
 Explosive (268)
 Kenetic (269)
 Thermal (270)
 
 Shield:
 Sheild amount (263)
 Shield recharg time (479)
 damage resist
 EM (271)
 Explosive (272)
 Kenetic (273)
 Thermal (274)
 Capacitor:
 Capacity (482) 
 Recharge time (55)
 Targeting:
 Max targeting range (75)
 Max locked targets (192)
 Radar Str (208)
 Ladar Str (209)
 Magnetometric (210)
 Gravimetric (211)
 Signature radius (552)
 Propulsion
 Max Velocity (37)
 Ship warp speed
 
 */
 



@end
