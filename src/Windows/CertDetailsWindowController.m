//
//  CertDetailsWindowController.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 27/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CertDetailsWindowController.h"

#import "Character.h"
#import "Cert.h"
#import "CertClass.h"
#import "CertPair.h"
#import "SkillPair.h"
#import "GlobalData.h"
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
	}
	
	return self;
}

-(void)dealloc
{
	[cert release];
	[character release];
	[super dealloc];
}

-(void) setLabels
{
	[certDescription setStringValue:[cert certDescription]];
	//[certDescription sizeToFit];
}

-(void) setDatasource
{
	[certPrerequisites setDataSource:self];
}

+(void) displayWindowForCert:(Cert*)cer character:(Character*)ch
{
	CertDetailsWindowController *wc = [[CertDetailsWindowController alloc]initWithCert:cer
																		  forCharacter:ch];
	[[wc window]makeKeyAndOrderFront:nil];
}

-(void) windowWillClose:(NSNotification*)note
{
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	[self autorelease];
}

-(void) windowDidLoad
{
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self
	 selector:@selector(windowWillClose:)
	 name:NSWindowWillCloseNotification
	 object:[self window]];
	
	[self setLabels];
	[self setDatasource];
	[[self window]setTitle:[cert fullCertName]];
}



#pragma mark OutlineView datasource methods.

-(NSInteger)outlineView:(NSOutlineView *)outlineView 
  numberOfChildrenOfItem:(id)item
{
	if(item == nil){
		return [[cert certPrereqs]count] + [[cert skillPrereqs]count];
	}
	
	if([item isKindOfClass:[CertPair class]]){
		Cert *c = [[[GlobalData sharedInstance]certTree]certForID:[item certID]];
		return [[c certPrereqs]count] + [[c skillPrereqs]count];
	}
	
	if([item isKindOfClass:[SkillPair class]]){
		Skill *s = [[[GlobalData sharedInstance]skillTree]skillForId:[item typeID]];;
		return [[s prerequisites]count];
	}
	
	assert(0);
	
	return 0;
}


-(id) certPairAtIndex:(Cert*)c index:(NSInteger)index
{
	NSInteger certCount = [[c certPrereqs]count];
	if(index < certCount){
		return [[c certPrereqs]objectAtIndex:index];
	}else{
		return [[c skillPrereqs]objectAtIndex:index - certCount];
	}
	return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView 
			child:(NSInteger)index 
		   ofItem:(id)item
{
	/*
	 this is a bit messy, as we need to first count of the cert prerequs, 
	 then move onto skill prereqs if that is greater than than the cert count.
	 */
	if(item == nil){
		return [self certPairAtIndex:cert index:index];
	}
	
	if([item isKindOfClass:[CertPair class]]){
		Cert *c = [[[GlobalData sharedInstance]certTree]certForID:[item certID]];
		return [self certPairAtIndex:c index:index];
	}
	
	if([item isKindOfClass:[SkillPair class]]){
		Skill *s = [[[GlobalData sharedInstance]skillTree]skillForId:[item typeID]];
		return [[s prerequisites]objectAtIndex:index];
	}
	
	NSLog(@"%@",[item className]);
	
	return nil;
}

-(NSAttributedString*) colouredString:(NSString*)str colour:(NSColor*)colour
{
	NSDictionary *dict = [NSDictionary dictionaryWithObject:colour 
													 forKey:NSForegroundColorAttributeName];
	NSAttributedString *astr = [[NSAttributedString alloc]initWithString:str
															  attributes:dict];
	[astr autorelease];
	
	return astr;
}



- (id)outlineView:(NSOutlineView *)outlineView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
		   byItem:(id)item
{
	if(item == nil){
		return @"nil";
	}
	
	if([item isKindOfClass:[SkillPair class]]){
		
		Skill *s = [[character st]skillForId:[(SkillPair*)item typeID]];
		
		NSColor *colour;
		if(s == nil){
			colour = [NSColor redColor];
		}else if([s skillLevel] < [item skillLevel]){
			colour = [NSColor orangeColor];
		}else{
			colour = [NSColor blueColor];
		}
		
		return [self colouredString:[item roman] colour:colour];
	}
	
	if([item isKindOfClass:[CertPair class]]){
		Cert *c = [[[GlobalData sharedInstance]certTree]certForID:[item certID]];
		
		if([character hasCert:[item certID]]){
			return [self colouredString:[c fullCertName] colour:[NSColor blueColor]];
		}
		
		return [c fullCertName];
	}
	
	return [item className];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView 
   isItemExpandable:(id)item
{
	if([item isKindOfClass:[SkillPair class]]){
		Skill *s = [[[GlobalData sharedInstance]skillTree]skillForId:[item typeID]];
		if([[s prerequisites]count] > 0){
			return YES;
		}
	}
	
	if([item isKindOfClass:[CertPair class]]){
		Cert *c = [[[GlobalData sharedInstance]certTree]certForID:[item certID]];
		if([[c certPrereqs]count] > 0){
			return YES;
		}
		if([[c skillPrereqs]count] > 0){
			return YES;
		}
	}
	
	return NO;
}

@end
