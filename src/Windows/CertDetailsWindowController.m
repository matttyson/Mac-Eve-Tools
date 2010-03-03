//
//  CertDetailsWindowController.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 27/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CertDetailsWindowController.h"

#import "CertPrerequisiteDatasource.h"

#import "Character.h"
#import "Cert.h"
#import "CertClass.h"
#import "CertPair.h"
#import "CertTree.h"
#import "SkillPair.h"
#import "GlobalData.h"
#import "SkillPlan.h"
#import "Helpers.h"

#import "assert.h"


@implementation CertDetailsWindowController

-(void) awakeFromNib
{
	[certPrerequisites setIndentationMarkerFollowsCell:YES];
}

-(id) initWithCert:(Cert*)cer forCharacter:(Character*)ch
{
	if((self = [super initWithWindowNibName:@"CertDetails"])){
		cert = [cer retain];
		character = [ch retain];
		certDS = [[CertPrerequisiteDatasource alloc]initWithCert:cert forCharacter:character];
	}
	
	return self;
}

-(void)dealloc
{
	[cert release];
	[character release];
	[certPrerequisites setDataSource:nil];
	[certDS release];
	[super dealloc];
}

-(void) setLabels
{
	[certDescription setStringValue:[cert certDescription]];
	//[certDescription sizeToFit];
}

-(void) setDatasource
{
	[certPrerequisites setDataSource:certDS];
}

+(void) displayWindowForCert:(Cert*)cer character:(Character*)ch
{
	//Shut up you stupid compiler.
	CertDetailsWindowController *wc = [(CertDetailsWindowController*)
									   [CertDetailsWindowController alloc]initWithCert:cer
																		  forCharacter:ch];
	[[wc window]makeKeyAndOrderFront:nil];
}

-(void) windowWillClose:(NSNotification*)note
{
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	[self autorelease];
}

-(void) calculateTimeToTrain
{
	//Normally skill plans should be created using the character object, but we don't
	//want to save this plan
	
	NSString *text;
	
	[miniPortrait setImage:[character portrait]];
	
	if([character hasCert:[cert certID]]){
		text = [NSString stringWithFormat:
				NSLocalizedString(@"%@ has this certificate",@"<@CharacterName> has this cert"),
				[character characterName]];
	}else {
		SkillPlan *plan = [[SkillPlan alloc]initWithName:@"--TEST--" character:character];
		[plan addSkillArrayToPlan:[cert certChainPrereqs]];
		
		NSInteger timeToTrain = [plan trainingTime];
		
		[plan release];
		
		if(timeToTrain == 0){
			text = [NSString stringWithFormat:
					NSLocalizedString(@"%@ has not claimed this certificate",@"<@CharacterName> has not claimed this cert"),
					[character characterName]];
		}else{
			NSString *timeToTrainString = stringTrainingTime(timeToTrain);
			text = [NSString stringWithFormat:
					NSLocalizedString(@"%@ could have this certificate in %@",@"<@CharacterName"),
					[character characterName],timeToTrainString];
		}
	}
	
	[trainingTime setStringValue:text];
}

-(void) windowDidLoad
{
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self
	 selector:@selector(windowWillClose:)
	 name:NSWindowWillCloseNotification
	 object:[self window]];
	
	[self calculateTimeToTrain];
	[self setLabels];
	[self setDatasource];
	[[self window]setTitle:[cert fullCertName]];
}


#pragma mark OutlineView datasource methods.

@end
