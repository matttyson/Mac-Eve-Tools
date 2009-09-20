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

#import "XMLCharacterOperation.h"

/*
	The final NSOperation object that depends on the XML sheet objects.
	
	This object may be used ONCE ONLY. make a new object instead of reusing it.
 
	At the moment this is where XML updating errors are discovered, but there is no
	way of reporting errors back to the caller.
 
	This class needs to be refactored and made to handle ALL xml sheets
 */

@interface XMLParseOperation : XMLCharacterOperation {
	NSMutableArray *xmlFiles;
	
	id delegate;
	SEL callback;
	id object;
}

@property (readwrite,nonatomic,assign) id delegate;
@property (readwrite,nonatomic,assign) id object;

/*the selector should accept one argumet of type NSArray*/
@property (readwrite,nonatomic,assign) SEL callback;

/*
 the xml sheet that is getting parsed, and the character directory it belongs to
 */
-(void) addCharacterDir:(NSString*)characterDir forSheet:(NSString*)xmlSheet;

@end
