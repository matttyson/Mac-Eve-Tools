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

#import "MainController.h"
#import "CharacterSheetController.h"
#import "MTCharacterOverviewCell.h"
#import "Config.h"
#import "GlobalData.h"
#import "Character.h"
#import "Account.h"
#import "SkillTree.h"
#import "Helpers.h"
#import "SkillPlanController.h"
#import "CharacterDatabase.h"
#import "ServerMonitor.h"
#import "EvemonXmlPlanIO.h"
#import "SkillPlan.h"
#import "METPluggableView.h"
#import "CharacterManager.h"


#import "DBManager.h"

#ifdef HAVE_SPARKLE
#import <Sparkle/Sparkle.h>
#endif


#pragma mark MainController

#define WINDOW_SAVE_NAME @"MainWindowSave"

@interface MainController (MainControllerPrivate)

-(void)prefWindowWillClose:(NSNotification *)notification;
-(void)updatePopupButton;

-(void) setAsActiveView:(id<METPluggableView>)mvc;

-(void) serverStatus:(ServerStatus)status;
-(void) serverPlayerCount:(NSInteger)playerCount;

-(void) setStatusImage:(StatusImageState)state;
-(void) statusMessage:(NSString*)message;
@end


@implementation MainController (MainControllerPrivate)

-(void) setStatusImage:(enum StatusImageState)state
{
	if(state != StatusHidden){
		[statusImage setHidden:NO];
		[statusImage setEnabled:YES];
	}
	
	switch (state) {
		case StatusHidden:
			[statusImage setHidden:YES];
			[statusImage setEnabled:NO];
			break;
		case StatusGreen:
			[statusImage setImage:[NSImage imageNamed:@"green.tiff"]];
			break;
		case StatusYellow:
			[statusImage setImage:[NSImage imageNamed:@"yellow.tiff"]];
			break;
		case StatusRed:
			[statusImage setImage:[NSImage imageNamed:@"red.tiff"]];
			break;
		case StatusGray:
			[statusImage setImage:[NSImage imageNamed:@"gray.tiff"]];
			break;
		default:
			break;
	}
}


-(void) statusMessage:(NSString*)message
{
	if(message == nil){
		[statusString setHidden:YES];
		return;
	}
	[statusString setHidden:NO];
	[statusString setStringValue:message];
	[statusString sizeToFit];
}

-(void) clearTimer:(NSTimer*)theTimer
{
	@synchronized(self)
	{
		/*timer is now invalidated*/
		statusMessageTimer = nil;
		[self statusMessage:nil];
		[self setStatusImage:StatusHidden];
	}
}

-(void) setStatusMessage:(NSString*)message 
			  imageState:(enum StatusImageState)state
					time:(NSInteger)seconds
{
	@synchronized(self)
	{
		if(statusMessageTimer != nil){
			[statusMessageTimer invalidate];
			statusMessageTimer = nil;
		}
	
		//if zero, display forever.
		if(seconds == 0){
			[self statusMessage:message];
			return;
		}
		
		[self setStatusImage:state];
		
		[self statusMessage:message];
		statusMessageTimer = [NSTimer timerWithTimeInterval:(NSTimeInterval)seconds
													 target:self
												   selector:@selector(clearTimer:)
												   userInfo:nil
													repeats:NO];
		[[NSRunLoop currentRunLoop]addTimer:statusMessageTimer forMode:NSDefaultRunLoopMode];
	}
}


-(void) serverStatus:(ServerStatus)status
{
	switch(status)
	{
		case ServerUp:
			[serverStatus setImage:[NSImage imageNamed:@"green.tiff"]];
			break;
		case ServerDown:
			[serverStatus setImage:[NSImage imageNamed:@"red.tiff"]];
			break;
		case ServerUnknown:
			[serverStatus setImage:[NSImage imageNamed:@"lightgray.tiff"]];
			break;
	}
}

-(void) serverPlayerCount:(NSInteger)playerCount
{
	NSString *str = @"Tranquility";
	if(playerCount > 0){
		str = [str stringByAppendingFormat:@" (%ld)",playerCount];
	}
	[serverName setStringValue:str];
}

