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

@class Character;

/*
 This protocol is not yet finished, nor do all the views implement it properly.
 
 The idea is all views (Currently, the character sheet and the skill planner)
 should implement this interface.  The MainController class will then call this
 interface in response to what the user does.
 
 */


@protocol METPluggableView

/*
 This is the character the view is to display.
 This will be called as the user changes which character they want to look at.
 */
-(void) setCharacter:(Character*)c;  

-(NSView*) view; //The NSView that we will be displaying to the user.

/*setCharacter will be called AFTER viewWillBeActivated is called and BEFORE viewIsActive is called*/

-(void) viewIsActive; //called after the window has become active
-(void) viewIsInactive; //called after the window has been deactiviated

-(void) viewWillBeDeactivated; //called before the view is deactivated.
-(void) viewWillBeActivated;  //called after the view is deactivated

/*
	Return an NSMenuItem populated with any options to display to the user
	return nil if the plugin does not require a menu
 
	(Not yet implemented in the MainController class)
 
	If this view returns a menu other than nil, it will be displayed
	to the left of the "Mac Eve Tools" menu bar item
 */
-(NSMenuItem*) menuItems;

/*
	This will be an object given to each view when it is made active so it can query
	the core app status.  not yet implemented or specced out yet.
 */

//-(void) setControllerDelegate:(id)object;

@end
