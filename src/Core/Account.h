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
@class CharacterTemplate;

@protocol AccountUpdateDelegate

/*
	passes in the Account* object when the account finishes updating
	didSucceed: YES on successful download, NO on error
 */

-(void) accountDidUpdate:(id)acct didSucceed:(BOOL)success;

@end


/*
	An Account object contains all the characters for a given account
	Create this object to fetch all the characters for that account.
	then, you can pick and choose what characters you care about for that account
*/

@interface Account : NSObject <NSCoding> { //<NSTableViewDataSource, NSCoding> {
	NSString *accountID;
	NSString *apiKey;
	NSString *accountName; /*user supplied name to identify this account*/
	
	/*an array of all characters that belong to this account, regardless of active state*/
	NSMutableArray *characters; //CharacterTemplates
	
	id <AccountUpdateDelegate> delegate;
}

@property (retain) NSString* accountID;
@property (retain) NSString* apiKey;
@property (retain) NSString* accountName;
@property (retain) NSMutableArray *characters;

/*This sets up the internal variables, it does not populate the characters*/
-(Account*) initWithDetails:(NSString*)acctID acctKey:(NSString*)key;
-(Account*) initWithName:(NSString*)name;

/*
	Refresh from disk (if the file exists). if not, download from the web
	returns
		YES if loaded from disk. deleagte will not be called.
		NO if downloading from API site. delegate will be called
 */
-(void) loadAccount:(id<AccountUpdateDelegate>)del; /*read xml file off disk*/
-(void) loadAccount:(id<AccountUpdateDelegate>)del runForModalWindow:(BOOL)modal;

/*Force redownload from web*/
-(void) fetchCharacters:(id<AccountUpdateDelegate>)del;

-(NSInteger) characterCount;
-(NSArray*) characters;


/*NSTableView datasource methods for displaying characters*/
	//- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
	//- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;

/*find a character in this account with the given name*/
-(CharacterTemplate*) findCharacter:(NSString*)charName;


@end
