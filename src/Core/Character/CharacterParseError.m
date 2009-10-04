//
//  CharacterParseError.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 4/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CharacterParseError.h"


@implementation CharacterParseError

@synthesize errorCode;
@synthesize errorDescription;

-(CharacterParseError*) initWithError:(NSString*)message 
								 code:(NSInteger)code
							 xmlSheet:(NSString*)xmlSheet

{
	if((self = [super init])){
		errorDescription = [message retain];
		errorCode = code;
		sheetName = [xmlSheet retain];
	}
	return self;
}

-(void)dealloc
{
	[sheetName release];
	[errorDescription release];
	[super dealloc];
}

@end
