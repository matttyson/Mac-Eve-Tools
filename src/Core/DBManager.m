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

#import "DBManager.h"
#import "Config.h"
#import "XmlHelpers.h"
#import "XmlFetcher.h"

#import "bsd-base64.h"

#import <libxml/tree.h>
#import <bzlib.h>
#import <sqlite3.h>
#import <openssl/sha.h>

#import "CCPDatabase.h"

#define DATABASE_BZ2_FILE @"database.sql.bz2"
#define UPDATE_FILE @"MacEveApi-database.xml"

#define DBUPDATE_DEFN @"MacEveApi-database.xml"
#define DATABASE_SQL_BZ2 @"database.sql.bz2"
#define DATABASE_SQL @"database.sql"
#define DATABASE_SQLITE @"database.sqlite"
#define DATABASE_SQLITE_TMP @"database.sqlite.tmp"


@interface DBManager  (DBManagerPrivate) <XmlFetcherDelegate>

-(void) xmlDocumentFinished:(BOOL)status xmlPath:(NSString*)path xmlDocName:(NSString*)docName;

-(void) parseDBXmlVersion:(NSString*)file;

/*
 the fooThread messages are called if you are NOT operating from within the main thread
 */

/*for a progress indicator, can be null*/
-(void) progress:(NSNumber*)currentProgress;
-(void) progressThread:(double)currentProgress;
/*a message to display to the user about the current progress*/
-(void) logProgress:(NSString*)progressMessage;
-(void) logProgressThread:(NSString*)progressMessage;

-(void) closeWindow:(id)object;
-(void) showCloseButton:(id)object;

@end

@implementation DBManager (DBManagerPrivate)


-(void) closeWindow:(id)object
{
	[[self window]close];
}

/*allow the user to close the window*/
-(void) showCloseButton:(id)object
{
	[closeButton setEnabled:YES];
}

#pragma mark Main thread messages
/*ONLY call these methods from within the main thread*/
-(void) progress:(NSNumber*)currentProgress
{
	[progressIndicator setDoubleValue:[currentProgress doubleValue]];
}

-(void) logProgress:(NSString*)progressMessage
{
	[textField setStringValue:progressMessage];
}

#pragma mark Threaded method wrappers
/*call these from within another thread*/
-(void) progressThread:(double)currentProgress
{
	[self performSelectorOnMainThread:@selector(progress:) 
						   withObject:[NSNumber numberWithDouble:currentProgress] 
						waitUntilDone:NO];
}

-(void) logProgressThread:(NSString*)progressMessage
{
	[self performSelectorOnMainThread:@selector(logProgress:)
							   withObject:progressMessage
							waitUntilDone:NO];
}

-(void) xmlDocumentFinished:(BOOL)status 
					xmlPath:(NSString*)path 
				 xmlDocName:(NSString*)docName
{
	if([docName isEqualToString:UPDATE_FILE]){
		/*parse the file, determine if there is a new version available*/
		[self parseDBXmlVersion:path];
		BOOL update = (availableVersion > [self currentVersion]);
		if(delegate != nil){
			[delegate newDatabaseAvailable:self status:update];
		}
	}
}

-(void) xmlDidFailWithError:(NSError*)xmlErrorMessage 
					xmlPath:(NSString*)path 
				 xmlDocName:(NSString*)docName
{
	NSLog(@"Connection failed! (%@)",[xmlErrorMessage localizedDescription]);
	
	NSRunAlertPanel(@"Error Account XML",[xmlErrorMessage localizedDescription],@"Close",nil,nil);
}

-(BOOL) xmlValidateData:(NSData*)xmlData xmlPath:(NSString*)path xmlDocName:(NSString*)docName
{
	return YES;
}

