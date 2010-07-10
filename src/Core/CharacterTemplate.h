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


@interface CharacterTemplate : NSObject<NSCoding> {
	NSString *characterName;
	NSString *characterId;
	NSString *accountId;
	NSString *apiKey;
	BOOL active;
	BOOL primary;
}

@property (retain) NSString* characterName;
@property (retain) NSString* characterId;
@property (retain) NSString* accountId;
@property (retain) NSString* apiKey;
@property BOOL active;
@property BOOL primary;

-(CharacterTemplate*) initWithDetails:(NSString*)name 
							accountId:(NSString*)acctId
							   apiKey:(NSString*)key
							   charId:(NSString*)charId
							   active:(BOOL)isActive
							  primary:(BOOL)isPrimary;

@end
