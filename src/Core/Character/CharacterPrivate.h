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

#import "Character.h"

/*
 do NOT call any of these methods yourself, this file should only be included by the Character class
 */
@interface Character (CharacterPrivate)


/*
	This function creates the character object with the
 contents of all the XML documents.
 */
-(BOOL) parseCharacterXml:(NSString*)path;

-(BOOL) buildSkillTree:(xmlNode*)rowset;

/*
 Parse the XML sheet and build up the character details
 */
-(BOOL) parseXmlSheet:(xmlDoc*)document;
-(BOOL) parseXmlTraningSheet:(xmlDoc*)document;
-(BOOL) parseXmlQueueSheet:(xmlDoc*)document;

-(BOOL) parseAttributes:(xmlNode*)attributes;
-(BOOL) parseAttributeImplants:(xmlNode*)attrs;

-(void) addToDictionary:(const xmlChar*)xmlKey value:(NSString*)value;

/*calculate the total learning skill*/
-(void)calculateLearningSkills;

/*read the skill plans into the internal skill plan array*/
-(NSInteger) readSkillPlans;
/*write them out to the database*/
-(BOOL) writeSkillPlan;

@end