/*NSApplication delegate*/

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication 
					hasVisibleWindows:(BOOL)flag
{
	if (!flag)
	{
		[[self window] makeKeyAndOrderFront:self];
		[[self window] makeMainWindow];
	}
	
	return YES;
}

/*NSWindow delegate*/
-(BOOL) windowShouldClose:(id)window
{
	[window orderOut:self]; //Don't close the window, just hide it.
	return NO;
}

-(void) appWillTerminate:(NSNotification*)notification
{
	NSLog(@"Shutting down");
	
	[monitor stopMonitoring];
	[[self window]saveFrameUsingName:WINDOW_SAVE_NAME];
	
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	
	xmlCleanupParser();
}


-(void) updatePopupButton
{
	NSArray *charArray = [characterManager allCharacters];
	[charButton removeAllItems];
	
	if([charArray count] > 0){
		[charButton setEnabled:YES];
		
		NSMenu *menu;
		menu = [[NSMenu alloc] initWithTitle:@""];
		NSMenuItem *defaultItem = nil;
		
		for(Character *c in charArray){
			
			NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[c characterName] action:nil keyEquivalent:@""];
			[item setRepresentedObject:c];
			[menu addItem:item];
						
			[item release];
		}
		
		[charButton setMenu:menu];
		[menu release];

//		Select the default item.
//		[charButton selectItem:defaultItem];
		
	}else{
		//No characters enabled. disable the control.
		[charButton setEnabled:NO];
	}
}

/*reload the datasource with new characters*/
-(void) reloadAllCharacters
{
	//returns YES if the delegate will be called
	BOOL rc = [characterManager setTemplateArray:[[Config sharedInstance] activeCharacters] delegate:self];
	
	//reload the drawer datasource.
	if(!rc){
		//Characters are all on disk. delegaete will not be called.
		[overviewTableView reloadData];
		//Redo the popup button.
		[self updatePopupButton];
	}//else - work done in delegate
}


/*
 check to see if the current database is the right version,
 Download a new version if required.
 */
-(void) databaseReadyToCheck:(NSNotification *)notification
{
	DBManager *manager = [[[DBManager alloc]init]autorelease];
	
	if(![manager dbVersionCheck:[[Config sharedInstance] databaseMinimumVersion]]){
		[manager checkForUpdate2];
		[[NSNotificationCenter defaultCenter]addObserver:self 
												selector:@selector(databaseReadyToBuild:)
													name:NOTE_DATABASE_DOWNLOAD_COMPLETE
												  object:nil];
	}else{
		/*database version is current - launch app normally*/
		[self performSelector:@selector(launchAppFinal:) withObject:nil];
	}	
}

/*
 check to see if there is a database ready to be built.
 this should be called automaticlly by the databaseReadyToCheck notification.
 */
-(void) databaseReadyToBuild:(NSNotification*)notification
{
	[[NSNotificationCenter defaultCenter]removeObserver:self
												   name:NOTE_DATABASE_DOWNLOAD_COMPLETE
												 object:nil];
	
	DBManager *manager = [[[DBManager alloc]init]autorelease];
	
	//check to see if there is a new database ready to be built
	if([manager databaseReadyToBuild]){
		//Yes there is.  Build it.
		[manager buildDatabase2:@selector(launchAppFinal:) obj:self];
	}else{
		/*this shouldn't happen*/
		[self performSelector:@selector(launchAppFinal:) withObject:nil];
	}
}

/*called once the program has finished loading, but before the window appears.*/
-(void) appIsActive:(NSNotification*)notification
{
	/*event will not happen again, no need to listen for it*/
	[[NSNotificationCenter defaultCenter]
		removeObserver:self
		name:NSApplicationDidBecomeActiveNotification
	 object:NSApp];
	
	xmlInitParser(); //Init libxml2

	/*
	 The 'Requisite Files' thing no longer applies.
	 The Database is now a mandatory download
	 Mac Eve Tools cannot function without it.
	 */
	
	[self databaseReadyToCheck:nil];
}

/*
 Launch the application proper, display the window to the user.
 */
