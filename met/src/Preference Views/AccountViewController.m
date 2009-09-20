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

#import "AccountViewController.h"

#import "Character.h"
#import "CharacterTemplate.h"

@interface NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
@end

@implementation NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL
{
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
    NSRange range = NSMakeRange(0, [attrString length]);
	
    [attrString beginEditing];
    [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
	
    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
	
    // next make the text appear with an underline
    [attrString addAttribute:
	 NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
	
    [attrString endEditing];
	
    return [attrString autorelease];
}
@end

@interface AccountViewController (AccountViewControllerPrivate) <AccountUpdateDelegate>


-(void) setTextboxes;
-(void) updateAccount; /*saves the text field values into the account object*/
-(void) updateCharacterList;

-(void) accountDidUpdate:(id)acct didSucceed:(BOOL)success;

//dragging delegates
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender;
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;

@end


@implementation AccountViewController (AccountViewControllerPrivate)

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
	
	if( sourceDragMask & NSDragOperationCopy){
		return NSDragOperationCopy;
	}
	
	return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPoint destination = 
		[[self view]convertPoint:[sender draggingLocation] fromView:nil];
	
	NSRect bounds = [acctName bounds];
	
	if(NSPointInRect(destination,bounds)){
		NSLog(@"Yay!");
	}
	return YES;
}



-(void) updateCharacterList
{
	[characterList setDataSource:account];
	[characterList reloadData];
}

-(void) accountDidUpdate:(id)acct didSucceed:(BOOL)success
{
	[progressIndicator stopAnimation:self];
	[characterList setDataSource:account];
	[characterList reloadData];
	[progressIndicator setHidden:YES];
	NSLog(@"account update finished");
}

-(void) setTextboxes
{
	if(account == nil){
		return;
	}
	NSString *str;
	
	if((str = [account accountName]) != nil){
		[acctName setStringValue:str];
	}
	if((str = [account accountID]) != nil){
		[acctId setStringValue:str];
	}
	if((str = [account apiKey]) != nil){
		[acctKey setStringValue:str];
	}
}

-(void) updateAccount
{
	[account setAccountName:[acctName stringValue]];
	[account setAccountID:[acctId stringValue]];
	[account setApiKey:[acctKey stringValue]];
}

@end


@implementation AccountViewController

-(AccountViewController*) init
{
	if(self = [super initWithNibName:@"PreferenceAccount" bundle:nil]){
		[self setTitle:@"Accounts"];
	}
	
	return self;
}

-(AccountViewController*) initWithAccount:(Account*)acct
{
	if([self init]){
		account = acct;
	}
	return self;
}

-(void)awakeFromNib
{
	[acctName setDelegate:self];
	if(account != nil){
		[characterList setDataSource:account];
	}
	[self setTextboxes];
	
    // both are needed, otherwise hyperlink won't accept mousedown
    [url setAllowsEditingTextAttributes: YES];
    [url setSelectable: YES];
	
    NSURL* apiurl = [NSURL URLWithString:@"http://www.eveonline.com/api/default.asp"];
	
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] init];
    [string appendAttributedString: [NSAttributedString hyperlinkFromString:@"Need your API Key? Click here" withURL:apiurl]];
	
    // set the attributed string to the NSTextField
    [url setAttributedStringValue: string];
	[url sizeToFit];
	[string release];
	
	[progressIndicator setHidden:YES];
}

-(Account*) account
{
	return account;
}

-(void) setAccount:(Account*)acct
{
	if(account != nil){
		[characterList setDataSource:nil];
		[account release];
		account = nil;
	}
	
	if(acct == nil){
		return;
	}
	
	account = [acct retain];
	[self setTextboxes];
	[characterList setDataSource:account];
}

-(IBAction) characterActiveCellButtonClick:(id)sender
{
	// what the hell? yes it does you retard compiler
	//[[[account characters]objectAtIndex:[sender selectedRow]]toggleActiveState];
	CharacterTemplate *template = [[account characters]objectAtIndex:[sender selectedRow]];
	[template setActive:![template active]];
	[sender setNeedsDisplayInRect:[sender frameOfCellAtColumn:1 row:[sender selectedRow]]];
}

-(NSString*) accountName
{
	return [acctName stringValue];
}

-(void) setAccountName:(NSString*)accountName
{
	[acctName setStringValue:accountName];
}

-(NSString*) accountId
{
	return [acctId stringValue];
}

-(void) setAccountId:(NSString*)accountId
{
	return [acctId setStringValue:accountId];
}

-(NSString*) apiKey
{
	return [acctKey stringValue];
}

-(void) setApiKey:(NSString*)newApiKey
{
	[acctKey setStringValue:newApiKey];
}

-(IBAction) updateButtonClick:(id)sender
{
	[self updateAccount];
	[account loadAccount:self runForModalWindow:YES];
	[progressIndicator setHidden:NO];
	[progressIndicator startAnimation:self];
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	NSLog(@"%@",[aNotification name]);
	[account setAccountName:[acctName stringValue]];
	[pc updatePrefList];
}

@end
