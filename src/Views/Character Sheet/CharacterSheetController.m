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

#import "CharacterSheetController.h"
#import "XmlFetcher.h"
#import "GlobalData.h"
#import "Character.h"
#import "Account.h"
#import "SkillTree.h"
#import "Helpers.h"
#import "MTSkillProgressCell.h"
#import "Skill.h"
#import "SkillDetailsWindowController.h"
#import "MTEveSkillCell.h"
#import "MTEveSkillQueueHeader.h"
#import "SkillQueueDatasource.h"

#import "SkillPlan.h"


@interface CharacterSheetController (CharacterSheetPrivate)

-(void) showCharDetails:(Character*)character;
-(void) clearCharDetails; /*null out everything on error*/
-(void) clearCharTrainingDetails;

-(void) timerTick;

@end

@implementation CharacterSheetController (CharacterSheetPrivate)

-(void) timerTick
{
	if(trainingSkill != nil){
		[skillTree reloadItem:trainingSkill];
	}
}

-(void) clearCharDetails
{
	[charName setObjectValue:nil];
	[charRace setObjectValue:nil];
	
	[charInt setObjectValue:nil];
	[charPerc setObjectValue:nil];
	[charChar setObjectValue:nil];
	[charWill setObjectValue:nil];
	[charMem setObjectValue:nil];
	
	[charIsk setObjectValue:nil];
	[charSP setObjectValue:nil];
	[charKnownSkills setObjectValue:nil];
	[skillTree setDataSource:nil];
	[trainingRate setObjectValue:nil];
}

-(void) clearCharTrainingDetails
{
	[trainingRate setObjectValue:nil];
	[charTraining setObjectValue:nil];
	[timeRemaining setVisible:NO];
	trainingSkill = nil;
}

-(void) clearCharTrainingQueue
{
	[queueHeader setSkillPlan:nil];
	[queueHeader setCharacter:nil];
	[queueHeader setNeedsDisplay:YES];;
}

-(void) showCharTrainingQueue:(Character*)character
{
	if(currentCharacter != character){
		return;
	}
	SkillPlan *plan = [character trainingQueue];
	
	[queueHeader setCharacter:character];
	[queueHeader setSkillPlan:plan];
	[queueHeader setTimeRemaining:trainingTimeOfCurrentQueue];
	[queueHeader setNeedsDisplay:YES];
}

-(void) showCharDetails:(Character*)character
{
	if([character charSheetError]){
		return;
	}
	
	[charName setStringValue:[character stringForKey:CHAR_NAME]];
	[charRace setStringValue:[NSString stringWithFormat:@"%@ %@",
							  [character stringForKey:CHAR_RACE],
							  [character stringForKey:CHAR_BLOODLINE]]];
	[charName sizeToFit];
	[charRace sizeToFit];
	
	[charInt setStringValue:[character getAttributeString:ATTR_INTELLIGENCE]];
	[charPerc setStringValue:[character getAttributeString:ATTR_PERCEPTION]];
	[charChar setStringValue:[character getAttributeString:ATTR_CHARISMA]];
	[charWill setStringValue:[character getAttributeString:ATTR_WILLPOWER]];
	[charMem setStringValue:[character getAttributeString:ATTR_MEMORY]];
	
	[charInt sizeToFit];
	[charPerc sizeToFit];
	[charChar sizeToFit];
	[charWill sizeToFit];
	[charMem sizeToFit];
	
	[charIsk setObjectValue:[NSDecimalNumber decimalNumberWithString:[character stringForKey:CHAR_BALANCE]]];
	[charIsk sizeToFit];
	
	NSInteger clonePoints = [character integerForKey:CHAR_CLONE_SP];
	NSInteger charPoints = [character skillPointTotal];
	
	NSInteger threshold = (CGFloat)clonePoints * 0.95;
	
	if((clonePoints < charPoints) || (threshold < charPoints)){
		//clone is not up to date, make clone SP red to alert the user
		[cloneSP setTextColor:[NSColor redColor]];
	}else{
		[cloneSP setTextColor:[NSColor textColor]];
	}
	
	[cloneSP setObjectValue:[NSNumber numberWithInteger:clonePoints]];
	[cloneSP sizeToFit];
	
	[charSP setObjectValue:[NSNumber numberWithInteger:charPoints]];
	[charSP sizeToFit];
	
	NSString *knownSkills = [NSString stringWithFormat:@"%ld (%ld at V)",[character skillsKnown],[character skillsAtV]];
	[charKnownSkills setStringValue:knownSkills];
	[charKnownSkills sizeToFit];
	
	NSString *formattedSP = [SPFormatter stringFromNumber:[NSNumber numberWithInteger:charPoints]];
	NSString *headerCell = [NSString stringWithFormat:
							NSLocalizedString(@"Current skills: %ld  (skill points %@)",@"Cell header for skill sheet"),
			[character skillsKnown],formattedSP];
	[[[[skillTree tableColumns]objectAtIndex:0]headerCell]setStringValue:headerCell];
}

