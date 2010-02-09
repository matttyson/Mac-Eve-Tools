//
//  DatabaseViewController.m
//  Mac Eve Tools
//
//  Created by Matt Tyson on 3/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DatabaseViewController.h"

#import "CCPDatabase.h"
#import "Helpers.h"

@implementation DatabaseViewController

-(DatabaseViewController*) init
{
	if(self = [super initWithNibName:@"PreferenceDatabase" bundle:nil]){
		name = @"Database";
		[self setTitle:name];
	}
	return self;
}

-(void) showVersion
{
	CCPDatabase *db;
	
	NSString *path = [[Config sharedInstance]itemDBPath];
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if([fm fileExistsAtPath:path]){
		db = [[CCPDatabase alloc]initWithPath:path];
		
		NSString *verName = [db dbName];
		//NSInteger verNum = [db dbVersion];
		
		[db release];
		[dbVersionLabel setStringValue:verName];
		[dbVersionLabel sizeToFit];
		
		NSDictionary *dict = [fm attributesOfItemAtPath:path error:NULL];
		NSNumber *szNum = [dict valueForKey:NSFileSize];
		unsigned long long sz = [szNum unsignedLongLongValue];
		
		double szF = (double)sz / (double)(1024 * 1024);
		
		NSString *fileSzStr = [NSString stringWithFormat:@"%.2f MB",szF];
		[dbSize setStringValue:fileSzStr];
		[dbSize sizeToFit];
	}else{
		[dbVersionLabel setStringValue:@"N/A"];
		[dbVersionLabel sizeToFit];
		[dbSize setStringValue:@"N/A"];
		[dbSize sizeToFit];
	}
}

-(void) languageSelection
{
	NSMenu *menu = [[[NSMenu alloc]initWithTitle:@"Menu"]autorelease];
	
	NSMenuItem *item;
	
	enum DatabaseLanguage lang = [[Config sharedInstance]dbLanguage];
	
	item = [[NSMenuItem alloc]initWithTitle:languageForId(l_EN) action:NULL keyEquivalent:@""];
	[item setTag:l_EN];
	[menu addItem:item];
	[item release];
	
	item = [[NSMenuItem alloc]initWithTitle:languageForId(l_DE) action:NULL keyEquivalent:@""];
	[item setTag:l_DE];
	[menu addItem:item];
	[item release];
	
	item = [[NSMenuItem alloc]initWithTitle:languageForId(l_RU) action:NULL keyEquivalent:@""];
	[item setTag:l_RU];
	[menu addItem:item];
	[item release];
	
	[langSelector setMenu:menu];
		
	[langSelector selectItemWithTag:lang];
}

-(void) awakeFromNib
{
	[self showVersion];
	[self languageSelection];
}

-(IBAction) languageSelectionClick:(id)sender
{
	enum DatabaseLanguage lang = [[sender selectedItem]tag];
	
	[[Config sharedInstance]setDbLanguage:lang];
	
	[restartWarning setHidden:NO];
}

@end