-(void) parseDBXmlVersion:(NSString*)xmlPath
{
	xmlDoc *doc = xmlReadFile([xmlPath fileSystemRepresentation], 0,0);
	if(doc == NULL){
		return;
	}
	
	xmlNode *node = xmlDocGetRootElement(doc);
	if(node == NULL){
		xmlFreeDoc(doc);
		return;
	}
	
	NSString *ver = findAttribute(node,(xmlChar*)"version");
	
	availableVersion = [ver integerValue];
	
	for(xmlNode *cur_node = node->children;
		cur_node != NULL;
		cur_node = cur_node->next)
	{
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		
		if(xmlStrcmp(cur_node->name,(xmlChar*)"file") == 0){
			file = getNodeText(cur_node);
			[file retain];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"sha1_bzip") == 0){
			sha1_bzip = getNodeText(cur_node);
			[sha1_bzip retain];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"sha1_dec") == 0){
			sha1_dec = getNodeText(cur_node);
			[sha1_dec retain];
		}else if(xmlStrcmp(cur_node->name,(xmlChar*)"sha1_built") == 0){
			sha1_database = getNodeText(cur_node);
			[sha1_database retain];
		}
	}
	
	xmlFreeDoc(doc);
}

@end


@implementation DBManager

-(DBManager*) init
{
	if(self = [super initWithWindowNibName:@"DatabaseUpdate"]){
		availableVersion = -1;
	}
	return self;
}

-(void) dealloc
{
	if(sha1_dec != nil){
		[sha1_dec release];
	}
	if(sha1_bzip != nil){
		[sha1_bzip release];
	}
	if(file != nil){
		[file release];
	}
	if(sha1_database != nil){
		[sha1_database release];
	}
	[super dealloc];
}

-(NSInteger) currentVersion
{
	sqlite3 *db;	
	char **results;
	NSInteger currentVersion = -1;
	int rc;
	int rows,cols;
	NSString *path = [Config buildPathSingle:DATABASE_SQLITE];
	
	rc = sqlite3_open([path fileSystemRepresentation],&db);
	if(rc != SQLITE_OK){
		currentVersion = -1;
		sqlite3_close(db);
		return -1;
	}
	
	rc = sqlite3_get_table(db,"SELECT versionNum FROM version;",&results,&rows,&cols,NULL);
	if(rc != SQLITE_OK){
		if(results != NULL){
			sqlite3_free_table(results);
		}
		sqlite3_close(db);
		return -1;
	}
	if(cols == 1 && rows == 1){
		currentVersion = strtol(results[1],NULL,10);
	}
	
	NSLog(@"Database current version: %ld",currentVersion);
	
	sqlite3_free_table(results);
	sqlite3_close(db);
	
	return currentVersion;
}

-(NSInteger) availableVersion
{
	return availableVersion;
}

/*
	Check to see if a database update exists.
	Call the delegate if one does exist.
 */
-(void) checkForUpdate
{
	//Config *cfg = [Config sharedInstance];
	NSString *url = [NSString stringWithString:[[NSUserDefaults standardUserDefaults] stringForKey:UD_DB_UPDATE_URL]];
	
	XmlFetcher *fetcher = [[XmlFetcher alloc]initWithDelegate:self];
	NSString *path = [Config buildPathSingle:DBUPDATE_DEFN];
	[fetcher saveXmlDocument:url docName:UPDATE_FILE savePath:path];
	[fetcher release];
}

-(void) downloadUpdate
{
	//Config *cfg = [Config sharedInstance];
	NSString *url = [NSString stringWithString:[[NSUserDefaults standardUserDefaults] stringForKey:UD_DB_SQL_URL]];
	
	XmlFetcher *fetcher = [[XmlFetcher alloc]initWithDelegate:self];
	NSString *path = [Config buildPathSingle:DATABASE_SQL_BZ2];
	[fetcher saveXmlDocument:url docName:@"database.sql.bz2" savePath:path];
	[fetcher release];
}


-(BOOL) databaseReadyToBuild
{
	NSString *dbTarball = [Config buildPathSingle:DATABASE_SQL_BZ2];
	NSString *dbXml = [Config buildPathSingle:DBUPDATE_DEFN];
	if([[NSFileManager defaultManager]
		fileExistsAtPath:dbTarball])
	{
		if([[NSFileManager defaultManager]
			fileExistsAtPath:dbXml])
		{
			return YES;			
		}
	}
	return NO;
}

