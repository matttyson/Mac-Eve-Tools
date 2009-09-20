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

#import <Cocoa/Cocoa.h>

#import "METPluggableView.h"
#import "MTCountdown.h"
#import "MTEveSkillQueueHeader.h"

@class Character;
@class Skill;

@interface CharacterSheetController : NSViewController 
	<METPluggableView,NSOutlineViewDelegate> {
	/*character stuff*/
	IBOutlet NSOutlineView *skillTree;
	IBOutlet NSImageView *portrait;
	
	IBOutlet NSTextField *charName;
	IBOutlet NSTextField *charIsk;
	IBOutlet NSTextField *charSP;
	IBOutlet NSTextField *cloneSP;
	
	IBOutlet NSTextField *charKnownSkills;
	IBOutlet NSTextField *charTraining;
	IBOutlet NSTextField *charRace;
	
	IBOutlet NSTextField *charPerc;
	IBOutlet NSTextField *charInt;
	IBOutlet NSTextField *charChar;
	IBOutlet NSTextField *charWill;
	IBOutlet NSTextField *charMem;
	
	IBOutlet NSTextField *titleRemaining;
	IBOutlet NSTextField *titleRate;
	
	IBOutlet NSButton *charUpdateButton;
	
	IBOutlet NSTextField *trainingRate;
	
	IBOutlet MTEveSkillQueueHeader *queueHeader;
	
	IBOutlet MTCountdown *timeRemaining;
	
	NSNumberFormatter *SPFormatter;
	
	Character *currentCharacter; /*the character we are displaying*/
	Skill *trainingSkill;
}

-(Character*) character;
-(void) setCharacter:(Character*)c;



@end
