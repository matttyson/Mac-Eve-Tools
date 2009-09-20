//
//  MainViewController.m
//  guitest1
//
//  Created by Matt Tyson on 1/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"


@implementation MainViewController

/*
-(MainViewController*) init
{
	
}
*/



-(Character*) character //get the selected character
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(void) setCharacter:(Character*)c  //the user has changed the actively selected character
{
	[self doesNotRecognizeSelector:_cmd];	
}

-(void) viewIsActive
{
	[self doesNotRecognizeSelector:_cmd];
}
-(void) viewIsInactive
{
	[self doesNotRecognizeSelector:_cmd]; 
}
-(void) viewWillBeDeactivated
{
	[self doesNotRecognizeSelector:_cmd]; 
}
-(void) viewWillBeActivated
{
	[self doesNotRecognizeSelector:_cmd];
}

@end
