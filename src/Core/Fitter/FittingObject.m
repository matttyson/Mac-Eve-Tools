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


#import "FittingObject.h"


@implementation FittingObject


-(FittingObject*) initWithTypeID:(NSInteger)tID andAttributes:(NSDictionary*)attrs
{
	if((self = [super init])){
		typeID = tID;
		attributes = [attrs retain];
	}
	return self;
}

-(void)dealloc
{
	[attributes release];
	[super dealloc];
}

-(BOOL) isActive
{
	return NO;
}

-(BOOL) canOverheat
{
	return NO;
}

-(enum SlotType) slotType
{
	return 0;
}

-(BOOL) hasCharges
{
	return NO;
}

-(ModuleCharge*) charge
{
	return nil;
}

-(void) setCharge:(ModuleCharge*)chrg
{
}

-(CGFloat) valueForAttribute:(enum CCPAttributeID)attributeID
{
	return 0.0;
}

@end
