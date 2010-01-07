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

@class CCPDatabase;
@class CCPTypeAttribute;

@interface CCPType : NSObject {
	NSInteger typeID;
	NSInteger parentTypeID;
	NSInteger groupID;
	NSInteger metaGroupID;
	NSInteger graphicID;
	NSInteger raceID;
	NSInteger marketGroupID;
	NSInteger metaLevel;
	double radius;
	double mass;
	double volume;
	double capacity;
	double basePrice;
	NSString *typeName;
	NSString *typeDescription;
	
	NSInteger pirate;
	
	NSArray *skills;
	CCPDatabase *database;
	
	NSDictionary *attributes;
}

@property (readonly,nonatomic) NSInteger typeID;
@property (readonly,nonatomic) NSInteger groupID;
@property (readonly,nonatomic) NSInteger graphicID;
@property (readonly,nonatomic) NSInteger raceID;
@property (readonly,nonatomic) NSInteger marketGroupID;

@property (readonly,nonatomic) double radius;
@property (readonly,nonatomic) double mass;
@property (readonly,nonatomic) double volume;
@property (readonly,nonatomic) double capacity;
@property (readonly,nonatomic) double basePrice;

@property (readonly,nonatomic) NSString* typeName;
@property (readonly,nonatomic) NSString* typeDescription;

@property (readonly,nonatomic) NSDictionary* attributes;

-(NSInteger) metaGroupID;
-(NSInteger) parentTypeID;
-(NSInteger) metaLevel;

//prob shouldn't be here
-(BOOL) isPirateShip;

/*hm, this could use some rethinking.*/
-(CCPType*) initWithType:(NSInteger)typeID
				   group:(NSInteger)gID
				 graphic:(NSInteger)grID
					race:(NSInteger)rID
			 marketGroup:(NSInteger)mgID
				  radius:(double)rad
					mass:(double)mas
				  volume:(double)vol
				capacity:(double)cap
			   basePrice:(double)bPrice
				typeName:(NSString*)tName
				typeDesc:(NSString*)tDesc
				database:(CCPDatabase*)db;

-(NSArray*) prereqs;

/*
 return an attribute that belongs to this type. 
 returns NULL if nothing is available for the requested typeAttribute
 */
-(CCPTypeAttribute*) attributeForID:(NSInteger)attrID;

@end