-(void) showCharTrainingDetails:(Character*)character
{
	if([character trainingSheetError]){
		return;
	}
	
	NSInteger isTraining = [character integerForKey:CHAR_TRAINING_SKILLTRAINING];
	
	if(isTraining == 0){
		/*not training.*/
		[charTraining setStringValue:NSLocalizedString(@"Not Training",@"Character is not training any skills")];
		[charTraining sizeToFit];
		[trainingRate setObjectValue:nil];
		[timeRemaining setHidden:YES];
		[trainingRate setHidden:YES];
		[queueHeader setHidden:YES];
		[titleRate setHidden:YES];
		[titleRemaining setHidden:YES];
		[[skillQueueDisplay enclosingScrollView]setHidden:YES];
		trainingSkill = nil;
		
		return;
	}
		

	if(trainingTimeOfCurrentSkill > 0){
		NSString *typeID = [character stringForKey:CHAR_TRAINING_TYPEID];
		NSNumber *key = [NSNumber numberWithInteger:[typeID integerValue]];
		Skill *s = [[[GlobalData sharedInstance]skillTree] skillForId:key];
		
		if(s == nil){
			NSLog(@"Skill was null for skill id %@",key);
			return;
		}
	
		NSString *training = [NSString stringWithFormat:@"%@ %@",[s skillName],
							  romanForString([character stringForKey:CHAR_TRAINING_LEVEL])];
		[charTraining setStringValue:training];
		[charTraining sizeToFit];
	}
	
	if([[character trainingQueue]skillCount] > 0){
		
		/*
		 this needs to be whatever the skill planner thinks it is to train a single skill, not what the XML sheet says.
		 The XML sheet sheet gives a different time to what the skill planner says and users will piss and moan if there
		 is a difference between the two.
		 
		 we use the trainingTimeOfCurrentSkill / trainingTimeOfCurrentQueue variables to keep the training time
		 exact across all displays so they are all consistent and tick down at the exact same speed.
		 */
		
		[timeRemaining setInterval:trainingTimeOfCurrentSkill];
		[queueHeader setTimeRemaining:trainingTimeOfCurrentQueue];
		[skillQueueDatasource setFirstSkillCountdown:trainingTimeOfCurrentSkill];
			
		/*this needs the character sheet to calculate, and also needs the training sheet to know if it should be displayed*/
		if(trainingTimeOfCurrentSkill > 0){
		NSInteger sphr = [character spPerHour];
		[trainingRate setStringValue:[NSString stringWithFormat:@"%ld SP/hr",sphr]];
		[trainingRate sizeToFit];

		[timeRemaining setVisible:YES];
		[timeRemaining setHidden:NO];
		[trainingRate setHidden:NO];
		[titleRate setHidden:NO];
		[titleRemaining setHidden:NO];
		}
		[queueHeader setHidden:NO];
		[skillQueueDisplay setHidden:NO];
		[[skillQueueDisplay enclosingScrollView]setHidden:NO];
	}
	trainingSkill = [[character skillTree]skillForId:[character trainingSkill]];
}

-(void) characterDidUpdate:(Character*)character didSucceed:(BOOL)success docPath:(NSString*)docPath
{
	if(currentCharacter != character){ //if the character being updated is not the current character, return.
		return;
	}
	
	if([docPath isEqualToString:XMLAPI_CHAR_SHEET]){
		if(!success){
			NSLog(@"Error fetching character data for %@",[character characterName]);
			[self clearCharDetails];
			return;
		}
		[skillTree setDataSource:character];
		[skillTree reloadData];
		
		[self showCharDetails:character];
		if([character isTraining]){
			[self showCharTrainingQueue:character];
		}
	}else if([docPath isEqualToString:XMLAPI_CHAR_TRAINING]){
		if(!success){
			NSLog(@"Error fetching character training data for %@",[character characterName]);
			[self clearCharTrainingDetails];
			return;
		}
		[self showCharTrainingDetails:character];
	}else if([docPath isEqualToString:PORTRAIT]){
		if(!success){
			NSLog(@"Error fetching character portrait for %@",[character characterName]);
			return;
		}
		NSImage *pic = [character portrait];
		if(pic != nil){
			[portrait setImage:pic];
		}
	}else if([docPath isEqualToString:XMLAPI_CHAR_QUEUE]){
		if(!success){
			NSLog(@"Error fetching character portrait for %@",[character characterName]);
			[self clearCharTrainingQueue];
			return;
		
		}
		[self showCharTrainingQueue:character];
	}
}

@end


@implementation CharacterSheetController

