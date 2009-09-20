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


@interface MTCharacterOverviewCell : NSTextFieldCell {
	NSNumberFormatter *iskFormat;
	NSNumberFormatter *spFormat;
	NSDateFormatter *dateFormat;
	
	NSImage *portrait;	
	NSDecimalNumber *isk;
	NSString *skillName;
	NSString *charName;
	NSDate *finishDate;
	
	NSInteger skillPoints;
	NSInteger queueTimeLeft;
	NSInteger skillTimeLeft;
	NSInteger queueLength;
	
	BOOL isTraining;
}

@property (readwrite,nonatomic,retain) NSImage* portrait;
@property (readwrite,nonatomic,retain) NSDecimalNumber* isk;
@property (readwrite,nonatomic,retain) NSString* charName;
@property (readwrite,nonatomic,retain) NSString* skillName;
@property (readwrite,nonatomic,retain) NSDate* finishDate;

@property (readwrite,nonatomic,assign) NSInteger skillPoints;
@property (readwrite,nonatomic,assign) NSInteger queueTimeLeft;
@property (readwrite,nonatomic,assign) NSInteger skillTimeLeft;
@property (readwrite,nonatomic,assign) NSInteger queueLength;

@property (readwrite,nonatomic,assign) BOOL isTraining;

@end
