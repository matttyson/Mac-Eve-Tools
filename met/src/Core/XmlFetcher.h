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


/*
	This class is being phased out, don't use it in new code.
 */


@protocol XmlFetcherDelegate
/*
 Delegate prototype. implement this method and it will be called when the document is finished.
 
 status: YES means it succeded, NO means it broke
 path: Fully qualified path to the XML document. nil if file could not be written
 xmlDocName: the name of the document that was passed in. eg @"/char/SkillTree.aspx.xml"
*/
-(void) xmlDocumentFinished:(BOOL)status xmlPath:(NSString*)path xmlDocName:(NSString*)docName;

-(void) xmlDidFailWithError:(NSError*)error xmlPath:(NSString*)path xmlDocName:(NSString*)docName;

/*return YES if the data is OK.  NO if the data is bad*/
-(BOOL) xmlValidateData:(NSData*)data  xmlPath:(NSString*)path xmlDocName:(NSString*)docName;

@end

@interface XmlFetcher : NSObject {
	
	NSMutableData *xmlData; //URL data
	
	NSString *docName; /*@"/char/charsheet.aspx.xml  returned to the user*/
	NSString *savePath; /*fully qualified save path*/
	
	id <XmlFetcherDelegate> delegate;
}

-(XmlFetcher*) init;
-(XmlFetcher*) initWithDelegate:(id <XmlFetcherDelegate>)del;

/*sets the new delegate to be del*/
-(void) setDelegate:(id <XmlFetcherDelegate>)del;
/*
	Grab an XML document and save it to disk at the specified path.
 
	fullDocUrl: The full path to the XML document, with all required HTTP GET parameters
	docName: a string that will be returned to the delgate to identify what was fetched.
	path: the path to save the document to. note that it is not a fully qualified path.
			"/Users/username/Library/Application Support/" will be prepended to the path you supply.
			supply nil to save to the root directory
 
	the delegate will be called once the document has been saved.
	
	runLoopMode can be either NSDefaultRunLoopMode or NSModalPanelRunLoopMode.  calling without specifiy this
	paramter calls with NSDefaultRunLoopMode
 */
-(void) saveXmlDocument:(NSString*)fullDocUrl docName:(NSString*)name savePath:(NSString*)path runLoopMode:(NSString*)mode;
-(void) saveXmlDocument:(NSString*)fullDocUrl docName:(NSString*)name savePath:(NSString*)path;
-(BOOL) saveXmlDocument:(NSString*)fullDocUrl savePath:(NSString*)path;

@end