-(void) setDelegate:(id)del
{
	delegate = del;
}
-(id) delegate
{
	return delegate;
}

-(void) awakeFromNib
{
	[progressIndicator setIndeterminate:NO];
	[progressIndicator setUsesThreadedAnimation:YES];
	[progressIndicator setDoubleValue:0.0];
	[progressIndicator setStyle:NSProgressIndicatorBarStyle];
}

-(IBAction) closeSheet:(id)sender
{
	[NSApp endSheet:progressPanel];
	[progressPanel orderOut:sender];
}

#pragma mark NSURLDownload delegate methods

/*
 these delegates are called from within the main thread, so there is no need for
 performSelectorOnMainThread
 */
-(void) downloadFinished:(NSURLDownload*)download
{
	[downloadResponse release];
	downloadResponse = nil;
	[download release];
	 
	NSNotification *not = [NSNotification notificationWithName:NOTE_DATABASE_DOWNLOAD_COMPLETE object:nil];
	[[NSNotificationCenter defaultCenter]postNotification:not];
	
	[[self window]close];
	[self autorelease];
}

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response
{
	[downloadResponse release];
	downloadResponse = [response retain];
	bytesReceived = 0;
}

-(void) downloadDidBegin:(NSURLDownload *)download
{
	[self logProgress:@"Downloading Eve Database"];
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
	[self logProgress:@"Download finished - Please restart to apply the new database"];
	[self downloadFinished:download];
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(NSUInteger)length
{
	long long expectedLength = [downloadResponse expectedContentLength];
	
	bytesReceived += length;
	
	if(expectedLength != NSURLResponseUnknownLength){
		double percentComplete = (bytesReceived / (double)expectedLength) * (double)100.0;
		[self progressThread:percentComplete];
	}else{
		[self logProgress:[NSString stringWithFormat:@"Received %lu bytes",length]];
	}
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
	[self logProgress:[error localizedFailureReason]];
	[self downloadFinished:download];
}


#pragma mark Ugly bastard function to build the new database

/*any resemblance to this function and good OO coding practice is purely coincedental */

-(BOOL) privateBuildDatabase
{
	int bzerror;
	NSString *str;
	unsigned char *buffer;
	int bytes_read;
	//int rc;
	//sqlite3 *db;
	//char *error = NULL;
	FILE *fin;
	FILE *fout;
	SHA_CTX digest_ctx;
	size_t len;
	unsigned char sha_digest[SHA_DIGEST_LENGTH];
	BOOL status = NO;
	
	
#define MEGABYTE 1048576
	
	/*read the SHA1 hashes*/
	str = [Config buildPathSingle:DBUPDATE_DEFN];
	[self parseDBXmlVersion:str];
	
	
	str = [Config buildPathSingle:DATABASE_SQL_BZ2];
	if(![[NSFileManager defaultManager]
		 fileExistsAtPath:str])
	{
		NSLog(@"Can't find new database archive. aborting");
		goto _finish_cleanup;
	}
	
	fin = fopen([str fileSystemRepresentation],"rb");
	if(fin == NULL){
		NSLog(@"Couldn't open database archive");
		goto _finish_cleanup;
	}
	
	buffer = malloc(MEGABYTE);
	
	if(buffer == NULL){
		/*yeah, right*/
		fclose(fin);
		goto _finish_cleanup;
	}
	
	[self logProgressThread:NSLocalizedString(@"Verifying tarball",@"database verification process")];
	[self progressThread:1.0];
	
	SHA1_Init(&digest_ctx);
	while ((len = fread(buffer,1,MEGABYTE,fin))) {
		SHA1_Update(&digest_ctx,buffer,len);
	}
	SHA1_Final(sha_digest,&digest_ctx);
	
	b64_ntop(sha_digest,SHA_DIGEST_LENGTH,(char*)buffer,MEGABYTE);
	
	if(![sha1_bzip isEqualToString:[NSString stringWithUTF8String:(const char*)buffer]]){
		/*SHA1 Digest failed!*/
		NSLog(@"SHA1 bz2 hashing failed ('%@' != '%s')",sha1_bzip,buffer);
		[self logProgressThread:@"Tarball verification failed"];
		fclose(fin);
		free(buffer);
		goto _finish_cleanup;
	}
	
	[self logProgressThread:@"Tarball verification succeeded"];
	[self progressThread:2.0];
	
	rewind(fin);
	
	str = [Config buildPathSingle:DATABASE_SQL];
	fout = fopen([str fileSystemRepresentation],"w+");
	if(fout == NULL){
		fclose(fin);
		fclose(fout);
		free(buffer);
		NSLog(@"Couldn't open output file");
		goto _finish_cleanup;
	}
	
	[self logProgressThread:@"Extracting & Verifying Tarball"];
	[self progressThread:3.0];
	
	
	BZFILE *compress = BZ2_bzReadOpen(&bzerror,fin,0,0,NULL,0);
	if(bzerror != BZ_OK){
		[self logProgressThread:@"Decompression error"];
		NSLog(@"Bzip2 error!");
		free(buffer);
		fclose(fin);
		fclose(fout);
		goto _finish_cleanup;
	}
	
	bzerror = BZ_OK;
	SHA1_Init(&digest_ctx);
	while (bzerror == BZ_OK) {
		bytes_read = BZ2_bzRead(&bzerror,compress,buffer,MEGABYTE);
		if(bzerror == BZ_OK || bzerror == BZ_STREAM_END){
			fwrite(buffer, 1, bytes_read, fout);
			SHA1_Update(&digest_ctx,buffer,bytes_read);
		}
	}
	SHA1_Final(sha_digest,&digest_ctx);
	
	//close the uncompressed output file
	fclose(fout);
		
	b64_ntop(sha_digest,SHA_DIGEST_LENGTH,(char*)buffer,MEGABYTE);
	
	if(![sha1_dec isEqualToString:[NSString stringWithUTF8String:(char*)buffer]]){
		/*SHA1 Digest failed!*/
		NSLog(@"SHA1 sql hashing failed ('%@' != '%s')",sha1_dec,buffer);
		[self logProgressThread:@"SQL verification failed"];
		fclose(fin);
		free(buffer);
		//[delegate newDatabaseBuilt:self status:NO];
		goto _finish_cleanup;
	}
	
	free(buffer);
	
	BZ2_bzReadClose(&bzerror,compress);
	fclose(fin);
	
	[self logProgressThread:
	 NSLocalizedString(@"Tarball extracted and verified",)
	 ];
	[self progressThread:4.0];
	
	str = [Config buildPathSingle:DATABASE_SQLITE_TMP];
	
	[[NSFileManager defaultManager] 
	 removeItemAtPath:str error:nil];
	
	[self logProgressThread:NSLocalizedString(@"Building Database",)];
	[self progressThread:5.0];

	/*
	 fork and exec sqlite to build the database.
	 the old approach used C code to read the file and manually
	 read the queries and build the DB, which was slow and crap.
	 */
	NSTask *task = [[NSTask alloc]init];
	[task setLaunchPath:@"/usr/bin/sqlite3"];

	NSArray *args = [NSArray arrayWithObjects:
					 @"-init",
					 [Config buildPathSingle:DATABASE_SQL],
					 str,
					 @".quit",nil];
	
	[task setArguments:args];
	[task launch];
	[task waitUntilExit];
	[task release];
	
	[self progressThread:7.0];
	
	NSLog(@"Database successfully built!");
	
	/*remove the old database*/
	str = [Config buildPathSingle:DATABASE_SQLITE];
	[[NSFileManager defaultManager] 
	 removeItemAtPath:str error:nil];
	
	/*rename the file*/
	str = [Config buildPathSingle:DATABASE_SQLITE_TMP];
	NSString *str2 = [Config buildPathSingle:DATABASE_SQLITE];
	[[NSFileManager defaultManager]
	 moveItemAtPath:str
	 toPath:str2 
	 error:NULL];
	
	[self logProgressThread:NSLocalizedString(@"All done!  Please Restart.",
											  @"Database construction complete")
	 ];
		
	status = YES;
	
_finish_cleanup:
	/*remove xml defn*/
	str = [Config buildPathSingle:DBUPDATE_DEFN];
	[[NSFileManager defaultManager]
	 removeItemAtPath:str error:nil];
	/*remove sql*/
	str = [Config buildPathSingle:DATABASE_SQL];
	[[NSFileManager defaultManager] 
	 removeItemAtPath:str error:nil];
	/*remove bzip sql*/
	str = [Config buildPathSingle:DATABASE_SQL_BZ2];
	[[NSFileManager defaultManager] 
	 removeItemAtPath:str error:nil];
	
	return status;
}

-(void) threadBuildDatabase:(NSCondition*)sig
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	
	[self privateBuildDatabase];
		
	//Database has been built.  close the window
	
	[self performSelectorOnMainThread:@selector(closeWindow:) 
						   withObject:nil 
						waitUntilDone:YES];
	
	//Notifiy the app it may continue its next stage of execution.
	
	[pool drain];
	
	[appStartObject performSelectorOnMainThread:appStartSelector
									 withObject:nil
								  waitUntilDone:NO];
	
	[appStartObject release];
	appStartObject = nil;
	
	[self release]; //destroy object.
}

