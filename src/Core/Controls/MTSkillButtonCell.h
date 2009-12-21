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

/*
 This class exists to display the name of the skill being trained, 
 but also to provide functionality such as adding the skill to the next leve
 (plus button) removing the skill (minus button) and opening up the notes window
 (info button).
 */

@interface MTSkillButtonCell : NSTextFieldCell 
{
	SEL notesButtonAction;
	SEL plusButtonAction;
	SEL minusButtonAction;
	
	BOOL mouseInNotesButton;
	BOOL mouseInPlusButton;
	BOOL mouseInMinusButton;
	
	BOOL mouseDownInNotesButton;
	BOOL mouseDownInPlusButton;
	BOOL mouseDownInMinusButton;
}

@property (nonatomic,readwrite,assign) SEL notesButtonAction;
@property (nonatomic,readwrite,assign) SEL plusButtonAction;
@property (nonatomic,readwrite,assign) SEL minusButtonAction;

@end
