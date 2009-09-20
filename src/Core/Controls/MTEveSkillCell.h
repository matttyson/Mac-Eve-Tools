//
//  MTEveSkillCell.h
//  Mac Eve Tools
//
//  Created by Matt Tyson on 18/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

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

@end
