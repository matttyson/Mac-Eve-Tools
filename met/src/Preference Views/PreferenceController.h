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

#import "Config.h"


@class AccountViewController;

/*
	The main controller class for the preference panel.
	
	It is responsable for swapping views in and out
	
	Menu Items:
		Account
		General
		
 */

@interface PreferenceController : NSWindowController <NSOutlineViewDataSource,NSOutlineViewDelegate> {
	IBOutlet NSOutlineView *prefList;
	IBOutlet NSButton *doneButton;
	
	IBOutlet NSButton *plusButton;
	IBOutlet NSButton *minusButton;
	
	IBOutlet NSBox *box;
	
	NSMutableArray *viewControllers; /*array of all the views that we support*/
	
	/*
		special case for the account View Controller. we use one panel instance and recycle
		it amongst the accounts.
	 */
	AccountViewController *avc; 
	
	Config *cfg;
}

-(IBAction) doneButtonClick:(id)sender;
-(IBAction) plusMinusButtonClick:(id)sender;

-(void)updatePrefList;

-(Config*) config;

@end
