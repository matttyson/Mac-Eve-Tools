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

#import "GeneralSettingsController.h"


@implementation GeneralSettingsController

-(void) autoUpdateButtonClick:(id)sender
{
	[[Config sharedInstance]setAutoUpdate:([sender state] == NSOnState)];
}

-(void) systemInfoButtonClick:(id)sender
{
	[[Config sharedInstance]setSubmitSystemInformation:([sender state] == NSOnState)];
}

-(void) refreshCharButtonClick:(id)sender
{
	[[Config sharedInstance]setStartupRefresh:([sender state] == NSOnState)];
}

-(void) batchUpdateCharacters:(id)sender
{
	[[Config sharedInstance]setBatchUpdateCharacters:([sender state] == NSOnState)];
}

-(void)awakeFromNib
{
	Config *cfg = [Config sharedInstance];
	
	[autoUpdateButton setState:([cfg autoUpdate] ? NSOnState : NSOffState)];
	[systemInfoButton setState:([cfg submitSystemInformation] ? NSOnState : NSOffState)];
	[batchUpdateButton setState:([cfg batchUpdateCharacters] ? NSOnState : NSOffState)];
	
}

-(id)init
{
	if(self = [super initWithNibName:@"PreferencesGeneral" bundle:nil]){
		[self setTitle:@"General Settings"];
		name = @"General Settings";
	}
	
	return self;
}

@end
