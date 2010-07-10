//
//  AccountViewController.m
//  Mac Eve Tools
//
//  Created by Sebastian Kruemling on 19.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AccountPrefViewController.h"

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

@implementation AccountPrefViewController

- (void) awakeFromNib {
	
		// both are needed, otherwise hyperlink won't accept mousedown
    [apiKeyUrl setAllowsEditingTextAttributes: YES];
    [apiKeyUrl setSelectable: YES];
	
    NSURL* apiServiceUrl = [NSURL URLWithString:@"http://www.eveonline.com/api/default.asp"];
	
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] init];
    [string appendAttributedString: [NSAttributedString hyperlinkFromString:NSLocalizedString(@"Need your API Key? Click here", nil) withURL:apiServiceUrl]];
	
		// set the attributed string to the NSTextField
    [apiKeyUrl setAttributedStringValue: string];
	[apiKeyUrl sizeToFit];
	[string release];
}

- (NSString *)title
{
	return NSLocalizedString(@"Accounts", @"Account management");
}

- (NSString *)identifier
{
	return @"AccountPrefView";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"icon12_02"];
}

- (void) willBeClosed {
	[accountTableController savePreferences];
}

- (void) willBeDisplayed {
	[accountTableController refreshAccountsFromSettings];
}

@end
