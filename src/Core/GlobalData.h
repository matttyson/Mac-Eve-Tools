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

#import "SkillTree.h"

/*
 This singleton class is designed to hold global lookup data.
 Things such as the:
 
	SkillTree.
	Certeficates.
	CCP Database.
	Date Formatting.
 */

@class SkillTree;
@class CertTree;
@class CCPDatabase;

@interface GlobalData : NSObject {
	SkillTree *skillTree;
	CertTree *certTree;
	
	CCPDatabase *database;
	
	NSDateFormatter *dateFormatter;
}

@property (readonly,nonatomic) SkillTree* skillTree;
@property (readonly,nonatomic) CertTree* certTree;
@property (readonly,nonatomic) CCPDatabase* database;
@property (readonly,nonatomic) NSDateFormatter* dateFormatter;

+(GlobalData*) sharedInstance;



@end
