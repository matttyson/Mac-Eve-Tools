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

#import "ShipPrerequisiteDatasource.h"
#import "ShipAttributeDatasource.h"

#import "SkillPlan.h"
#import "Helpers.h"

@implementation ShipDetailsWindowController

-(void)awakeFromNib
{
	[shipPrerequisites setIndentationMarkerFollowsCell:YES];
}

-(void)dealloc
{
	[ship release];
	[character release];
	
	@synchronized(self){
		if(down != nil){
			[down cancel];
			[down release];
		}
	}
	
	[shipPreDS release];
	[shipAttrDS release];
	
	[super dealloc];
}

-(ShipDetailsWindowController*)initWithType:(CCPType*)type forCharacter:(Character*)ch
{
	if((self = [super initWithWindowNibName:@"ShipDetails"])){
		ship = [type retain];
		character = [ch retain];
		down = nil;
		
		//I think the compiler is on crack.  the warning given here makes no sense.
		shipAttrDS = [[ShipAttributeDatasource alloc]initWithShip:ship forCharacter:character];
		shipPreDS = [[ShipPrerequisiteDatasource alloc]initWithShip:ship forCharacter:character];
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
}

-(BOOL) displayImage
{
	NSString *imagePath = [[Config sharedInstance] pathForImageType:[ship typeID]];
	
	NSFileManager *fm = [NSFileManager defaultManager];
		
	if(![fm fileExistsAtPath:[imagePath stringByDeletingLastPathComponent]]){
		[fm createDirectoryAtPath:[imagePath stringByDeletingLastPathComponent]
	  withIntermediateDirectories:YES
					   attributes:nil
							error:NULL];
	}
	
	if([fm fileExistsAtPath:imagePath]){
		NSImage *image = [[NSImage alloc]initWithContentsOfFile:imagePath];
		[shipView setImage:image];
		[image release];
		return YES;
	}
	
	return NO;
}

/*test to see if the image already exists.  fetch it if not*/
-(void) testImage
{
	if([self displayImage]){
		return;
	}
	
	NSString *imageUrl = [[Config sharedInstance] urlForImageType:[ship typeID]] ;
	NSString *filePath = [[Config sharedInstance] pathForImageType:[ship typeID]];
	
	NSLog(@"Downloading %@ to %@",imageUrl,filePath);
	
	/*image does not exist. download it and display it when it's done.*/
	NSURL *url = [NSURL URLWithString:imageUrl];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLDownload *download = [[NSURLDownload alloc]initWithRequest:request delegate:self];
	[download setDestination:filePath allowOverwrite:NO];
	
	down = download;
}

-(void) addAttribute:(NSInteger)attr toArray:(NSMutableArray*)ary
{
	CCPTypeAttribute *ta = [ship attributeForID:attr];
	
	if(ta != nil){
		[ary addObject:ta];
	}
}

-(void) calculateTimeToTrain
{
	//Normally skill plans should be created using the character object, but we don't
	//want to save this plan
	SkillPlan *plan = [[SkillPlan alloc]initWithName:@"--TEST--" character:character];
	[plan addSkillArrayToPlan:[ship prereqs]];
	
	NSInteger timeToTrain = [plan trainingTime];
	
	[plan release];
	
	if(timeToTrain == 0){
		//Can use this ship now.
		[trainingTime setStringValue:
		 [NSString stringWithFormat:
		  NSLocalizedString(@"%@ can fly this ship",@"<@CharacterName>"),
		  [character characterName]]];
	}else{
		NSString *timeToTrainString = stringTrainingTime(timeToTrain);
		
		[trainingTime setStringValue:
		 [NSString stringWithFormat:
		  NSLocalizedString(@"%@ could fly this ship in %@",@"<@CharacterName>"),
		  [character characterName],timeToTrainString]];
	}
	
	[miniPortrait setImage:[character portrait]];
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
	
	[self testImage];
	
	[self setLabels];
	
	[self calculateTimeToTrain];
	
	[shipPrerequisites setDataSource:shipPreDS];
	[shipPrerequisites expandItem:nil expandChildren:YES];
	
	[shipAttributes setDataSource:shipAttrDS];
	[shipAttributes expandItem:nil expandChildren:YES];
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




#pragma mark prerequisites
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
 
#pragma mark NSURLDownload delegate

-(void) downloadDidFinish:(NSURLDownload *)download
{
	[self displayImage];
	
	@synchronized(self){
		[down release];
		down = nil;
	}
}

-(void) download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
	NSLog(@"Error downloading image (%@): %@",[[download request]URL], error);
	
	@synchronized(self){
		[down release];
		down = nil;
	}
}

@end