-(Character*) character
{
	return currentCharacter;
}

-(void) setCharacter:(Character*)c;
{
	if(c == nil){
		return;
	}
	if(currentCharacter == c){
		return;
	}
	
	if(currentCharacter != nil){
		[currentCharacter release];
	}
	
	[self clearCharDetails];
	[self clearCharTrainingDetails];
	[self clearCharTrainingQueue];
	
	currentCharacter = [c retain];
	
	SkillPlan *skillQueue = [c trainingQueue];
		
	if([skillQueue skillCount] > 0){
		NSDate *now = [NSDate date];
		trainingTimeOfCurrentSkill = [skillQueue trainingTimeOfSkillAtIndex:0 fromDate:now];
		trainingTimeOfCurrentQueue = [skillQueue trainingTimeFromDate:now];
	}else{
		trainingTimeOfCurrentSkill = 0;
		trainingTimeOfCurrentQueue = 0;
	}
	
	[skillQueueDatasource setCharacter:currentCharacter];
	[skillQueueDatasource setPlan:skillQueue];
	[skillQueueDisplay reloadData];
	
	[self showCharDetails:currentCharacter];
	[self showCharTrainingDetails:currentCharacter];
	[self showCharTrainingQueue:currentCharacter];
	
	[portrait setImage:[currentCharacter portrait]];
	[skillTree setDataSource:currentCharacter];
}

-(void) viewIsActive
{
	//user is looking at the charsheet. start the timer.
	secondTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
												   target:self
												 selector:@selector(timerTick:)
												 userInfo:nil
												  repeats:YES];
}

/*window is now inactive, clear instance variables of datasources and stuff*/
-(void) viewIsInactive
{
	[skillTree setDataSource:nil];
	[portrait setImage:nil];
	
	[self clearCharDetails];
	[self clearCharTrainingDetails];
	[self clearCharTrainingQueue];
	
	if(currentCharacter != nil){
		[currentCharacter release];
		currentCharacter = nil;
	}
	
	//Stop the timer when the user is no longer looking at the charsheet
	[secondTimer invalidate];
	secondTimer = nil;
}

-(void) viewWillBeDeactivated
{
	
}

-(void) viewWillBeActivated
{
	
}

/*not implemeted*/
-(NSMenuItem*) menuItems
{
	return nil;
}

/////end protocol methods

-(void) dealloc
{
	if(currentCharacter != nil){
		[currentCharacter release];
	}
	[super dealloc];
}

-(CharacterSheetController*) init
{
	if((self = [super initWithNibName:@"CharacterSheet" bundle:nil])){
		currentCharacter = nil;
	}
	
	return self;
}