-(void) launchAppFinal:(id)obj
{	
	
	Config *cfg = [Config sharedInstance];
	
	////////////// ---- THIS BLOCK MUST EXECUTE BEFORE ANY OTHER CODE ---- \\\\\\\\\\\\\\\\
	[[GlobalData sharedInstance]skillTree];
	[[GlobalData sharedInstance]certTree];
	////////////// ---- BLOCK END ---- \\\\\\\\\\\\\\\\
	
	/*init the views that will be used by this window*/
	
	[[self window] makeKeyAndOrderFront:self];
	
	id<METPluggableView> mvc;
	mvc = [[CharacterSheetController alloc]init];
	[mvc view];//trigger the awakeFromNib
	[mvc setInstance:self];
	[viewControllers addObject:mvc];
	[(NSObject*)mvc release];
	
	/*
	 
	Menu Item for importing evemon plans.  This doesn't work properly yet and shouldn't be included.
	 
	id<METPluggableView> view = [viewControllers objectAtIndex:1];
	NSMenuItem *menuItem = [view menuItems];
	if(menuItem != nil){
		[[NSApp mainMenu]insertItem:menuItem atIndex:1];
	}
	*/
	
	/*because of the threading and preloading the skill planner will awake early*/

	
	mvc = [[SkillPlanController alloc]init];
	[mvc view];//trigger the awakeFromNib
	[mvc setInstance:self];
	[viewControllers addObject:mvc];
	[(NSObject*)mvc release];
	
	
	[[self window] makeMainWindow];
	[[self window] setDelegate:self];
	[NSApp setDelegate:self];
		
#ifdef HAVE_SPARKLE
	SUUpdater *updater = [SUUpdater sharedUpdater];
	[updater setAutomaticallyChecksForUpdates:NO];
	[updater setFeedURL:[NSURL URLWithString:[cfg updateFeedUrl]]];
	[updater setSendsSystemProfile:[cfg submitSystemInformation]];	
#endif
	
	if([[cfg accounts] count] == 0){
		[NSApp beginSheet:noCharsPanel
		   modalForWindow:[self window]
			modalDelegate:nil
		   didEndSelector:NULL
			  contextInfo:NULL];
	}
#ifdef HAVE_SPARKLE
	else{
		if([cfg autoUpdate]){
			[[SUUpdater sharedUpdater]checkForUpdatesInBackground];
		}
	}
#endif
	
	//Set the character sheet as the active view.
	mvc = [viewControllers objectAtIndex:VIEW_CHARSHEET];
	[self setAsActiveView:mvc];
	
	// init the character manager object.
	characterManager = [[CharacterManager alloc]init];
	[characterManager setTemplateArray:[cfg activeCharacters] delegate:self];
	
	[overviewTableView setDataSource:characterManager];
	[overviewTableView setDelegate:characterManager];
	[overviewTableView reloadData];
	
	[self performSelector:@selector(setCurrentCharacter:) 
			   withObject:[characterManager defaultCharacter]];
	
	[self updatePopupButton];
		
	/*check to see if the server is up*/
	[self serverStatus:ServerUnknown];
	[monitor startMonitoring];
}

-(void) setAsActiveView:(id<METPluggableView>)mvc
{
	if(mvc == currentController){
		return;
	}
	
	id<METPluggableView> old = currentController;
	currentController = mvc;
	[old viewWillBeDeactivated];
	[mvc viewWillBeActivated];

	[viewBox setContentView:[mvc view]];
	[old viewIsInactive];
	if(currentCharacter != nil){
		[mvc setCharacter:currentCharacter];
	}
	[mvc viewIsActive];
}

-(void) prefWindowWillClose:(NSNotification *)notification
{
#ifndef MACEVEAPI_DEBUG
	[NSApp stopModal];
#endif
	[self reloadAllCharacters];
	[overviewTableView reloadData];
}

@end

@implementation MainController

-(void) dealloc
{
	[viewControllers release];
	[super dealloc];
}

