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

@class Skill;
@class SkillGroup;

enum MTEveSkillCellMode
{
	Mode_Skill,
	Mode_Group
};

@interface MTEveSkillCell : NSTextFieldCell {
	NSNumberFormatter *formatter;
	NSImage *skillBook;
	NSImage *skillBookV;
	NSImage *infoIcon;
	NSMutableParagraphStyle *truncateStyle;
	
	Skill *skill;
	SkillGroup *group;
	
	NSInteger skillLevel;
	NSInteger timeLeft;
	NSInteger currentSP;
	CGFloat percentCompleted;
		
	BOOL iMouseDownInInfoButton;
    BOOL iMouseHoveredInInfoButton;
	
	SEL skillInfoButtonAction;
	enum MTEveSkillCellMode mode;
}

/*call these to configure the cell*/
@property (readwrite,nonatomic,retain) SkillGroup* group;

@property (readwrite,nonatomic,assign) NSInteger timeLeft;
@property (readwrite,nonatomic,assign) NSInteger currentSP;

@property (readwrite,nonatomic,assign) SEL skillInfoButtonAction;
@property (readwrite,nonatomic,assign) enum MTEveSkillCellMode mode;


-(Skill*) skill;
-(void) setSkill:(Skill*)s;

-(CGFloat) percentCompleted;
-(void) setPercentCompleted:(CGFloat)percentCompleted;

-(NSRect) skillProgressRect:(const NSRect* restrict)bounds
				   infoRect:(const NSRect* restrict)infoRect
					yOffset:(CGFloat)yOffset;

@end