-(void) awakeFromNib
{
	/*Number formatter for the characters balance*/
	NSNumberFormatter *f = [[NSNumberFormatter alloc]init];
	[f setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[f setDecimalSeparator:@"."];
	[f setMinimumFractionDigits:2];
	[f setGeneratesDecimalNumbers:YES];
	[f setNumberStyle:NSNumberFormatterDecimalStyle];
	[f setPositiveSuffix:@" ISK"];
	[f setNegativeSuffix:@" ISK"];
	[charIsk setFormatter:f];
	[f release];
	
	/*formatter for skill points*/
	f = [[NSNumberFormatter alloc]init];
	[f setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[f setNumberStyle:NSNumberFormatterDecimalStyle];
	[f setPositiveSuffix:@" SP"];
	[charSP setFormatter:f];
	[cloneSP setFormatter:f];
	[f release];
	
	skillQueueDatasource = [[SkillQueueDatasource alloc]init];
	[skillQueueDisplay setDataSource:skillQueueDatasource];
	[skillQueueDisplay setDelegate:skillQueueDatasource];
	
	SPFormatter = [[NSNumberFormatter alloc]init];
	[SPFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[SPFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	[skillTree setDoubleAction:@selector(skillTreeDoubleClick:)];
	[skillTree setAction:@selector(skillTreeSingleClick:)];
	[skillTree setTarget:self];
	[skillTree setDelegate:self];
	
	/*set up the cell for drawing skills*/
	MTEveSkillCell *cell = [[skillTree tableColumnWithIdentifier:COL_SKILL_NAME]dataCell];
	[cell setTarget:self];

//	[queueHeader setHidden:YES];
//	[skillQueueDisplay setHidden:YES];
	
	/*the right-click ->delete popup menu for the character portrait.*/
	NSMenu *portraitMenu = [[NSMenu alloc]initWithTitle:@"Delete Portrait"];
	NSMenuItem *menuItem = [[NSMenuItem alloc]initWithTitle:NSLocalizedString(@"Delete Portrait",)
													 action:@selector(deleteCurrentPortrait:)
											  keyEquivalent:@""];
	[menuItem setTarget:self];
	[portraitMenu addItem:menuItem];
	
	[menuItem release];
	[portrait setMenu:portraitMenu];
	[portraitMenu release];
	
	//timeRemaining = nil;
}

/*
	Called once every second to update the training time countdown
	on the character sheet.
 */
-(void) timerTick:(NSTimer*)theTimer
{
	[queueHeader tick];
	[timeRemaining tick];
	[skillQueueDatasource tick];
	[skillQueueDisplay setNeedsDisplayInRect:[skillQueueDisplay frameOfCellAtColumn:0 row:0]];
}

-(void) deleteCurrentPortrait:(id)notUsed
{
	NSLog(@"delete portrait");
	[currentCharacter deletePortrait];
	NSAlert *alert = [[NSAlert alloc]init];
	[alert setMessageText:
	 NSLocalizedString(@"Portrait Deleted",
					   @"The character portrait has been deleted")];
	[alert setInformativeText:
	 NSLocalizedString(@"The portrait will be updated when the character is next refreshed",
					   @"")];
	[alert addButtonWithTitle:@"OK"];
	[alert runModal];
	[alert release];
	[portrait setImage:nil];
}

-(void) skillTreeDoubleClick:(id)sender
{
	id item = [sender itemAtRow:[sender selectedRow]];
	if(![item isKindOfClass:[Skill class]]){
		return;
	}
	
	[SkillDetailsWindowController displayWindowForSkill:item forCharacter:currentCharacter];
}

-(void) skillTreeSingleClick:(id)sender
{
	NSPoint mouse = [[sender window] convertScreenToBase:[NSEvent mouseLocation]];
	mouse = [(NSOutlineView*)sender convertPoint:mouse fromView:nil];
	NSInteger row = [sender rowAtPoint:mouse];
	if(row == -1){
		return;
	}
	id item = [sender itemAtRow:row];
	if([item isKindOfClass:[SkillGroup class]]){
		if([sender isItemExpanded:item]){
			[sender collapseItem:item];
		}else{
			[sender expandItem:item];
		}
	}
}

-(void) infoButtonAction:(NSOutlineView*)sender
{
	NSInteger row = [sender clickedRow];
	
	[SkillDetailsWindowController displayWindowForSkill:
	[sender itemAtRow:row] forCharacter:currentCharacter];
}

- (void)outlineView:(NSOutlineView *)outlineView 
willDisplayOutlineCell:(id)cell 
	 forTableColumn:(NSTableColumn *)tableColumn 
			   item:(id)item
{
	if(![cell isKindOfClass:[MTEveSkillCell class]]){
		return;
	}
	MTEveSkillCell *eveCell = cell;
	if([[tableColumn identifier]isEqualToString:COL_SKILL_NAME]){
		if([item isKindOfClass:[Skill class]]){
			[eveCell setMode:Mode_Skill];
			[eveCell setSkill:item];
			[eveCell setSkillInfoButtonAction:@selector(infoButtonAction:)];
			if([item skillLevel] == 5){
				[eveCell setTimeLeft:0];
				[eveCell setPercentCompleted:0];
				[eveCell setCurrentSP:[item skillPoints]];
			}else{
				NSInteger skillLevel = [item skillLevel];
				/*set the percentage completed bar*/
				[eveCell setPercentCompleted:
					[currentCharacter percentCompleted:[item typeID]
								   fromLevel:skillLevel
									 toLevel:skillLevel+1]
				 ];
				/*set the remaining training time*/
				[eveCell setTimeLeft:
				[currentCharacter trainingTimeInSeconds:[item typeID] 
										  fromLevel:skillLevel 
											toLevel:skillLevel+1 
							accountForTrainingSkill:YES]
				 ];
				
				if([currentCharacter isTraining] && 
					[[currentCharacter trainingSkill]isEqualToNumber:[item typeID]])
				{
					[eveCell setCurrentSP:[currentCharacter currentSPForTrainingSkill]];
				}else{
					[eveCell setCurrentSP:[item skillPoints]];
				}
			}
		}else{
			[eveCell setMode:Mode_Group];
			[eveCell setGroup:item];
		}
	}
}


/*delegate methods for the skill cell display*/

- (void)outlineView:(NSOutlineView *)outlineView 
	willDisplayCell:(id)cell 
	 forTableColumn:(NSTableColumn *)tableColumn 
			   item:(id)item
{
	[self outlineView:outlineView 
		willDisplayOutlineCell:cell 
	   forTableColumn:tableColumn 
				 item:item];
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView 
	 heightOfRowByItem:(id)item
{
	if([item isKindOfClass:[Skill class]]){
		return 36.0;
	}
	return [outlineView rowHeight];
}

-(void) setInstance:(id<METInstance>)instance
{
	//Don't retain.
	mainApp = instance;
}


@end