-(id)init
{
	if((self = [super initWithWindowNibName:@"MainMenu"])){
		viewControllers = [[NSMutableArray alloc]init];
				
		/*Some notifications that we want to listen to*/
		[[NSNotificationCenter defaultCenter]
		 addObserver:self 
		 selector:@selector(appIsActive:) 
		 name:NSApplicationDidBecomeActiveNotification 
		 object:NSApp];	
		
		[[NSNotificationCenter defaultCenter]
		 addObserver:self 
		 selector:@selector(appWillTerminate:) 
		 name:NSApplicationWillTerminateNotification 
		 object:NSApp];
		
		monitor = [[ServerMonitor alloc]init];
		[[NSNotificationCenter defaultCenter]
		 addObserver:self 
		 selector:@selector(serverStatusUpdate:) 
		 name:SERVER_STATUS_NOTIFICATION 
		 object:monitor];
	}
	
	return self;
}


-(void) awakeFromNib
{
	NSLog(@"Awoken from nib");
	
	NSWindow *window = [self window];
	[window setRepresentedFilename:WINDOW_SAVE_NAME];
	[window setFrameAutosaveName:WINDOW_SAVE_NAME];
		
	[noCharsPanel setDefaultButtonCell:[noCharsButton cell]]; //alert if you don't have an account set up
	
	[window setContentBorderThickness:30.0 forEdge:NSMinYEdge];
	[[serverName cell] setBackgroundStyle:NSBackgroundStyleRaised];
	[[statusString cell] setBackgroundStyle:NSBackgroundStyleRaised];
	
	/*add the menu item*/
	/*
	for(id<METPluggableView> v in viewControllers){
		NSMenuItem *menuItem = [v menuItems];
		if(menuItem != nil){
			[[NSApp mainMenu]insertItem:menuItem atIndex:1];
			//[[NSApp mainMenu]addItem:menuItem];
		}
	}*/
		
	/*
		notify when the selection of the overview tableview has changed.
	 */
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(charOverviewSelection:)
	 name:NSTableViewSelectionDidChangeNotification
	 object:overviewTableView];
	
	statusMessageTimer = nil;
}

-(void) setCurrentCharacter:(Character*)character
{
	if(character == nil){
		return;
	}
	if(currentCharacter != nil){
		[currentCharacter release];
	}
	
	currentCharacter = [character retain];
	
	[charButton selectItemWithTitle:[character characterName]];
	
	[characterButton setImage:[character portrait]];
	[characterButton setLabel:[character characterName]];
	
	if(currentController != nil){
		[currentController setCharacter:currentCharacter];
	}
	
	NSLog(@"Current character is %@",[currentCharacter characterName]);
	
	[[self window]setTitle:[NSString stringWithFormat:@"Mac Eve Tools - %@",[currentCharacter characterName]]];
}

-(IBAction)charSelectorClick:(id)sender
{
	NSMenuItem *item = [(NSPopUpButton*)sender selectedItem];
	
	[self setCurrentCharacter:[item representedObject]];
}

-(void) updateActiveCharacter
{
	//Get the id for the current character, find the new object in the character manager.
	Character *character = [characterManager characterById:[currentCharacter characterId]];
	if(character == nil){
		NSLog(@"ERROR: Couldn't find character %lu.  Can't update.",[currentCharacter characterId]);
		return;
	}
	[self setCurrentCharacter:character];
}

#pragma mark Character update delegate
//Called from the character manager class.

-(void) batchUpdateOperationDone:(NSArray*)errors
{
	// All characters have been updated.
	NSLog(@"Finished batch update operation");
	
	
	[statusString setHidden:YES];
	[fetchCharButton setEnabled:YES];
	[charButton setEnabled:YES];
	
	/*
	 replace this with a new message that says update completed
	 and then have a timer that will clear the message after X seconds.
	 Need to be careful with race conditions, however.
	 
	 Ideally we want to be able to provide a simple error message here,
	 however this may not be possible because we are updating a bunch of
	 characters, each with possibly a different error message.
	*/
	[self statusMessage:nil];
	
	if(errors != nil){
		[self setStatusMessage:@"Error updating characters" imageState:StatusRed time:5];
	}else{
		[self setStatusMessage:@"Update Completed" imageState:StatusGreen time:5];
	}
	
	//reload the datasource for the character overview.
	[overviewTableView reloadData];
	
	//now we need to present the new character object to the active view.
	
	[self updateActiveCharacter];
}

