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
#import "read_query.h"

#import <libxml/tree.h>
#import <bzlib.h>
#import <sqlite3.h>
#import <openssl/sha.h>

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

-(NSString*) buildString:(NSString*)str;
-(void) closeWindow:(id)object;

@end

@implementation DBManager (DBManagerPrivate)

-(NSString*) buildString:(NSString*)str
{
	return nil;
}

/*allow the user to close the window*/
-(void) closeWindow:(id)object
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

-(void) xmlDocumentFinished:(BOOL)status xmlPath:(NSString*)path xmlDocName:(NSString*)docName
{
	if([docName isEqualToString:UPDATE_FILE]){
		/*parse the file, determine if there is a new version available*/
		[self parseDBXmlVersion:path];
		BOOL update = (availableVersion > [self currentVersion]);
		[delegate newDatabaseAvailable:self status:update];
	}
}

-(void) xmlDidFailWithError:(NSError*)xmlErrorMessage xmlPath:(NSString*)path xmlDocName:(NSString*)docName
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
	if(self = [super init]){
		availableVersion = -1;
	}
	return self;
}

-(void) dealloc
{
	if(sha1_dec != NULL){
		[sha1_dec release];
	}
	if(sha1_bzip != NULL){
		[sha1_bzip release];
	}
	if(file != NULL){
		[file release];
	}
	if(sha1_database != NULL){
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

-(void) performCheck
{
	Config *cfg = [Config sharedInstance];
	NSString *url = [NSString stringWithString:[cfg dbUpdateUrl]];
	
	XmlFetcher *fetcher = [[XmlFetcher alloc]initWithDelegate:self];
	NSString *path = [Config buildPathSingle:DBUPDATE_DEFN];
	[fetcher saveXmlDocument:url docName:UPDATE_FILE savePath:path];
	[fetcher release];
}

-(void) downloadUpdate
{
	Config *cfg = [Config sharedInstance];
	NSString *url = [NSString stringWithString:[cfg dbSQLUrl]];
	
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

-(void) downloadDatabase:(id)object
{
	[progressIndicator setMinValue:0.0];
	[progressIndicator setMaxValue:100.0];
	[progressIndicator setDoubleValue:0.0];
	[title setStringValue:@"Downloading database"];
	
	[NSApp beginSheet:progressPanel
	   modalForWindow:object
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:NULL];
	
	
	//NSString *savePath = @"/Library/Application Support/MacEveApi";
	NSString *savePath = [[Config sharedInstance]rootPath];
	if(![[NSFileManager defaultManager] fileExistsAtPath:savePath]){
		
		/*Directory does not exist. create it.*/
		[[NSFileManager defaultManager]
		 createDirectoryAtPath:savePath 
		 withIntermediateDirectories:YES
		 attributes:nil 
		 error:NULL];
		
	}
	
	NSURL *url = [NSURL URLWithString:[[Config sharedInstance]dbSQLUrl]];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLDownload *download = [[NSURLDownload alloc]initWithRequest:request delegate:self];
	
	if(!download){
		[self logProgress:@"Error creating connection!"];
		[self closeWindow:nil];
	}else{
		NSString *dest = [Config filePath:DATABASE_SQL_BZ2,nil];
		[download setDestination:dest allowOverwrite:YES];
		[download setDeletesFileUponFailure:YES];
	}
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
	[self closeWindow:nil];
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
	int rc;
	sqlite3 *db;
	char *error = NULL;
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
	
	[self logProgressThread:@"Verifying tarball"];
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
	
	fflush(fout);
	
	//[self logProgressThread:@"Tarball extracted"];
	
	b64_ntop(sha_digest,SHA_DIGEST_LENGTH,(char*)buffer,MEGABYTE);
	
	if(![sha1_dec isEqualToString:[NSString stringWithUTF8String:(char*)buffer]]){
		/*SHA1 Digest failed!*/
		NSLog(@"SHA1 sql hashing failed ('%@' != '%s')",sha1_dec,buffer);
		[self logProgressThread:@"SQL verification failed"];
		fclose(fin);
		fclose(fout);
		free(buffer);
		//[delegate newDatabaseBuilt:self status:NO];
		goto _finish_cleanup;
	}
	
	BZ2_bzReadClose(&bzerror,compress);
	fclose(fin);
	
	[self logProgressThread:@"Tarball extracted and verified"];
	[self progressThread:4.0];
	
	str = [Config buildPathSingle:DATABASE_SQLITE_TMP];
	
	[[NSFileManager defaultManager] 
	 removeItemAtPath:str error:nil];
	
	rc = sqlite3_open([str fileSystemRepresentation],&db);
	if(rc != SQLITE_OK){
		/*bleh*/
		free(buffer);
		fclose(fout);
		goto _finish_cleanup;
	}
	
	fseek(fout,0L,SEEK_SET);
	
	[self logProgressThread:@"Building Database"];
	[self progressThread:5.0];
	
	while(read_query((char*)buffer,MEGABYTE,fout) != 0L){
		rc = sqlite3_exec(db,(char*)buffer,NULL,NULL,&error);
		if(rc != SQLITE_OK){
			NSLog(@"SQLITE Error: %s:",error);
			sqlite3_free(error);
			sqlite3_close(db);
			error = NULL;
			//[delegate newDatabaseBuilt:self status:NO];
		}
	}
	
	fclose(fout);
	sqlite3_close(db);
	
	[self logProgressThread:@"Database built"];
	[self logProgressThread:@"Verifiying database"];
	[self progressThread:6.0];
	
	/*verify the new database built correctly*/
	
	/*
	fin = fopen([str fileSystemRepresentation],"rb");
	SHA1_Init(&digest_ctx);
	while ((len = fread(buffer,1,MEGABYTE,fin))) {
		SHA1_Update(&digest_ctx,buffer,len);
	}
	SHA1_Final(sha_digest,&digest_ctx);
	
	fclose(fin);
	
	b64_ntop(sha_digest,SHA_DIGEST_LENGTH,buffer,MEGABYTE);
	if(![sha1_database isEqualToString:[NSString stringWithUTF8String:buffer]]){
		NSLog(@"SHA1 database hashing failed ('%@' != '%s')",sha1_database,buffer);
		[self logProgressThread:@"Database verification failed"];
		[[NSFileManager defaultManager] 
		 removeItemAtPath:str error:nil];
		str = [Config buildPathSingle:DBUPDATE_DEFN];
		[[NSFileManager defaultManager] 
		 removeItemAtPath:str error:nil];
		str = [Config buildPathSingle:DATABASE_SQL];
		[[NSFileManager defaultManager] 
		 removeItemAtPath:str error:nil];
		free(buffer);
		goto _finish_cleanup;
	}
	[self logProgressThread:@"Database verification succeeded"];
	*/
	[self progressThread:7.0];
	
	free(buffer);
	
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
	
	[self logProgressThread:@"All done!"];
	
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

-(void) threadBuildDatabase:(id)object
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	
	[self privateBuildDatabase];
	
	[self performSelectorOnMainThread:@selector(closeWindow:) 
						   withObject:object 
						waitUntilDone:NO];
	
	[pool drain];
}

-(void) buildDatabase:(id)object
{
	[progressIndicator setMinValue:0.0];
	[progressIndicator setMaxValue:7.0];
	[progressIndicator setDoubleValue:0.0];
	[title setStringValue:@"Building database"];
	
	[NSApp beginSheet:progressPanel
	   modalForWindow:object
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:NULL];
	
	[NSThread detachNewThreadSelector:@selector(threadBuildDatabase:) toTarget:self withObject:nil];
}


@end
