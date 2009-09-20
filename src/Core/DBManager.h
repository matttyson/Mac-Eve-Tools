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

@class DBManager;

@protocol DBManagerDelegate

/*
	called if a new database is ready
	returns YES if a new version is ready to download.
 */
-(void) newDatabaseAvailable:(DBManager*)manager status:(BOOL)status;

@end


@interface DBManager : NSObject {
	NSInteger availableVersion;
	
	NSString *sha1_bzip;
	NSString *sha1_dec;
	NSString *sha1_database;
	NSString *file;
	
	id<DBManagerDelegate> delegate;
	
	IBOutlet NSPanel *progressPanel;
	IBOutlet NSButton *closeButton;
	IBOutlet NSTextField *textField;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *title;
	
	NSURLResponse *downloadResponse;
	NSUInteger bytesReceived;
}

-(NSInteger) currentVersion;
-(NSInteger) availableVersion;

/*returns YES if there is a new database waiting to be installed.*/
-(BOOL) databaseReadyToBuild;
/*display the modal window and build the database*/
-(void) buildDatabase:(id)sender;

/*kick off a database version check*/
-(void) performCheck;

/*download the update*/
-(void) downloadDatabase:(id)object;

-(void) setDelegate:(id<DBManagerDelegate>)del;
-(id<DBManagerDelegate>) delegate;
-(IBAction) closeSheet:(id)sender;

@end