-(void)buildDatabase2:(SEL)callBackFunc obj:(id)object
{
	[[self window]makeKeyAndOrderFront:nil];

	// Perform on main thread.
	[progressIndicator setMinValue:0.0];
	[progressIndicator setMaxValue:7.0];
	[progressIndicator setDoubleValue:0.0];
	[title setStringValue:NSLocalizedString(@"Building Database",
											@"database constuction start")];
		
	// open window on main thread.
	
	[self retain]; //retain object. thread function will release it.
	
	appStartSelector = callBackFunc;
	appStartObject = [object retain];
	
	[NSThread detachNewThreadSelector:@selector(threadBuildDatabase:) 
							 toTarget:self 
						   withObject:nil];
	
}

-(void) downloadDatabase
{
	NSString *savePath = [[NSUserDefaults standardUserDefaults] stringForKey:UD_ROOT_PATH];
	if(![[NSFileManager defaultManager] fileExistsAtPath:savePath]){
		
		/*Directory does not exist. create it.*/
		[[NSFileManager defaultManager]
		 createDirectoryAtPath:savePath 
		 withIntermediateDirectories:YES
		 attributes:nil 
		 error:NULL];
		
	}
	
	[self checkForUpdate];
	
	NSURL *url = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:UD_DB_SQL_URL]];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLDownload *download = [[NSURLDownload alloc]initWithRequest:request delegate:self];
	
	if(download == nil){
		[self logProgress:@"Error creating connection!"];
		[self showCloseButton:nil];
	}else{
		NSString *dest = [Config filePath:DATABASE_SQL_BZ2,nil];
		[download setDestination:dest allowOverwrite:YES];
		[download setDeletesFileUponFailure:YES];
	}
}


-(void)checkForUpdate2
{
	/*call from main thread*/	
	[progressIndicator setMinValue:0.0];
	[progressIndicator setMaxValue:100.0];
	[progressIndicator setDoubleValue:0.0];
	[title setStringValue:NSLocalizedString(@"Downloading database",@"download new database export")];

	[[self window]makeKeyAndOrderFront:nil];
	
	[self retain];
	
	[self downloadDatabase];
}

-(BOOL) dbVersionCheck:(NSInteger)minVersion
{
	NSString *path = [[NSUserDefaults standardUserDefaults] stringForKey:UD_ITEM_DB_PATH];
	
	if(![[NSFileManager defaultManager]fileExistsAtPath:path]){
		NSLog(@"Database does not exist!");
		return NO;
	}
	
	CCPDatabase *db = [[CCPDatabase alloc]initWithPath:path];
	
	BOOL status = [db dbVersion] >= minVersion;
	
	[db release];
	
	return status;
}


@end