-(void) updateAllCharacters
{
	[self statusMessage:@"Updating Characters"];
	[characterManager updateAllCharacters:self];
	[fetchCharButton setEnabled:NO];
	[charButton setEnabled:NO];
}

-(IBAction) fetchCharButtonClick:(id)sender
{
//	if([[Config sharedInstance]batchUpdateCharacters]){
		[self updateAllCharacters];
//	}else{
//		[self updateActiveCharacter];
//	}
}

-(IBAction) showPrefPanel:(id)sender;
{
	if(prefPanel == nil){
		prefPanel = [[PreferenceController alloc]init];
		[[NSNotificationCenter defaultCenter]
		 addObserver:self 
			selector:@selector(prefWindowWillClose:)
				name:NSWindowWillCloseNotification 
		 object:[prefPanel window]];
	}
	
	//NSLog(@"Opening pref pane %@",[self window]);
#ifdef MACEVEAPI_DEBUG
	[prefPanel showWindow:self]; //if it crashes in a modal window it's impossible to debug
#else
	[NSApp runModalForWindow:[prefPanel window]];
#endif
}

-(IBAction) toolbarButtonClick:(id)sender
{
	if([sender tag] == -1){
		[overviewDrawer toggle:self];
		return;
	}
	
	id<METPluggableView> mvc = [viewControllers objectAtIndex:[sender tag]];
	
	NSMenuItem *item;
	
	//Check to see if the current controller has a menu item.
	item = [currentController menuItems];
	if(item != nil){
		[[NSApp mainMenu]removeItemAtIndex:1];
	}
	
	[self setStatusMessage:nil imageState:StatusHidden time:0];//clear any toolbar message.
	[self setAsActiveView:mvc];
	
	//	remove the old one(if it exists) add the new one.
	item = [mvc menuItems];
	if(item != nil){
		[[NSApp mainMenu]insertItem:item atIndex:1];
	}
}

-(IBAction) viewSelectorClick:(id)sender
{
	NSMenuItem *item = [sender selectedItem];
	
	id<METPluggableView> mvc = [item representedObject];
	 
	[self setAsActiveView:mvc];
}

/*called to dismiss the panel that appears if you have no characaters*/
-(IBAction) noCharsButtonClick:(id)sender
{
	[NSApp endSheet:noCharsPanel];
	[noCharsPanel orderOut:sender];
	[self showPrefPanel:nil];
}

-(IBAction) checkForUpdates:(id)sender
{
#ifdef HAVE_SPARKLE
	SUUpdater *updater = [SUUpdater sharedUpdater];
	[updater checkForUpdates:[self window]];
#endif
}

-(void) newDatabaseAvailable:(DBManager*)manager status:(BOOL)status
{
	if(!status){
		NSRunAlertPanel(@"Database is up to date",
						@"You have the lastest database version", 
						@"Close",nil,nil);
		return;
	}
	NSInteger result = NSRunAlertPanel(@"New database available",
								 @"Do you wish to download the new item database?", 
								 @"Download",
								 @"Ignore", 
								 nil);
	
	switch (result) {
		case NSAlertDefaultReturn:
		//	[dbManager downloadDatabase:[self window]];
			break;
		default:
			break;
	}
}

-(IBAction) checkForDatabase:(id)sender
{
	//[dbManager performCheck];
}

-(void) serverStatusUpdate:(NSNotification*)notification
{
	[self serverStatus:[monitor status]];
	[self serverPlayerCount:[monitor numPlayers]];
}

-(void) charOverviewClick:(NSTableView*)sender
{
	NSInteger row = [sender selectedRow];
	if(row == -1){
		return;
	}
	
	[self setCurrentCharacter:[(CharacterManager*)[sender dataSource]characterAtIndex:row]];
}

-(void) charOverviewSelection:(NSNotification*)notification
{
	[self charOverviewClick:[notification object]];
}

-(void) setToolbarMessage:(NSString *)message
{
	//Set a permanat message
	[self setStatusMessage:message 
				imageState:StatusHidden
					  time:0];
}

-(void) setToolbarMessage:(NSString*)message time:(NSInteger)seconds
{
	[self setStatusMessage:message imageState:StatusHidden time:seconds];
}

@end
