//
//  CharacterParseError.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 4/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CharacterParseError : NSObject {
	NSInteger errorCode;
	NSString *errorDescription;
	
	NSString *sheetName;
	NSString *characterName;
}

@property (nonatomic,readonly) NSInteger errorCode;
@property (nonatomic,readonly) NSString* errorDescription;

-(CharacterParseError*) initWithError:(NSString*)message 
								 code:(NSInteger)code
							 xmlSheet:(NSString*)xmlSheet;


@end
