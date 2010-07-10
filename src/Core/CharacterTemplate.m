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

#import "CharacterTemplate.h"


@implementation CharacterTemplate


@synthesize characterName;
@synthesize characterId;
@synthesize accountId;
@synthesize apiKey;
@synthesize active;
@synthesize primary;

-(CharacterTemplate*) initWithDetails:(NSString*)name 
							accountId:(NSString*)acctId
							   apiKey:(NSString*)key
							   charId:(NSString*)charId
							   active:(BOOL)isActive
							  primary:(BOOL)isPrimary
{
	if((self = [super init])){
		self.characterId = [charId retain];
		self.characterName = [name retain];
		self.apiKey = [key retain];
		self.accountId = [acctId retain];
		self.active = isActive;
		self.primary = isPrimary;
	}
	return self;
}

-(void)dealloc
{
	[self.characterId release];
	[self.characterName release];
	[self.apiKey release];
	[self.accountId release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding protocol

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self != nil) {
		self.accountId = [aDecoder decodeObjectForKey:@"accountId"];
		self.active = [aDecoder decodeBoolForKey:@"active"];
		self.apiKey = [aDecoder decodeObjectForKey:@"apiKey"];
		self.characterId = [aDecoder decodeObjectForKey:@"characterId"];
		self.characterName = [aDecoder decodeObjectForKey:@"characterName"];
		self.primary = [aDecoder decodeBoolForKey:@"primary"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.accountId forKey:@"accountId"];
	[aCoder encodeBool:self.active forKey:@"active"];
	[aCoder encodeObject:self.apiKey forKey:@"apiKey"];
	[aCoder encodeObject:self.characterId forKey:@"characterId"];
	[aCoder encodeObject:self.characterName forKey:@"characterName"];
	[aCoder encodeBool:self.primary forKey:@"primary"];
}

@end
