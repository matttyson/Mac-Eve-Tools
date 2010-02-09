/*
 This file is part of Mac Eve Tools.
 
 Mac Eve Tools is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Foobar is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Mac Eve Tools.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <Cocoa/Cocoa.h>


enum CharacterSortMode
{
	CS_Isk,
	CS_SkillPoints,
	CS_TrainingSkill,
	CS_TrainingQueue,
	CS_Alpha
};

@class Character;

/*
 This factory class is designed to create immutable character objects.
 They are immutable in the sense that they cannot be "updated".  that is
 the XML sheets cannot be updated / redownloaded by the character class.
 (in other words, any data obtained from the API server)
 
 It is however valid to mess with the skill plans, ship fitouts or any other
 data managed by the character object.
 
 Maintains a list of ACTIVE characters only.  We don't care about inactive
 characters.
 
 Implements tableview delegates & datasource methods for the character overview
 display.
 */



@interface CharacterManager : NSObject <NSTableViewDataSource,NSTableViewDelegate>
{
	NSMutableArray *templateArray;
	
	/*
	 maybe use a NSDictionary, keyed on characterId as an NSInteger
	 if an item is not in the dictionary, then it is not available yet
	 and would need to be downloaded
	 */

	NSArray *sortedArray;
	NSMutableDictionary *characterDictionary;
	
	NSInteger currentCharacter;
	NSInteger defaultCharacter;
	NSInteger characterCount;
	
	/*
		Return a list of all characters?
	 */
}

-(CharacterManager*) init;

/*
 pass in the template array for the character objects.
 obtained from the config object.  The CharacterManager
 will build up its character array
 
 */
-(BOOL)setTemplateArray:(NSArray*)tarray delegate:(id)del;

/*
	Get a character instance.
 
	index: the index in the array
	download: if YES, download everything from the XML website
			  if NO, return whatever is available on disk.
 
	If nothing is on disk it will be downloaded
 */
//-(Character*) characterAtIndex:(NSInteger)index download:(BOOL)download;

/*return the defult character as set in the preference screen.*/
-(Character*) defaultCharacter;


/*
 the number of characters in the factory
 */
-(NSInteger) characterCount;
-(Character*) characterAtIndex:(NSInteger)index;

/*given a characterId, return that character if it exists*/
-(Character*) characterById:(NSUInteger)characterId;

-(NSArray*) allCharacters;

/*deletes the portrait of the current character.*/
-(void) deletePortrait;

/*
	Refresh all characters.
	Call the delegate when done.
 */
-(void) updateAllCharacters:(id)del;

//Update an individual character.
//-(void) updateCharacter:(NSNumber*)characterId delegate:(id)del;

/*
	Add some sort of sorting mechanism so that characters can be sorted based on:
	Alphabetical Order.
	Skill completion date.
	Skill Points.
	ISK.
 */


@end
